import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';


class MapView extends StatefulWidget{
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView>{
  int postIndex = 0;

  List<Post> posts = [];
  
  @override
  void initState() {
    super.initState();
    PostDataManager().getPostsByUserId(AuthService().currentUser!.uid).then((value)=> setState(() => posts = value));
    //loadPosts();
  }
  
  /*
  void loadPosts() async {
    try {
      // Fetch the list of posts
      List<Post> fetchedPosts = await PostDataManager().getPostsByUserId(AuthService().currentUser!.uid);
      setState(() {
        posts = fetchedPosts; // Update the local variable with the fetched posts
      });
    } catch (error) {
      // Handle errors
      print('Error loading posts: $error');
    }
  }
  */

  Widget postMainImage(){
    return Padding(
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
    );
  }

  Widget postMainImagePlaceholder(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width-10, // padding 2*5 = 10
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
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

  Widget profileImage(){
    return SizedBox(
      width: 50,
      height: 50,
      child: ClipOval(
        child: Image.asset(
          "assets/images/marcel_profile.jpg",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget profileImagePlaceholder(){
    return const SizedBox(
      width: 50,
      height: 50,
      child: ClipOval(
        child: Icon(
          Icons.person
        )
      ),
    );
  }
  
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

  Widget profileImageAndText(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Row(
        children: [
          profileImage(),
          postInfoText(),
        ],
      ),
    );
  }

  Widget profileImageAndTextPlaceholder(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Row(
        children: [
          profileImagePlaceholder(),
          postInfoTextPlaceholder(),
        ],
      ),
    );
  }

  Widget mundoMap() {
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
                    initialCenter: posts[postIndex].location,
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
                          point: posts[postIndex].location,
                          child: profileImage()
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

  Widget mundoMapPlaceholder(){
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
              mundoMapPlaceholder(),
            ],
          )
        : Column(
            children: [
              postMainImage(),
              profileImageAndText(),
              mundoMap(),
            ]
          )
      ),
    );
  }
}