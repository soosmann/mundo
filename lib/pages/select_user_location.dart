import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:mundo/models/user.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/location.dart';
import 'package:location/location.dart';
import 'package:mundo/models/user_data_manager.dart';
import 'package:mundo/pages/home.dart';

class SelectUserLocationView extends StatefulWidget {

  const SelectUserLocationView({super.key});

  @override
  State<SelectUserLocationView> createState() => _SelectUserLocationViewState();
}

class _SelectUserLocationViewState extends State<SelectUserLocationView> {
  LocationDataManager locationDataManager = LocationDataManager();
  UserDataManager userDataManager = UserDataManager();

  MundoUser? user;

  final predictedLocationsNotifier = ValueNotifier<List<MundoLocationWithoutCoordinates>>([]);
  String locationInput = "";
  MundoLocation? chosenLocation;

  /// get current location of device to set it on map
  @override
  void initState() {
    super.initState();
    userDataManager.getUserData().then((value) => setState(() => user = value));
    getLocation().then((coordinates) {
      locationDataManager.getMundoLocationByCoordinates(coordinates).then((mundoLocation) => 
        setState(() {
          chosenLocation = mundoLocation;
          locationInput = "${mundoLocation.city}, ${mundoLocation.region}";
        })
      );
    });
  }
  
  /// func to retrieve current device location
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
    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  /// headline
  Widget _headline(){
    return const Text(
      "Wo wohnst du?",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    );
  }

  /// placeholder for the map
  Widget _positionMapPlaceholder(){
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

  /// map with selected position
  Widget _positionMap() {
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
                  initialCenter: chosenLocation?.coordinates ?? const LatLng(0, 0),
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
                        point: chosenLocation?.coordinates ?? const LatLng(0, 0),
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
  
  /// entry field for location\
  /// gets autocomplete suggestions from google maps api\
  /// renders search field and list of suggestions
  Widget _locationEntry(){
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        } else {
          predictedLocationsNotifier.value = await locationDataManager.getAutoCompletionData(textEditingValue.text.toLowerCase());
          return predictedLocationsNotifier.value.map((location) => "${location.city}, ${location.region}");
        }
      },
      onSelected: (option) {},
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

  /// button that allows to continue with the selected location
  Widget _continueButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () {
        if (chosenLocation != null) {
          userDataManager.saveUsersLocation(chosenLocation!);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeView()),
            (route) => false,
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

  /// button that allows to skip the location selection
  Widget _skipButton(){
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateColor.resolveWith((states) => Theme.of(context).buttonTheme.colorScheme!.primary),
      ),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeView()),
          (route) => false,
        );
      },
      child: Text(
        "Überspringen",
        style: TextStyle(
          color: Theme.of(context).textTheme.labelLarge!.color,
        ),
      )
    );
  }

  Widget _buttonRow(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _skipButton(),
        _continueButton()
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
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              _headline(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              _locationEntry(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              user != null ? _positionMap() : _positionMapPlaceholder(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              _buttonRow(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
            ],
          ),
        ),
      ),
    );
  }
}