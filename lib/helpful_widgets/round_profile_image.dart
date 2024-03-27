import 'package:flutter/material.dart';

Widget roundProfileImage(BuildContext context, String? picture, double width, double height){ // TODO: Tropfenform
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

/*
  bool createPostButtonPressed = false;
  Widget createPostButton(BuildContext context){
    return Listener(
      onPointerUp: (_){
        setState(() {
          createPostButtonPressed = false;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostView())
          );
        });
      },
      onPointerDown: (_){
        setState(() {
          createPostButtonPressed = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 30, 
              offset: const Offset(10, 10), 
              color: Colors.black.withOpacity(createPostButtonPressed ? 0.4 : 0.4),
              inset: createPostButtonPressed
            ),
            BoxShadow(
              blurRadius: 30, 
              offset: const Offset(-10, -10), 
              color: Colors.grey.withOpacity(createPostButtonPressed ? 0.4 : 0.4),
              inset: createPostButtonPressed
            )
          ],
        ),
        child: const SizedBox(
          height: 50, 
          width: 250,
          child: Icon(Icons.add)
        ), 
      )
    );
  }

  bool settingsButtonPressed = false;
  Widget settingsButton(BuildContext context){
    return Listener(
      onPointerUp: (_){
        setState(() {
          settingsButtonPressed = false;
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const ProfileSettingsView())
          );
        });
      },
      onPointerDown: (_){
        setState(() {
          settingsButtonPressed = true;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 30, 
              offset: const Offset(10, 10), 
              color: Colors.black.withOpacity(settingsButtonPressed ? 0.4 : 0.4),
              inset: settingsButtonPressed
            ),
            BoxShadow(
              blurRadius: 30, 
              offset: const Offset(-10, -10), 
              color: Colors.grey.withOpacity(settingsButtonPressed ? 0.4 : 0.4),
              inset: settingsButtonPressed
            )
          ],
        ),
        child: const SizedBox(
          height: 50, 
          width: 50,
          child: Icon(Icons.settings)
        ), 
      )
    );
  }

  Widget settingsAndCreateButton(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        createPostButton(context),
        settingsButton(context),
      ],
    );
  }
  */