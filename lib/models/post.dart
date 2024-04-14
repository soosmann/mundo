import 'dart:io';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:mundo/models/location.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// class that represents a post in the app
class Post{
  String id;
  String ownerId;
  String title;
  final List<dynamic> postElements;
  int? mainImageIndex;
  int creationUnixTimeStamp;
  MundoLocation? location;

  int _positionCounter = 0;

  Post({String? customId, required this.ownerId, required this.title, required this.postElements, int? creationUnixTimeStamp, this.mainImageIndex, this.location}): 
    id = customId ?? const Uuid().v4(),
    creationUnixTimeStamp = creationUnixTimeStamp ?? DateTime.now().toUtc().millisecondsSinceEpoch;

  /// setter for title
  changeTitle(String newTitle){
    title = newTitle;
  }

  /// setter for location
  changeLocation(MundoLocation newLocation){
    location = newLocation;
  }

  /// add a text element to the post if there are less than 10 elements
  addText(String text){
    if (postElements.length <= 9){
      postElements.add(PostText(text: text, position: _positionCounter));
      _positionCounter++;
      updateElementPositions();
    }
  }

  /// add an image element to the post if there are less than 10 elements\
  /// set it to main image if its the first selected image
  addImage(File imageTemp){
    if (postElements.length <= 9){
      bool isNewImageMainImage = true;
      for (var element in postElements){
        if (element is PostImage){
          if (element.isMainImage){
            isNewImageMainImage = false;
          }
        }
      }

      if (isNewImageMainImage){
        mainImageIndex = _positionCounter;
      }

      postElements.add(PostImage(imageFile: imageTemp, isMainImage: isNewImageMainImage, position: _positionCounter));
      _positionCounter++;
      updateElementPositions();
    }
  }

  /// delete a text element from the post\
  /// update the positions of the remaining elements
  deleteText(PostText postText){
    postElements.remove(postText);
    updateElementPositions();
    _positionCounter--;
  }

  /// delete an image element from the post\
  /// update the positions of the remaining elements
  deleteImage(PostImage postImage){
    postElements.remove(postImage);
    updateElementPositions();
    _positionCounter--;
  }

  /// update the positions of the elements in the post\
  /// is used to keep the positions from 0-9 of the elements in the list up to date
  updateElementPositions(){
    bool mainImageFound = false;
    for (var i = 0; i < postElements.length; i++) {
      final postElement = postElements[i];
      if (postElement is PostText) {
        postElement.position = i;
      } else if (postElement is PostImage) {
        postElement.position = i;
        if (postElement.isMainImage){ // one has to change mainImageIndex if the main image is moved
          mainImageIndex = postElement.position;
          mainImageFound = true;
        }
      }
    }

    if (!mainImageFound){
      for (var postElement in postElements){
        if (postElement is PostImage) {
          postElement.isMainImage = true;
          mainImageIndex = postElement.position;
          break;
        }
      }
    }
  }

  /// setter unix timestamp
  setCreationTimeStamp(){
    creationUnixTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

  /// check if the post has a text and an image element\
  /// can be used to check if a post is valid
  bool getHasTextAndImage(){
    bool hasText = false;
    bool hasImage = false;

    for (var postElement in postElements){
      if (postElement is PostText){
        hasText = true;
      } else if (postElement is PostImage){
        hasImage = true;
      }
    }

    return hasText && hasImage;
  }

  /// delete all elements that are empty
  deleteNotNecessaryElements(){
    final copy = List.from(postElements); // copy the list to avoid editing the iterated list
    for (var postElement in copy){
      if (postElement is PostText){
        if (postElement.text.isEmpty){
          deleteText(postElement);
        }
      } else if (postElement is PostImage){
        if (postElement.imageFile.path.isEmpty){
          deleteImage(postElement);
        }
      }
    }
  }

  /// standardmethod toString
  @override
  String toString(){
    return "Post(title: $title, postElements: $postElements, mainImageIndex: $mainImageIndex, timeStamp: $creationUnixTimeStamp, location: $location)";
  }

  /// method to get a file from an image url
  /// used to download images from the internet and save them as Flutter File in PostImage instance
  static Future<File> getImageFileFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final documentDirectory = await getTemporaryDirectory();
      String rng = math.Random().nextInt(10000).toString();
      final file = File('${documentDirectory.path}/temp_image_$rng.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }

  /// method to create a Post instance from a Firebase map
  static Future<Post> createFromFirebaseMap(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    List<dynamic> content = doc["content"];
    List<dynamic> postElements = [];

    for (var item in content) {
      if (item["type"] == "text") {
        postElements.add(PostText(text: item["text"], position: item["position"]));
      } else if (item["type"] == "image") {
        postElements.add(PostImage(
          imageFile: await Post.getImageFileFromUrl(item["imageUrl"]),
          isMainImage: item["isMainImage"],
          position: item["position"]
        ));
      }
    }
    
    return Post(
      customId: doc["id"],
      ownerId: doc["owner"],
      title: doc["title"],
      postElements: postElements,
      mainImageIndex: doc["mainImageIndex"],
      creationUnixTimeStamp: doc["date"],
      location: MundoLocation(
        googleMapsId: doc["loc"]["gMapsId"], 
        city: doc["loc"]["city"], 
        region: doc["loc"]["region"],
        coordinates: LatLng(doc["loc"]["lat"], doc["loc"]["lng"])
      )
    );
  }
}

/// class that represents a text element in a post
class PostText{
  String text;
  int position;

  PostText({required this.text, required this.position});

  /// standardmethod toString
  @override
  String toString(){
    String stringText = "PostText(text: $text, position: $position)";
    return stringText;
  }
}

/// class that represents an image element in a post
class PostImage{
  final File imageFile;
  bool isMainImage;
  int position;

  PostImage({required this.imageFile, required this.isMainImage, required this.position});

  /// standardmethod toString
  @override
  String toString(){
    String stringText = "PostImage(imageFile: $imageFile, isMainImage: $isMainImage, position: $position)";
    return stringText;
  }
}