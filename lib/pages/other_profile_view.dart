import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:mundo/pages/post_view.dart';

class OtherProfileView extends StatefulWidget{
  final MundoUser user;
  const OtherProfileView({super.key, required this.user});

  @override
  State<OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<OtherProfileView> {
  final UserDataManager userDataManager = UserDataManager();
  final PostDataManager postDataManager = PostDataManager();

  String profilePictureUrl = "";
  List<Post>? posts;
  bool? isUserFollowing;

  @override
  void initState(){
    super.initState();
    userDataManager.getProfileImageUrlOfUser(widget.user.id).then((value) => {setState(() => profilePictureUrl = value)});
    userDataManager.isUserFollowing(widget.user.id).then((value) => {setState(() => isUserFollowing = value)});
    postDataManager.getPostsByUserId(widget.user.id).then((value) => {setState(() => posts = value)});
  }

  Widget profileHeadline(){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          GestureDetector(
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
          const Text(
            ", Dörentrup",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 25
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget profileHeader(){
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          roundProfileImage(context, widget.user.profilePictureUrl, 80, 80),
          Expanded(
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     Text(
                      "Posts",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      "Follower",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    Text(
                      "Folgt",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
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
                    Text(
                      widget.user.followerCount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    Text(
                      widget.user.followingCount.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
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
                                color: Colors.white,//Theme.of(context).textTheme.labelLarge!.color,
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

  Widget profileDivider(){
    return const Divider(
      color: Colors.grey,
    );
  }

  Widget postField(
    Post post,
  ){
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostView(post: post))
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: SizedBox(
          width: 335,
          height: 335,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.file(
                  post.postElements[post.mainImageIndex!].imageFile,
                  fit: BoxFit.fitHeight,
                )
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }

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
