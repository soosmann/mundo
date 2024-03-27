import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/user_data_manager.dart';

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
          "lat": post.location.latitude,
          "lng": post.location.longitude
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
          String imageUrl = await savePostImage(postImage, post.title);
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
          
        incrementPostAmount();
      } on FirebaseException catch (e) {
        print("Error: $e");
      }
    } else {
      print("No user logged in.");
    }
  }

  Future<File> getImageFileFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getTemporaryDirectory();
      String rng = math.Random().nextInt(10000).toString();
      final file = File('${documentDirectory.path}/temp_image_$rng.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      print('Error downloading image: $e');
      rethrow;
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
        List<dynamic> content = doc["content"];
        List<dynamic> postElements = [];

        for (var item in content){
          if (item["type"] == "text"){
            postElements.add(PostText(text: item["text"], position: item["position"]));
          } else if (item["type"] == "image"){
            postElements.add(PostImage(
              imageFile: await getImageFileFromUrl(item["imageUrl"]),
              isMainImage: item["isMainImage"],
              position: item["position"]
            ));
          }
        }
        posts.add(Post(
          customId: doc["id"],
          ownerId: doc["owner"],
          title: doc["title"],
          postElements: postElements,
          mainImageIndex: doc["mainImageIndex"],
          location: LatLng(doc["loc"]["lat"], doc["loc"]["lng"])
        ));
      }
    }
    return posts;
  }

  void incrementPostAmount(){
    String? currentUserId = authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("users").doc(currentUserId).update({"posts": FieldValue.increment(1)});
    }
  }
}