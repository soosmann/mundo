import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/location.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/pages/select_user_location_settings.dart';
import 'package:mundo/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/user.dart';

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
  MundoLocation? newUserLocation;

  String userNameInfoString = "Dies ist dein aktueller Benutzername";
  bool isUserNameAvailable = true;

  /// func to load new possible profile picture
  Future selectImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedImage == null) return;
      setState(() {
        newProfilePicture = File(pickedImage.path);
      });
    } on PlatformException catch(e) {
      throw Exception('Failed to pick image: $e');
    }
  }
  /// set current username in change username field
  @override
  void initState(){
    super.initState();
    _usernameController.text = widget.user.username;
  }

  /// app bar with title and save button\
  /// check if profile params where change, if so, update them
  Widget _appBar() {
    return AppBar(
      title: const Text("Einstellungen"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.done),
          onPressed: () async {
            if (_usernameController.text != widget.user.username && isUserNameAvailable){
              userDataManager.updateUsername(_usernameController.text);
            }
            if ((newUserLocation != null) && (newUserLocation != widget.user.location)){
              userDataManager.saveUsersLocation(newUserLocation!);
            }
            if (newProfilePicture != null){
              //bool uploadSuccess = await userDataManager.saveProfileImage(
              await userDataManager.saveProfileImage(
                newProfilePicture!, 
                SettableMetadata(
                  contentType: 'image/jpeg',
                  customMetadata: {'picked': 'image'}
                )
              );
            }
            setState(() => Navigator.pop(context));
          },
        ),
      ],
    );
  }

  /// show current profile pic or changed profile pic
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

  /// switch for switching between light and dark mode
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

  /// button to get to the change user location view
  Widget _locationChangeOption(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Location",
            style: TextStyle(fontSize: 20),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => SelectUserLocationSettingsView(
                  user: widget.user,
                  onLocationSelected: (selectedLocation) => setState(() => newUserLocation = selectedLocation)
                  )
                )
              );
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
                newUserLocation != null 
                  ? newUserLocation!.city
                  : widget.user.location != null ? widget.user.location!.city : "Ort wählen",
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

  /// button to sign out the user
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
  // TODO: implement delete acc
  /*
  Widget _deleteAccountButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
      ),
      onPressed: (){
        setState(() {
          if (AuthService().currentUser != null){
            AuthService().currentUser!.delete().then((value) => {
              setState(() => UserDataManager().deleteCurrentUsersAccount())
              //Navigator.pop(context)
            });
          }
        });
      },
      child: const Text(
        "Account löschen",
        style: TextStyle(
          color: Colors.white
        ),
      ),
    );
  }
  */
  /// shows information about chosen username (available, in use, current username)
  Widget _userNameInfo(){
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
                  }
                  });
                });
              }
            ),
            _userNameInfo(),
            _darkModeSwitch(),
            _locationChangeOption(),
            _signOutButton(),
            //_deleteAccountButton()
          ]
        ),
      )
    );
  }
}
