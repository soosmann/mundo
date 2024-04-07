import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:mundo/models/location.dart';

class MundoUser{
  final String id;
  final String email;
  final String username;
  final String? profilePictureUrl;
  final int postCount;
  final int followerCount;
  final int followingCount;
  MundoLocation? location;
  
  MundoUser({
    required this.id, 
    required this.email, 
    required this.username, 
    this.profilePictureUrl,
    required this.postCount, 
    required this.followerCount,
    required this.followingCount,
    this.location});

  factory MundoUser.fromFirebaseDoc(DocumentSnapshot<Map<String, dynamic>> doc){
    final data = doc.data()!;
    if (data["loc"] == null){
      return MundoUser(
        id: doc.id,
        email: data["email"],
        username: data["username"],
        profilePictureUrl: data["picture"],
        postCount: data["posts"],
        followerCount: data["followers"],
        followingCount: data["following"],
        location: null
      );
    }else{
      return MundoUser(
        id: doc.id,
        email: data["email"],
        username: data["username"],
        profilePictureUrl: data["picture"],
        postCount: data["posts"],
        followerCount: data["followers"],
        followingCount: data["following"],
        location: MundoLocation(
          googleMapsId: data["loc"]["gMapsId"],
          city: data["loc"]["city"],
          region: data["loc"]["region"],
          coordinates: LatLng(data["loc"]["lat"], data["loc"]["lng"])
        )
      );
    }
  }

  void changeLocation(MundoLocation newLocation){
    location = newLocation;
  }
}