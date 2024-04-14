import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/models/user.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/pages/other_profile_view.dart';

class ShowFollowingsView extends StatefulWidget {
  final String userId;
  const ShowFollowingsView({Key? key, required this.userId}) : super(key: key);

  @override
  State<ShowFollowingsView> createState() => _ShowFollowingsView();
}

class _ShowFollowingsView extends State<ShowFollowingsView> {
  TextEditingController searchInputController = TextEditingController();

  UserDataManager userDataManager = UserDataManager();

  List<MundoUser> followedUsers = [];
  List<MundoUser> shownUsers = [];

  /// retrieve following users of current user
  @override
  void initState(){
    super.initState();
    userDataManager.getFollowings(widget.userId)
      .then((value) => {setState(() {
        followedUsers = value;
        shownUsers = value;
      })});
  }

  /// search users based on string in the textfield
  List<MundoUser> _searchUsers(String value){
    if (value == ""){
      return followedUsers;
    }
    List<MundoUser> foundUsers = [];
    for (MundoUser user in followedUsers){
      if (user.username.contains(value)){
        foundUsers.add(user);
      }
    }
    return foundUsers;
  }

  /// app bar with title
  Widget _appBar() {
    return AppBar(
      title: const Text("Du folgst"),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  /// shows list of followed users
  Widget _followedUsersList(){
    return Expanded(
        child: ListView.builder(
          itemCount: shownUsers.length,
          itemBuilder: (context, index){
            return ListTile(
              title: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileView(user: followedUsers[index]))),
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
              MediaQuery.of(context).size.width-20, 
              MediaQuery.of(context).size.height*0.06, 
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