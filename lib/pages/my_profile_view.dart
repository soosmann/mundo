import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:flutter_inset_box_shadow/flutter_inset_box_shadow.dart';
import 'package:mundo/pages/post_view.dart';
import 'package:mundo/pages/profile_settings.dart';
import 'package:mundo/pages/select_post_location.dart';
import 'package:mundo/pages/show_followers.dart';
import 'package:mundo/pages/show_followings.dart';

class MyProfileView extends StatefulWidget{
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final UserDataManager userDataManager = UserDataManager();
  final PostDataManager postDataManager = PostDataManager();
  MundoUser? user;
  List<Post>? posts;

  @override
  void initState(){
    super.initState();
    userDataManager.getUserData().then((value) => {setState(() => user = value)});
    //userDataManager.getProfileImageUrlOfUser(AuthService().currentUser!.uid).then((value) => {setState(() => profilePictureUrl = value)});
    postDataManager.getPostsByUserId(AuthService().currentUser!.uid).then((value) => {setState(() => posts = value)});
  }

  Future<void> signOut() async {
    await AuthService().signOut();
  }

  Widget profileHeadline(){
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(
        children: [
          Text(
            user?.username ?? "username",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          user?.location != null 
            ? Text(
                ", ${user!.location!.city}",
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 25
                ),
              ) 
            : const SizedBox(height: 0),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (user != null){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => ProfileSettingsView(user: user!))
                );
              }
            },
            child: Container(
              height: 35, 
              width: 35,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, 
                borderRadius: BorderRadius.circular(5)
              ),
              child: const Icon(Icons.settings)
            ),
          ), 
        ],
      ),
    );
  }

  Widget profileHeader(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 10),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (user != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSettingsView(user: user!)));
            },
            child: roundProfileImage(context, user?.profilePictureUrl, 100, 100),
          ),
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
                      onTap: () {
                        if (user != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowersView(userId: user!.id)));
                      },
                      child: const Text(
                        "Follower",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (user != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowingsView(userId: user!.id)));
                      },
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
                      user?.postCount.toString() ?? "0",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (user != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowersView(userId: user!.id)));
                      },
                      child: Text(
                        user?.followerCount.toString() ?? "0",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (user != null) Navigator.push(context, MaterialPageRoute(builder: (context) => ShowFollowingsView(userId: user!.id)));
                      },
                      child: Text(
                        user?.followingCount.toString() ?? "0",
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 20
                        ),
                      ),
                    )
                  ]
                ),
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
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostView(post: post, user: user, isOwnPost: true))),
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
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).textTheme.labelLarge!.color,
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

  Widget postFieldList(){
    if (posts == null || posts!.isEmpty){
      return const Text("Keine Posts vorhanden");
    }else{
      return Column(
        children: posts!.map((post) => postField(post)).toList(),
      );
    }
  }

  Widget createPostFloatingButton(){
    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectPostLocationView())
        );
      },
      child: Icon(
        Icons.add,
        color: Theme.of(context).floatingActionButtonTheme.foregroundColor
      ),
    );
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
      floatingActionButton: createPostFloatingButton(),
    );
  }
}
