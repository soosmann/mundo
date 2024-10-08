import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/location.dart';
import 'package:mundo/models/user.dart';
import 'package:uuid/uuid.dart';

/// class that manages data traffic with Firebase related to Mundo Users
class UserDataManager{
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirebaseStorage storage = FirebaseStorage.instance;

  /// save a new user to the Firestore Db
  bool saveUser(String email, String username){
    final Map<String, dynamic> dataJson = <String, dynamic>{
      "email": email,
      "username": username,
      "posts": 0,
      "followers": 0,
      "following": 0,
    };
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      db.collection("users").doc(currentUserId).set(dataJson);
      return true;
    } else {
      return false;
    }
  }

  /// delete the current user from the Firestore Db\
  /// currently not in use!!!
  bool deleteCurrentUsersAccount(){
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      db.collection("users").doc(currentUserId).delete();
      return true;
    } else {
      return false;
    }
  }

  /// update the username of the current user
  bool updateUsername(String username){
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      db.collection("users").doc(currentUserId).update({"username": username});
      return true;
    } else {
      return false;
    }
  }

  /// Checks if a username is already in use\
  /// true = in use, false = not in use
  Future<bool> getIsUsernameInUse(String username) async {
    final result = await db.collection("users").where("username", isEqualTo: username).get();
    return result.docs.isNotEmpty;
  }

  /// get the user data of the current user
  Future<MundoUser> getUserData() async {
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      final result = await db.collection("users").doc(currentUserId).get();
      return MundoUser.fromFirebaseDoc(result);
    } else {
      return MundoUser(id: "", email: "", username: "", profilePictureUrl: "", postCount: 0, followerCount: 0, followingCount: 0);
    }
  }

  /// get the user data of a user by their user id
  Future<MundoUser> getMundoUserById(String userId) async {
    String? currentUserId = _authService.currentUser?.uid;
    if (currentUserId != null) {
      final result = await db.collection("users").doc(userId).get();
      return MundoUser.fromFirebaseDoc(result);
    } else {
      return MundoUser(id: "", email: "", username: "", profilePictureUrl: "", postCount: 0, followerCount: 0, followingCount: 0);
    }
  }

  /// save the profile image of the current user to Firebase Storage and update the user document in Firestore
  Future<bool> saveProfileImage(File image, SettableMetadata metadata) async {
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null) {
      final ref = storage.ref().child("profile_pictures").child(currentUserId);
      UploadTask uploadTask = ref.putFile(image, metadata);
      
      await uploadTask.whenComplete(() {
        getProfileImageUrlOfUser(currentUserId).then((imageUrl) {
          if (imageUrl.isNotEmpty) {
            db.collection("users").doc(currentUserId).set(
              {"picture": imageUrl}, 
              SetOptions(merge: true)
            );
          }     
        });
      });
      return true;
    } else {
      return false;
    }
  }

  /// save the location of the current user to Firestore
  bool saveUsersLocation(MundoLocation location){
    String? currentUserId = _authService.currentUser?.uid;

    Map<String, dynamic> dataJson = <String, dynamic>{
      "loc": {
        "gMapsId": location.googleMapsId,
        "city": location.city,
        "region": location.region,
        "lat": location.coordinates.latitude,
        "lng": location.coordinates.longitude
      }
    };

    if (currentUserId != null) {
      db.collection("users").doc(currentUserId).update(dataJson);
      return true;
    } else {
      return false;
    }
  }

  /// get the profile image url of a user by their user id\
  /// needed to update the Firebase Doc of the user by the users profile pic url
  Future<String> getProfileImageUrlOfUser(String userId) async {
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null) {
      try{
        final ref = storage.ref().child("profile_pictures").child(userId);
        String url = await ref.getDownloadURL();
        return url.isNotEmpty ? url : "";
      } on FirebaseException catch (e) {
        if (e.code == "object-not-found") {
          throw Exception("Error: $e");
        }
        throw Exception("Error: $e");
      }
    } else {
      throw Exception("Error: User not logged in");
    }
  }

  /// Searches for usernames that start with "query"
  /// Returns list of Mundo users bassed on returned Firebase Documents 
  Future<List<MundoUser>> searchUserNames(String query) async {
    final result = await db
      .collection("users")
      .where("username", isGreaterThanOrEqualTo: query)
      .where("username", isLessThanOrEqualTo: "$query\uf8ff") // \uf8ff performs the "starts with"
      .get();

    List<MundoUser> mundoUsers = [];

    for (var doc in result.docs) {
      mundoUsers.add(MundoUser.fromFirebaseDoc(doc));
    }
    return mundoUsers;
  }

  /// Follows a user by their user id
  bool followUser(String idOfFollowedUser){
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null) {
      final Map<String, dynamic> dataJson = <String, dynamic>{
        "userid": currentUserId,
        "follows": idOfFollowedUser
      };
      db.collection("follows").doc(const Uuid().v4()).set(dataJson);
      incrementFollowerCount(idOfFollowedUser);
      return true;
    } else {
      return false;
    }
  }

  /// Unfollows a user by their user id
  bool unfollowUser(String idOfUnfollowedUser){
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null) {
      db.collection("follows").where("userid", isEqualTo: currentUserId).where("follows", isEqualTo: idOfUnfollowedUser).get().then((value) {
        for (var doc in value.docs) {
          db.collection("follows").doc(doc.id).delete();
        }
      });
      decrementFollowerCount(idOfUnfollowedUser);
      return true;
    } else {
      return false;
    }
  }

  /// Increments the follower count of the user with the given id
  /// Increments the following count of the current user
  void incrementFollowerCount(String ifOfFollowedUser){
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null){
      db.collection("users").doc(ifOfFollowedUser).update({"followers": FieldValue.increment(1)});
      db.collection("users").doc(currentUserId).update({"following": FieldValue.increment(1)});
    }
  }

  /// Decrements the follower count of the user with the given id
  /// Decrements the following count of the current user
  void decrementFollowerCount(String ifOfUnfollowedUser){
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null){
      db.collection("users").doc(ifOfUnfollowedUser).update({"followers": FieldValue.increment(-1)});
      db.collection("users").doc(currentUserId).update({"following": FieldValue.increment(-1)});
    }
  }

  /// Checks if the current user is following the user with the given id
  Future<bool> isUserFollowing(String userId) async {
    String? currentUserId = _authService.currentUser?.uid;

    if (currentUserId != null) {
      final result = await db.collection("follows").where("userid", isEqualTo: currentUserId).where("follows", isEqualTo: userId).get();
      if (result.docs.length == 1){
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// Returns a list of users that are following the user with the given id
  Future<List<MundoUser>> getFollowers(String userId) async {
    final result = await db.collection("follows").where("follows", isEqualTo: userId).get();
    List<MundoUser> followers = [];

    for (var doc in result.docs) {
      final result = await db.collection("users").doc(doc["userid"]).get();
      followers.add(MundoUser.fromFirebaseDoc(result));
    }
    return followers;
  }
  
  /// Returns a list of users that the user with the given id is following
  Future<List<MundoUser>> getFollowings(String userId) async {
    final result = await db.collection("follows").where("userid", isEqualTo: userId).get();
    List<MundoUser> following = [];

    for (var doc in result.docs) {
      final result = await db.collection("users").doc(doc["follows"]).get();
      following.add(MundoUser.fromFirebaseDoc(result));
    }
    return following;
  }
}
