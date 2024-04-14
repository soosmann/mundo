import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/auth.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:mundo/models/user.dart';
import 'package:mundo/models/post.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/create_post.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/location.dart';
import 'package:location/location.dart';

class SelectPostLocationView extends StatefulWidget {
  const SelectPostLocationView({super.key});

  @override
  State<SelectPostLocationView> createState() => _SelectPostLocationViewState();
}

class _SelectPostLocationViewState extends State<SelectPostLocationView> {
  LocationDataManager locationDataManager = LocationDataManager();

  final predictedLocationsNotifier = ValueNotifier<List<MundoLocationWithoutCoordinates>>([]);
  String locationInput = "";
  MundoLocation? chosenLocation; 

  Post post = Post(
    ownerId: AuthService().currentUser!.uid,
    title: "Neuer Post", 
    postElements: [],
  );

  MundoUser? user;

  /// get user data and current location to display it on post location selection map
  @override
  void initState() {
    super.initState();
    UserDataManager().getUserData().then((value) => setState(() => user = value));
    
    getLocation().then((coordinates) {
      locationDataManager.getMundoLocationByCoordinates(coordinates).then((mundoLocation) => 
        setState(() {
          chosenLocation = mundoLocation;
          locationInput = "${mundoLocation.city}, ${mundoLocation.region}";
        })
      );
    });
  }
  
  /// function to get current device location
  Future<LatLng> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location service are disabled.');
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permissions are denied');
      }
    }

    locationData = await location.getLocation();
    //print("Coordinates: ${locationData.latitude}, ${locationData.longitude}");
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  /// title for the view
  Widget headline(){
    return const Text(
      "Wo bist Du gewesen?",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    );
  }

  /// placeholder for the map
  Widget positionMapPlaceholder(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [ 
            Container(
              width: MediaQuery.of(context).size.width - 20,
              height: MediaQuery.of(context).size.height*0.5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Icon(
                  Icons.map, 
                  size: MediaQuery.of(context).size.width*0.5, 
                  color: Theme.of(context).colorScheme.secondary
                ),
              )
            )
          ],
        ),
      ),
    );
  }

  /// map with user location
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
                key: UniqueKey(),
                options: MapOptions(
                  initialCenter: chosenLocation?.coordinates ?? const LatLng(0, 0), //post.location!.coordinates,
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
                        point: chosenLocation?.coordinates ?? const LatLng(0,0),//post.location!.coordinates,
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
  
  /// entry field for location input\
  /// calls the autocomplete function to get predicted locations\
  /// creates textfield and options for the predicted locations
  Widget locationEntry(){
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          predictedLocationsNotifier.value = [];
          return <String>[];
        } else {
          predictedLocationsNotifier.value = await locationDataManager.getAutoCompletionData(textEditingValue.text.toLowerCase());
          return predictedLocationsNotifier.value.map((location) => "${location.city}, ${location.region}");
        }
      },
      fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
        textEditingController.text = locationInput;
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
        return ValueListenableBuilder<List<MundoLocationWithoutCoordinates>>(
          valueListenable: predictedLocationsNotifier,
          builder: (context, predictedLocations, child) {
            return Material(
              elevation: 0,
              child: Column(
                children: predictedLocations.map((location) {
                  return ListTile(
                    title: Text("${location.city}, ${location.region}"),
                    onTap: () {
                      onSelected("${location.city}, ${location.region}"); // for triggering the disappearance of the options
                      locationDataManager.getCoordinatesByPlaceId(location.googleMapsId)
                        .then((coordinates) => setState(() {
                          locationInput = "${location.city}, ${location.region}";
                          chosenLocation = MundoLocation(
                            googleMapsId: location.googleMapsId, 
                            city: location.city,
                            region: location.region, 
                            coordinates: coordinates
                          );
                        })
                      );
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  /// button to continue to the post creation view
  Widget continueButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () {
        if (chosenLocation != null) {
          post.changeLocation(chosenLocation!);
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => CreatePostView(post: post))
          );
        }
      },
      child: Text(
        "Weiter",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      )
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
              chosenLocation != null ? positionMap() : positionMapPlaceholder(),
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