import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/user.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/post_view.dart';
import 'package:mundo/pages/show_followers.dart';
import 'package:mundo/pages/show_followings.dart';

class OtherProfileView extends StatefulWidget{
  final MundoUser user;
  const OtherProfileView({super.key, required this.user});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  final UserDataManager userDataManager = UserDataManager();
  final PostDataManager postDataManager = PostDataManager();

  List<Post>? posts;
  bool? isUserFollowing;

  /// get if the current user is following the user of this profile and the users posts
  @override
  void initState(){
    super.initState();
    userDataManager.isUserFollowing(widget.user.id).then((value) => {setState(() => isUserFollowing = value)});
    postDataManager.getPostsByUserId(widget.user.id).then((value) => {setState(() => posts = value)});
  }

  /// profile headline including back button, username, location
  Widget profileHeadline(){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.chevron_left,
              size: 35,
            ),
          ),
          Text(
            widget.user.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          widget.user.location != null 
            ? Text(
                ", ${widget.user.location!.city}",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 25
                ),
              ) 
            : const SizedBox(height: 0),
          const Spacer(),
        ],
      ),
    );
  }

  /// profile header including profile picture, post count, follower count, following count\
  /// button to follow or unfollow the user
  Widget profileHeader(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          roundProfileImage(context, widget.user.profilePictureUrl, 80, 80),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      "Posts",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowersView(userId: widget.user.id))),
                      child: const Text(
                        "Follower",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowingsView(userId: widget.user.id))),
                      child: const Text(
                        "Folgt",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    ),
                  ]
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      widget.user.postCount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowersView(userId: widget.user.id))),
                      child: Text(
                        widget.user.followerCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowingsView(userId: widget.user.id))),
                      child: Text(
                        widget.user.followingCount.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    )
                  ]
                ),
                const SizedBox(height: 5),
                isUserFollowing == false 
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              bool success = userDataManager.followUser(widget.user.id);
                              if (success) isUserFollowing = true;
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue, 
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: const Text(
                              "Folgen",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            )
                          ),
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              bool success = userDataManager.unfollowUser(widget.user.id);
                              if (success) isUserFollowing = false;
                            });
                            
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width/2,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.blue, 
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: const Text(
                              "Entfolgen",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,//Theme.of(context).textTheme.labelLarge!.color,
                              ),
                            )
                          ),
                        )
                      ],
                    )
              ],
            ),
          ),
        ],
      ),  
    );
  }

  /// divider between profile header and posts
  Widget profileDivider(){
    return const Divider(
      color: Colors.grey,
    );
  }

  /// post field including image, title, location
  Widget postField(
    Post post,
  ){
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostView(post: post, user: widget.user, isOwnPost: false))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: MediaQuery.of(context).size.width - 10,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 10,
                  height: MediaQuery.of(context).size.width - 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      post.postElements[post.mainImageIndex!].imageFile,
                      fit: BoxFit.cover,
                    )
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 10,
                    child: Text(
                      post.title,
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(3),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 10,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.black,
                        ),
                        Text(
                          "${post.location!.city}, ${post.location!.region}",
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  /// list to invoke postFields
  Widget postFieldList(){
    if (posts == null || posts!.isEmpty){
      return const Text("Keine Posts vorhanden");
    }else{
      return Column(
        children: posts!.map((post) => postField(post)).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              profileHeadline(),
              profileHeader(),
              profileDivider(),
              postFieldList(),
            ],
          ),
        ),
      ),
    );
  }
}
