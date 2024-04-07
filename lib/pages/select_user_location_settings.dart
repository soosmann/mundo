import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mundo/helpful_widgets/round_profile_image.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:mundo/models/mundo_user.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/helpful_widgets/entry_field.dart';
import 'package:mundo/models/location.dart';
import 'package:location/location.dart';

class SelectUserLocationSettingsView extends StatefulWidget {
  final MundoUser user;
  final Function(MundoLocation) onLocationSelected;

  const SelectUserLocationSettingsView({super.key, required this.user, required this.onLocationSelected});

  @override
  State<SelectUserLocationSettingsView> createState() => _SelectUserLocationViewSettingsState();
}

class _SelectUserLocationViewSettingsState extends State<SelectUserLocationSettingsView> {
  LocationDataManager locationDataManager = LocationDataManager();

  final predictedLocationsNotifier = ValueNotifier<List<MundoLocationWithoutCoordinates>>([]);
  String locationInput = "";
  MundoLocation? chosenLocation;

  @override
  void initState() {
    super.initState();
    if (widget.user.location == null){
      getLocation().then((coordinates) {
        locationDataManager.getMundoLocationByCoordinates(coordinates).then((mundoLocation) => 
          setState(() {
            chosenLocation = mundoLocation;
            locationInput = "${chosenLocation!.city}, ${chosenLocation!.region}";
          })
        );
      });
    } else {
      chosenLocation = widget.user.location;
      locationInput = "${widget.user.location!.city}, ${widget.user.location!.region}";
    }
  }
  
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

  Widget _appBar(){
    return AppBar(
      title: const Text("Wähle deinen Standort"),
      backgroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        IconButton(
          icon: const Icon(Icons.done),
          onPressed: () async {
            if (chosenLocation != null){
              widget.onLocationSelected(chosenLocation!);
              Navigator.pop(context);
            }
          },
        )
      ],
    );
  }

  Widget headline(){
    return const Text(
      "Wo wohnst du?",
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold
      ),
    );
  }

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
                          widget.user.profilePictureUrl,
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
  
  Widget _locationEntry(){
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return <String>[];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _appBar(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              _locationEntry(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
              chosenLocation != null ? positionMap() : positionMapPlaceholder(),
              SizedBox(height: MediaQuery.of(context).size.height*0.04),
            ],
          ),
        ),
      ),
    );
  }
}