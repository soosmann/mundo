import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:mundo/models/post.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/create_post.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/location.dart';

class SelectPostLocationView extends StatefulWidget {
  const SelectPostLocationView({super.key});

  @override
  State<SelectPostLocationView> createState() => _SelectPostLocationViewState();
}

class _SelectPostLocationViewState extends State<SelectPostLocationView> {
  LocationDataManager locationDataManager = LocationDataManager();
  TextEditingController locationInputController = TextEditingController();

  List<Location> predictedLocations = [];

  Post post = Post(
    ownerId: AuthService().currentUser!.uid,
    title: "Neuer Post", 
    postElements: [],
    location: const LatLng(52.02335, 9.01869)
  );

  MundoUser? user;

  @override
  void initState() {
    super.initState();
    UserDataManager().getUserData().then((value) => setState(() => user = value));
  }

  Widget headline(){
    return const Text(
      "Wo bist Du gewesen?",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    );
  }

  bool isUserScrollingOnMap = false;
  Widget positionMap() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 20,
          height: MediaQuery.of(context).size.height*0.5,
          child: Stack(
            children: [
              FlutterMap(
                key: isUserScrollingOnMap ? UniqueKey() : UniqueKey(),
                options: MapOptions(
                  initialCenter: post.location,
                  initialZoom: 5,
                  onPositionChanged: (position, hasGesture) {
                    setState(() {
                      isUserScrollingOnMap = true;
                      post.changeLocation(position.center!); 
                    });
                  },
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
                        child: roundProfileImage(
                          context, 
                          user?.profilePictureUrl,
                          50, 
                          50
                        )
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

  Widget continueButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => CreatePostView(post: post))
      ), 
      child: Text(
        "Weiter",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      )
    );
  }

  Widget locationEntry(){
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        } else {
          predictedLocations = await locationDataManager.getAutoCompletionData(textEditingValue.text.toLowerCase());
          return predictedLocations.map((location) => "${location.city}, ${location.region}");
        }
      },
      onSelected: (String selectedLocation) {
        setState(() {
          isUserScrollingOnMap = false;
        });
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        return entryField(
          context, 
          MediaQuery.of(context).size.width-20,
          50,
          const EdgeInsets.all(0),
          "Location", 
          textEditingController, 
          1,
          innerPadding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          focusNode: focusNode
        );
      },
      optionsViewBuilder: (BuildContext context, Function(String) onSelected, Iterable<String> options) {
        var optionsList = options.toList();
        return Material(
          elevation: 0,
          child: Column(
            children: [
              for (var i = 0; i < options.length; i++)
                ListTile(
                  title: Text(optionsList[i]),
                  onTap: () {
                    onSelected(optionsList[i]);
                    locationDataManager.getCoordinatesByPlaceId(predictedLocations[i].googleMapsId)
                      .then((value) => setState(() => post.changeLocation(value)));
                  },
                ),
            ],
          ),
        );
      },
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              headline(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              locationEntry(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              positionMap(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              continueButton(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
            ],
          ),
        ),
      ),
    );
  }
}