import 'package:flutter/material.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/home.dart';
import 'package:flutter_map/flutter_map.dart';

class PostPreviewView extends StatelessWidget {
  final Post post;

  PostPreviewView({super.key, required this.post});

  final UserDataManager userDataManager = UserDataManager();
  final PostDataManager postDataManager = PostDataManager();

  Widget _appBar(BuildContext context) {
    return AppBar(
      title: Text(post.title),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.done),
          onPressed: () async {
            postDataManager.addPost(post).then((value) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeView()),
                (route) => false,
              );
            });
          },
        ),
      ],
    );
  }

  Widget postTitle(BuildContext context){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Container(
        width: MediaQuery.of(context).size.width-10, // left and right padding: 2*5=10
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: Text(
          post.title, 
          style: const TextStyle(
            fontSize: 30, 
            fontWeight: FontWeight.bold
          )
        ),
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
                  initialCenter: post.location,
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
                        point: post.location,
                        child: const FlutterLogo()//profileImage()
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
        for (var postElement in post.postElements)
          if (postElement is PostText)
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 2), 
              child: Container(
                width: MediaQuery.of(context).size.width-10, // left and right padding: 2*5=10
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
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
                      borderRadius: BorderRadius.circular(25), // TODO: Why do borders not have equal radius?
                    ) 
                  : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
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
              postTitle(context),
              positionMap(context),
              _postContent(context),
          ]
        ),
        )
      )
    );
  }
}
