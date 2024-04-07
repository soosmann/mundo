import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/pages/other_profile_view.dart';

class ShowFollowersView extends StatefulWidget {
  final String userId;
  const ShowFollowersView({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShowFollowersView> createState() => _ShowFollowersView();
}

class _ShowFollowersView extends State<ShowFollowersView> {
  TextEditingController searchInputController = TextEditingController();

  UserDataManager userDataManager = UserDataManager();

  List<MundoUser> followers = [];
  List<MundoUser> shownUsers = [];

  @override
  void initState(){
    super.initState();
    userDataManager.getFollowers(widget.userId)
      .then((value) => {setState(() {
        followers = value;
        shownUsers = value;
      })});
  }

  List<MundoUser> _searchUsers(String value){
    if (value == ""){
      return followers;
    }
    List<MundoUser> foundUsers = [];
    for (MundoUser user in followers){
      if (user.username.contains(value)){
        foundUsers.add(user);
      }
    }
    return foundUsers;
  }

  Widget _appBar() {
    return AppBar(
      title: const Text("Deine Follower"),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _followedUsersList(){
    return Expanded(
        child: ListView.builder(
          itemCount: shownUsers.length,
          itemBuilder: (context, index){
            return ListTile(
              title: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileView(user: followers[index]))),
                child: Row(
                  children: [
                    roundProfileImage(context, shownUsers[index].profilePictureUrl, 50, 50),
                    const SizedBox(width: 10,),
                    Text(shownUsers[index].username),
                  ],
                ),
              ),
            );
          }
        ),
      
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            entryField(
              context, 
              380, 
              50, 
              const EdgeInsets.fromLTRB(0, 10, 0, 10), 
              "Gefolgte Accounts durchsuchen", 
              searchInputController, 
              1,
              onChanged: (value) => setState(() => shownUsers = _searchUsers(value)),
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5)
            ),
            _followedUsersList()
          ]
        ),
      )
    );
  }
}