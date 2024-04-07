import 'package:flutter/material.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/location_view.dart';
import 'package:mundo/pages/other_profile_view.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:mundo/models/location.dart';

class SearchView extends StatefulWidget{
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>{
  final TextEditingController _searchController = TextEditingController();

  final UserDataManager userDataManager = UserDataManager();
  final LocationDataManager locationDataManager = LocationDataManager();

  List<MundoUser> foundUsers = [];
  List<MundoLocationWithoutCoordinates> foundLocations = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() =>_onSearchTextChanged(_searchController.text));
  }

  @override
  void dispose() {
    _searchController.removeListener(() =>_onSearchTextChanged(_searchController.text));
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged(String value) async {
    if (value != ""){
      List<MundoUser> retrievedUsers = await UserDataManager().searchUserNames(value);
      setState(() {
        foundUsers = retrievedUsers;
      });
    }
  }

  Widget _searchTile(IconData icon, String title){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: MediaQuery.of(context).size.width*0.5-20,
          height: MediaQuery.of(context).size.width*0.5-20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  icon, 
                  size: 80,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                  )
                )
              )
            ],
          )
        )
      )
    );
  }
  
  Widget _searchTileRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _searchTile(Icons.person, "Personen"),
        _searchTile(Icons.location_on, "Orte"),
      ],
    );
  }

  Widget resultsOrTile(){
    if (foundUsers.isEmpty){
      return _searchTileRow();
    }else{
      return Expanded(
        child: ListView.builder(
          itemCount: foundUsers.length,
          itemBuilder: (context, index){
            return ListTile(
              title: InkWell(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileView(user: foundUsers[index]))),
                child: Row(
                  children: [
                    roundProfileImage(context, foundUsers[index].profilePictureUrl, 50, 50),
                    const SizedBox(width: 10,),
                    Text(foundUsers[index].username),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Widget searchBar(){
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        } else {
          foundUsers = await userDataManager.searchUserNames(textEditingValue.text.toLowerCase());
          foundLocations = await locationDataManager.getAutoCompletionData(textEditingValue.text.toLowerCase());

          Iterable<String> predictedUsers = foundUsers.map((user) => user.username);
          Iterable<String> predictedLocations = foundLocations.map((location) => "${location.city}, ${location.region}");
          
          return predictedUsers.followedBy(predictedLocations);
        }
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return entryField(
          context, 
          MediaQuery.of(context).size.width-20,
          50,
          const EdgeInsets.all(10),
          "Suche", 
          textEditingController,
          1,
          innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          focusNode: focusNode
        );
      },
      optionsViewBuilder: (BuildContext context, Function(String) onSelected, Iterable<String> options) {
        //var optionsList = options.toList();
        return Material(
          elevation: 0,
          child: Column(
            children: [
              foundUsers.isNotEmpty 
                ? SizedBox(
                    width: MediaQuery.of(context).size.width-20,
                    child: const Text(
                      "Gefundene User:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                : const SizedBox(height: 0),
              for (var index = 0; index < foundUsers.length; index++)
                ListTile(
                  title: Row(
                    children: [
                      roundProfileImage(context, foundUsers[index].profilePictureUrl, 50, 50),
                      const SizedBox(width: 10,),
                      Text(foundUsers[index].username),
                    ],
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileView(user: foundUsers[index]))),
                ),
              foundLocations.isNotEmpty
                ? SizedBox(
                    width: MediaQuery.of(context).size.width-20,
                    child: const Text(
                      "Gefundene Orte:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                : const SizedBox(height: 0),
              for (var index = 0; index < foundLocations.length; index++)
                ListTile(
                  title: Text("${foundLocations[index].city}, ${foundLocations[index].region}"),
                  onTap: () {
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (builder) => LocationView(locationWithoutCoordinates: foundLocations[index]))
                    );
                  },
                )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [/*
            entryField(
              context, 
              MediaQuery.of(context).size.width-20,
              50,
              const EdgeInsets.fromLTRB(10, 10, 10, 10),
              "Suche", 
              _searchController, 
              1,
              innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5)
            ),
            */
            searchBar(),
            resultsOrTile()
          ],
        ),
      )
    );
  }
}