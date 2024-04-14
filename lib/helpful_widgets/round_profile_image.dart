import 'package:flutter/material.dart';

/// function to create a round profile image
/// decides between placeholder and network image by given picture string
Widget roundProfileImage(BuildContext context, String? picture, double width, double height){
  return SizedBox(
    width: width,
    height: height,
    child: ClipOval(
      child: picture != null && picture != ""
        ? roundProfileImageNetwork(context, picture, width, height)
        : roundProfileImagePlaceholder(context, width, height),
    ),
  );
}

/// placeholder for round profile image
Widget roundProfileImagePlaceholder(BuildContext context, double width, double height){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.secondary,
    ),
    child: Icon(
      Icons.person_rounded,
      size: width,
      color: Colors.white
    ),
  );
}

/// network image for round profile image
Widget roundProfileImageNetwork(BuildContext context, String link, double width, double height){
  return Image.network(
    link,
    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
      if (loadingProgress == null) {
        return child;
      } else {
        return const CircularProgressIndicator();
      }
    },
    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
      return const Text('Error loading image');
    },
    fit: BoxFit.cover,
  );
}