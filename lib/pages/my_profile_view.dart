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
            "${user?.username ?? "username"}, ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const Text(
            "Dörentrup",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 25
            ),
          ),
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
          roundProfileImage(context, user?.profilePictureUrl, 100, 100),
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
                      user?.postCount.toString() ?? "0",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    Text(
                      user?.followerCount.toString() ?? "0",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
                      ),
                    ),
                    Text(
                      user?.followingCount.toString() ?? "0",
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 20
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
