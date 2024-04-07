import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/post_data_manager.dart';

class PostView extends StatefulWidget {
  final Post post; 
  final MundoUser? user;
  final bool isOwnPost;

  const PostView({super.key, required this.post, this.user, required this.isOwnPost});

  @override
  State<PostView> createState() => _PostView();
}

class _PostView extends State<PostView> {
  MundoUser? user;
  bool isMapExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.user != null ? user = widget.user : UserDataManager().getUserData().then((value) => setState(() => user = value));
  }

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text(widget.post.title),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _postTitle(BuildContext context){
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
            if (widget.isOwnPost)
            IconButton(
              onPressed: (){
                PostDataManager().deletePost(widget.post.id)
                  .then((value) => Navigator.pop(context));
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red
              )
            )
          ],
        ),
      )
    );
  }

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

  Widget positionMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
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
                        child: roundProfileImage(context, user?.profilePictureUrl, 50, 50)
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

  Widget _postContent(BuildContext context){
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
              _appBar(context),
              _postTitle(context),
              _locationInfo(),
              isMapExpanded ? positionMap(context) : const SizedBox(height: 0),
              _postContent(context),
            ]
          ),
        ),
      )
    );
  }
}
