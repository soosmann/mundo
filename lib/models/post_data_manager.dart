import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/models/mundo_user.dart';

class PostDataManager{
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService authService = AuthService();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final UserDataManager userDataManager = UserDataManager();

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
        print("Error: $e");
      }
    } else {
      print("No user logged in.");
    }
  }

  Future<List<Post>> getPostsByUserId(String userId) async {
    String? currentUserId = authService.currentUser?.uid;
    List<Post> posts = [];

    if (currentUserId != null) {
      final result = await db
        .collection('posts')
        .where('owner', isEqualTo: userId) // index: owner ascending, date descending, __name__ descending
        .orderBy("date", descending: true)
        .get();

      for (var doc in result.docs){
        posts.add(await Post.createFromFirebaseMap(doc));
      }
    }
    return posts;
  }

  void incrementPostAmount(String userId){
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("users").doc(userId).update({"posts": FieldValue.increment(1)});
    }
  }

  void decrementPostAmount(String userId){
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("users").doc(userId).update({"posts": FieldValue.increment(-1)});
    }
  }

  Future<List<Post>> getPostsForFyPage(String userId, int timeStamp) async {
    String? currentUserId = authService.currentUser?.uid;
    List<Post> posts = [];

    if (currentUserId != null){
      List<MundoUser> followingUsers = await userDataManager.getFollowings(userId);
      
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
        print("Error: $e");
      }
    }
  }

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