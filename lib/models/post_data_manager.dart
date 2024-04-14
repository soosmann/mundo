import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/models/user.dart';

/// class that manages data traffic with Firebase related to MiMundo Posts
class PostDataManager{
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService authService = AuthService();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final UserDataManager userDataManager = UserDataManager();

  /// save a post image to Firebase Storage
  /// returns the download URL of the image to be able to place it in a post Doc in Firestore Db
  Future<String> savePostImage(PostImage postImage, String postId) async {
    String? currentUserId = authService.currentUser?.uid;

    String imageUrl = "";

    if (currentUserId != null) {
      final ref = storage
        .ref()
        .child("posts")
        .child(postId)
        .child("image_${postImage.position}");

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: <String, String>{
          "position": postImage.position.toString(),
          "isMainImage": postImage.isMainImage.toString()
        }
      );

      UploadTask uploadTask = ref.putFile(postImage.imageFile, metadata);

      await uploadTask.whenComplete(() async {
        imageUrl = await ref.getDownloadURL();
      });
    }
    return imageUrl;
  }

  /// add a post to the Firestore Db\
  /// increments the post count of the user who created the post
  Future<void> addPost(Post post) async {
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      post.setCreationTimeStamp();
      final Map<String, dynamic> dataJson = <String, dynamic>{
        "id": post.id,
        "owner": post.ownerId,
        "title": post.title,
        "mainImageIndex": post.mainImageIndex,
        "date": post.creationUnixTimeStamp,
        "loc": {
          "gMapsId": post.location!.googleMapsId,
          "city": post.location!.city,
          "region": post.location!.region,
          "lat": post.location!.coordinates.latitude,
          "lng": post.location!.coordinates.longitude
        },
        "content": []
      };

      for (int i = 0; i < post.postElements.length; i++){
        Map<String, dynamic> contentItems = {};

        if (post.postElements[i] is PostText){
          PostText postText = post.postElements[i] as PostText;
          contentItems.addAll({
            "type": "text",
            "text": postText.text,
            "position": postText.position
          });
        } else if (post.postElements[i] is PostImage){
          PostImage postImage = post.postElements[i] as PostImage;
          String imageUrl = await savePostImage(postImage, post.id);
          contentItems.addAll({
            "type": "image",
            "imageUrl": imageUrl,
            "isMainImage": postImage.isMainImage,
            "position": postImage.position
          });
        }
        dataJson["content"].add(contentItems);
      }
      try {
        db
          .collection('posts')
          .doc(post.id)
          .set(dataJson);
          
        incrementPostAmount(currentUserId);
      } on FirebaseException catch (e) {
        throw Exception("Error: $e");
      }
    } else {
      throw Exception("No user logged in.");
    }
  }

  /// get all posts of a user by their user id
  Future<List<Post>> getPostsByUserId(String userId) async {
    String? currentUserId = authService.currentUser?.uid;
    List<Post> posts = [];

    if (currentUserId != null) {
      final result = await db
        .collection('posts')
        .where('owner', isEqualTo: userId) // index: owner ascending, date descending, __name__ descending
        .orderBy("date", descending: true)
        .get(); // TODO: add pagination to not load all posts at once -> takes too much time

      for (var doc in result.docs){
        posts.add(await Post.createFromFirebaseMap(doc));
      }
    }
    return posts;
  }

  /// increment post amount of a user
  void incrementPostAmount(String userId){
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("users").doc(userId).update({"posts": FieldValue.increment(1)});
    }
  }

  /// decrement post amount of a user
  void decrementPostAmount(String userId){
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("users").doc(userId).update({"posts": FieldValue.increment(-1)});
    }
  }

  /// get posts for the feed page of a user based on timestamp\
  /// retrieves users the user follows\
  /// based on this, get newest posts of user\
  Future<List<Post>> getPostsForFyPage(String userId, int timeStamp) async {
    String? currentUserId = authService.currentUser?.uid;
    List<Post> posts = [];

    if (currentUserId != null){
      List<MundoUser> followingUsers = await userDataManager.getFollowings(userId); // TODO: split getFollowings and getPostsForFyPage to only load followers once on fyp, not everytime new posts are loaded
      
      final postResults = await db
        .collection("posts")
        .where("owner", whereIn: followingUsers.map((e) => e.id).toList())
        .where("date", isLessThan: timeStamp)
        .orderBy("date", descending: true)
        .limit(3)
        .get();

      for (var doc in postResults.docs){
        posts.add(await Post.createFromFirebaseMap(doc));
      }
    }
    return posts;
  }

  /// delete a post and decrement the post amount of the user who created the post
  Future<void> deletePost(String postId) async {
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      try {
        await db.collection("posts").doc(postId).delete();

        var results = await storage.ref().child("posts").child(postId).listAll(); // cant directly delete dir, need to delete file by file
        for (var item in results.items){
          await item.delete();
        }

        decrementPostAmount(AuthService().currentUser!.uid);
      } on FirebaseException catch (e) {
        throw Exception("Error: $e");
      }
    }
  }

  /// retrieve posts by Google Maps Id\
  /// used to get posts for a location page, all posts have attached Google Maps Id
  Future<List<Post>> getPostsByLocationId(String googleMapsId) async {
    String? currentUserId = authService.currentUser?.uid;
    List<Post> posts = [];

    if (currentUserId != null){
      final postData = await db.collection("posts").where("loc.gMapsId", isEqualTo: googleMapsId).limit(6).get();
      
      for (var doc in postData.docs){
        posts.add(await Post.createFromFirebaseMap(doc));
      }
    }
    return posts;
  }  
}