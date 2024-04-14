import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/home.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/user.dart';

class PostPreviewView extends StatefulWidget {
  final Post post;

  const PostPreviewView({super.key, required this.post});

  @override
  State<PostPreviewView> createState() => _PostPreviewView();
}

class _PostPreviewView extends State<PostPreviewView> {
  final PostDataManager postDataManager = PostDataManager();

  MundoUser? user;

  bool isMapExpanded = false;

  /// get user data to display profile image
  @override
  void initState() {
    super.initState();
    UserDataManager().getUserData().then((value) => setState(() => user = value));
  }

  /// detects if post button was pressed, to avoid multiple posts
  final buttonPressedNotifier = ValueNotifier<bool>(false);
  /// app bar with title and post Post button
  Widget _appBar() {
    return AppBar(
      title: Text(widget.post.title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: buttonPressedNotifier,
          builder: (context, buttonPressed, child) {
            return IconButton(
              icon: const Icon(Icons.done),
              onPressed: buttonPressed ? null : () async {
                buttonPressedNotifier.value = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post wurde hochgeladen.')),
                );
                postDataManager.addPost(widget.post).then((value) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeView()),
                    (route) => false,
                  );
                });
              },
            );
          },
        ),
      ],
    );
  }

  /// display post title
  Widget _postTitle(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Container(
        width: MediaQuery.of(context).size.width-10, // left and right padding: 2*5=10
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: roundProfileImage(context, user?.profilePictureUrl, 40, 40)),
            Expanded(
              child: Text(
                widget.post.title, 
                style: const TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold
                ),
                softWrap: true,
                maxLines: 2,
              ),
            ),
          ]
        )
      )
    );
  }

  /// display location information and expandable map icon
  Widget _locationInfo(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Row(
        children: [
          const Icon(Icons.location_on),
          const SizedBox(width: 5),
          Text(
            "${widget.post.location!.city}, ${widget.post.location!.region}", 
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold
            )
          ),
          InkWell(
            onTap:() => setState(() {
              isMapExpanded = !isMapExpanded;
            }),
            child: Icon(
              isMapExpanded ? Icons.expand_less : Icons.expand_more
            ),
          ),
        ]
      )
    );
  }

  /// display map with post location
  Widget _positionMap() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: MediaQuery.of(context).size.width-20, // left and right padding: 2*10=20
          height: MediaQuery.of(context).size.height*0.3,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: widget.post.location!.coordinates,
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
                        point: widget.post.location!.coordinates,
                        child: roundProfileImage(context, user!.profilePictureUrl, 50, 50)
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// display post content
  Widget _postContent(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var postElement in widget.post.postElements)
          if (postElement is PostText)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 2), 
              child: Container(
                width: MediaQuery.of(context).size.width-10, // left and right padding: 2*5=10
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(postElement.text),
              )
            )
          else if (postElement is PostImage)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
              child: Container(
                width: MediaQuery.of(context).size.width-10,
                height: MediaQuery.of(context).size.width-10,
                decoration: postElement.isMainImage 
                  ? BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 5,
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ) 
                  : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), // border radius different because image lays on top of border
                  child: Image.file(
                    postElement.imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appBar(),
              _postTitle(),
              _locationInfo(),
              (isMapExpanded && user != null) ? _positionMap() : const SizedBox(height: 0),
              _postContent(),
          ]
        ),
        )
      )
    );
  }
}
