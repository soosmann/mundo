import 'package:cloud_firestore/cloud_firestore.dart';

class MundoUser{
  final String id;
  final String email;
  final String username;
  final String? profilePictureUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  
  MundoUser({
    required this.id, 
    required this.email, 
    required this.username, 
    this.profilePictureUrl,
    required this.postCount, 
    required this.followerCount,
    required this.followingCount});

  factory MundoUser.fromFirebaseDoc(DocumentSnapshot<Map<String, dynamic>> doc){
    final data = doc.data()!;
    return MundoUser(
      id: doc.id,
      email: data["email"],
      username: data["username"],
      profilePictureUrl: data["picture"],
      postCount: data["posts"],
      followerCount: data["followers"],
      followingCount: data["following"]
    );
  }
}