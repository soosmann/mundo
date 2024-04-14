import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/other_profile_view.dart';
import 'package:mundo/pages/post_view.dart';

class MapView extends StatefulWidget{
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>{
  PostDataManager postDataManager = PostDataManager();
  UserDataManager userDataManager = UserDataManager();

  int postIndex = 0;
  MundoUser? currentPostsOwner;

  List<Post> posts = [];

  /// retrieves posts for the current user and sets the first post\
  /// download data of current user to show profile image
  @override
  void initState() {
    super.initState();
    postDataManager.getPostsForFyPage(AuthService().currentUser!.uid, DateTime.now().millisecondsSinceEpoch).then((value) => setState(() {
      posts.addAll(value);
      if (posts.isNotEmpty){
        userDataManager.getMundoUserById(posts[postIndex].ownerId).then((value) => setState(() => currentPostsOwner = value));
      }
    }));
  }

  /// shows big main image
  Widget postMainImage(){
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostView(post: posts[postIndex], isOwnPost: false))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.width-10, // padding 2*5 = 10
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: posts.isEmpty
              ? Icon(
                  Icons.image,
                  size: MediaQuery.of(context).size.width-10,
                  color: Theme.of(context).colorScheme.secondary,
                )
              : Image.file(
                  posts[postIndex].postElements[posts[postIndex].mainImageIndex!].imageFile,
                  fit: BoxFit.cover,
                )
          ),
        ),
      ),
    );
  }

  /// placeholder for main image
  Widget postMainImagePlaceholder(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width-10, // padding 2*5 = 10
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).colorScheme.primary,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            Icons.image,
              size: MediaQuery.of(context).size.width-10,
              color: Theme.of(context).colorScheme.secondary,
            )
        ),
      ),
    );
  }
  
  /// displays the posts name
  Widget postInfoText(){
    return Container(
      width: MediaQuery.of(context).size.width-60, // image circle diameter = 50, and padding 2 * 5 = 10
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        posts[postIndex].title,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 20
        )
      ),
    );
  }

  /// placeholder for post info string
  Widget postInfoTextPlaceholder(){
    return Container(
      width: MediaQuery.of(context).size.width-60, // image circle diameter = 50, and padding 2 * 5 = 10
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        "",
        textAlign: TextAlign.start,
        style: TextStyle(
          fontSize: 20
        )
      ),
    );
  }

  /// row that combines the users profile image with the post name
  Widget profileImageAndText(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileView(user: currentPostsOwner!))),
            child: roundProfileImage(context, currentPostsOwner?.profilePictureUrl, 50, 50)
          ),
          postInfoText(),
        ],
      ),
    );
  }

  /// row that combines placeholders for user image and post name
  Widget profileImageAndTextPlaceholder(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Row(
        children: [
          roundProfileImage(context, currentPostsOwner?.profilePictureUrl, 50, 50),
          postInfoTextPlaceholder(),
        ],
      ),
    );
  }

  /// show the post location on the map\
  /// contains buttons to navigate through the posts\
  /// when the second last post is reached, more posts are loaded based on the timestamp of the oldest retrieved post
  Widget postLocationMap() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [ 
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: FlutterMap(
                  key: UniqueKey(), // by always using a new unique key everytime, the widget seems completely new to Flutter and is rebuild -> allows map recentering
                  options: MapOptions(
                    initialCenter: posts[postIndex].location!.coordinates,
                    initialZoom: 5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          width: 50,
                          height: 50,
                          point: posts[postIndex].location!.coordinates,
                          child: roundProfileImage(context, currentPostsOwner?.profilePictureUrl, 50, 50)
                        )
                      ],
                    )
                  ],
                )
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        if (postIndex > 0){
                          setState(() {
                            postIndex--;
                            if (posts.isNotEmpty){
                              userDataManager.getMundoUserById(posts[postIndex].ownerId)
                                .then((value) => setState(() => currentPostsOwner = value));
                            }
                          });
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        if (postIndex < posts.length-1){
                          setState(() {
                            postIndex++;
                            if (posts.isNotEmpty){
                              userDataManager.getMundoUserById(posts[postIndex].ownerId)
                                .then((value) => setState(() => currentPostsOwner = value));
                            }
                            if (postIndex == posts.length-2){
                              postDataManager.getPostsForFyPage(AuthService().currentUser!.uid, posts.last.creationUnixTimeStamp).then((value) {
                                posts.addAll(value);
                              });
                            }
                          });
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_right
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }

  /// placeholder for post location map
  Widget postLocationMapPlaceholder(){
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [ 
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Center(
                      child: Icon(
                        Icons.map, 
                        size: MediaQuery.of(context).size.width*0.5, 
                        color: Theme.of(context).colorScheme.secondary
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        if (postIndex > 0){
                          setState(() {
                            postIndex--;
                            if (posts.isNotEmpty){
                              userDataManager.getMundoUserById(posts[postIndex].ownerId)
                                .then((value) => setState(() => currentPostsOwner = value));
                            }
                          });
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_left
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipOval(
                  child: Material(
                    color: Colors.blue,
                    child: InkWell(
                      onTap: () {
                        if (postIndex < posts.length-1){
                          setState(() {
                            postIndex++;
                            if (posts.isNotEmpty){
                              userDataManager.getMundoUserById(posts[postIndex].ownerId)
                                .then((value) => setState(() => currentPostsOwner = value));
                            }
                          });
                        }
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.chevron_right
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ]
          ),
        ),
      ),
    );
  }
  /// TODO: message user to follow users with posts if user doesnt follow users (with posts)
  /// build this view depending if posts are available or not
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: posts.isEmpty
        ? Column(
            children: [
              postMainImagePlaceholder(),
              profileImageAndTextPlaceholder(),
              postLocationMapPlaceholder(),
            ],
          )
        : Column(
            children: [
              postMainImage(),
              profileImageAndText(),
              postLocationMap(),
            ]
          )
      ),
    );
  }
}