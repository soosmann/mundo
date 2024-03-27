import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';

class Post{
  String id;
  String ownerId;
  String title;
  final List<dynamic> postElements;
  int? mainImageIndex;
  int creationUnixTimeStamp;
  LatLng location;

  int _positionCounter = 0;

  Post({String? customId, required this.ownerId, required this.title, required this.postElements, this.mainImageIndex, required this.location}): 
    id = customId ?? const Uuid().v4(),
    creationUnixTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch;

  changeTitle(String newTitle){
    title = newTitle;
  }

  changeLocation(LatLng newLocation){
    location = newLocation;
  }

  addText(String text){
    if (postElements.length <= 10){
      postElements.add(PostText(text: text, position: _positionCounter));
      _positionCounter++;
      updateElementPositions();
    }
  }

  addImage(File imageTemp){
    if (postElements.length <= 10){
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

  deleteText(PostText postText){
    postElements.remove(postText);
    updateElementPositions();
    _positionCounter--;
  }

  deleteImage(PostImage postImage){
    postElements.remove(postImage);
    updateElementPositions();
    _positionCounter--;
  }

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

  setCreationTimeStamp(){
    creationUnixTimeStamp = DateTime.now().toUtc().millisecondsSinceEpoch;
  }

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

  @override
  String toString(){
    return "Post(title: $title, postElements: $postElements, mainImageIndex: $mainImageIndex, timeStamp: $creationUnixTimeStamp, location: $location)";
  }
}

class PostText{
  String text;
  int position;

  PostText({required this.text, required this.position});

  @override
  String toString(){
    String stringText = "PostText(text: $text, position: $position)";
    return stringText;
  }
}

class PostImage{
  final File imageFile;
  bool isMainImage;
  int position;

  PostImage({required this.imageFile, required this.isMainImage, required this.position});

  @override
  String toString(){
    String stringText = "PostImage(imageFile: $imageFile, isMainImage: $isMainImage, position: $position)";
    return stringText;
  }
}