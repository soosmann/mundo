import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/mundo_user.dart';

class ProfileSettingsView extends StatefulWidget {
  final MundoUser user;
  const ProfileSettingsView({super.key, required this.user});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsView();
}

class _ProfileSettingsView extends State<ProfileSettingsView> {
  UserDataManager userDataManager = UserDataManager();
  final TextEditingController _usernameController = TextEditingController();

  File? newProfilePicture;

  String userNameInfoString = "Dies ist dein aktueller Benutzername";
  bool isUserNameAvailable = true;

  Future selectImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedImage == null) return;
      setState(() {
        newProfilePicture = File(pickedImage.path);
      });
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  void initState(){
    super.initState();
    _usernameController.text = widget.user.username;
  }

  Widget _appBar() {
    return AppBar(
      title: const Text("Settings"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.done),
          onPressed: () async {
            if (_usernameController.text != widget.user.username && isUserNameAvailable){
              userDataManager.updateUsername(_usernameController.text);
            }
            if (newProfilePicture != null){
              bool uploadSuccess = await userDataManager.saveProfileImage(
                newProfilePicture!, 
                SettableMetadata(
                  contentType: 'image/jpeg',
                  customMetadata: {'picked': 'image'}
                )
              );
              if (uploadSuccess ==  true){
                  setState(() {
                    Navigator.pop(context);
                  });
              }
            }else{
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  Widget _profileImage(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: GestureDetector(
        onTap: () async {
          await selectImageFromGallery();
        },
        child: ClipOval(
          child: Stack(
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: newProfilePicture == null 
                  ? roundProfileImage(context, widget.user.profilePictureUrl, 200, 200)
                  : Image.file(
                      newProfilePicture!,
                      fit: BoxFit.cover
                    ),
              ),
              Positioned(
                bottom: 0,
                left:0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: const Text(
                    'Ändern',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ]
          ),
        ),
      )
    );
  }

  Widget _darkModeSwitch(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Farbmodus",
            style: TextStyle(fontSize: 20),
          ),
          GestureDetector(
            onTap: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
            child: Container(
              alignment: Alignment.center,
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, 
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                Theme.of(context).brightness == Brightness.light ? "Lightmode" : "Darkmode",
                style: const TextStyle(
                  fontSize: 20
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signOutButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
      ),
      onPressed: (){
        setState(() {
          AuthService().signOut().then((value) => {
            Navigator.pop(context)
          });
        });
      },
      child: const Text(
        "Abmelden",
        style: TextStyle(
          color: Colors.white
        ),
      ),
    );
  }

  Widget userNameInfo(){
    return Text(
      userNameInfoString,
      style: TextStyle(
        color: isUserNameAvailable ? Colors.green : Colors.red
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            _profileImage(),
            entryField(
              context, 
              300, 
              50, 
              EdgeInsets.zero, 
              "Neuer Benutzername", 
              _usernameController, 
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              onChanged: (value) {
                userDataManager.getIsUsernameInUse(value).then((isInUse) {
                  setState(() {
                    if (value == widget.user.username){
                    userNameInfoString = "Dies ist dein aktueller Benutzername.";
                    isUserNameAvailable = true;
                  }else if (isInUse){
                    userNameInfoString = "Dieser Benutzername ist bereits in Verwendung.";
                    isUserNameAvailable = false;
                  }else{
                    userNameInfoString = "Dieser Benutzername ist verfügbar.";
                    isUserNameAvailable = true;
                    /*
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Dieser Benutzername ist bereits vergeben"),
                      )
                    );
                    */
                  }
                  });
                });
              }
            ),
            userNameInfo(),
            _darkModeSwitch(),
            _signOutButton()
          ]
        ),
      )
    );
  }
}
