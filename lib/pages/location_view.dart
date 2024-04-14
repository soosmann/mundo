import 'package:flutter/material.dart';
import 'package:mundo/models/location.dart';
import 'package:mundo/models/location_data_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:mundo/models/post_data_manager.dart';
import 'package:mundo/models/post.dart';
import 'package:mundo/pages/post_view.dart';

class LocationView extends StatefulWidget {
  final MundoLocationWithoutCoordinates locationWithoutCoordinates;
  const LocationView({Key? key, required this.locationWithoutCoordinates}) : super(key: key);

  @override
  State<LocationView> createState() => _LocationViewState();
}

class _LocationViewState extends State<LocationView> {
  MundoLocation? location;
  bool isMapExpanded = false;

  List<Post> posts = [];

  /// receives a MundoLocationWithoutCoordinates, needs to get the coordinates to create a MundoLocation\
  /// retrieves posts by location id
  @override
  void initState() {
    super.initState();
    LocationDataManager().getCoordinatesByPlaceId(widget.locationWithoutCoordinates.googleMapsId)
      .then((value) => setState(() => location = MundoLocation(
        googleMapsId: widget.locationWithoutCoordinates.googleMapsId, 
        city: widget.locationWithoutCoordinates.city, 
        region: widget.locationWithoutCoordinates.region, 
        coordinates: value)
      ));

    PostDataManager().getPostsByLocationId(widget.locationWithoutCoordinates.googleMapsId).then((value) => setState(() => posts = value));
  }

  /// title of the location\
  /// icon to show or hide map
  Widget _locationTitle(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
      child: Container(
        width: MediaQuery.of(context).size.width-10, // left and right padding: 2*5=10
        padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.chevron_left,
                size: 30,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                "${widget.locationWithoutCoordinates.city}, ${widget.locationWithoutCoordinates.region}", 
                style: const TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold
                ),
                softWrap: true,
                maxLines: 2,
              ),
            ),
            InkWell(
              onTap: () => setState(() => isMapExpanded = !isMapExpanded),
              child: Icon(
                isMapExpanded ? Icons.expand_less : Icons.expand_more,
                size: 35,
              ),
            ),
          ],
        ),
      )
    );
  }

  /// shows location on map
  Widget _positionMap() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: MediaQuery.of(context).size.width-20, // left and right padding: 2*10=20
          height: MediaQuery.of(context).size.height*0.3,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: location!.coordinates,
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
                        point: location!.coordinates,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// placeholder for map
  Widget _positionMapPlaceholder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 2, 10, 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 1000),
          width: MediaQuery.of(context).size.width-20, // left and right padding: 2*10=20
          height: MediaQuery.of(context).size.height*0.3,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary
          ),
          child: Icon(
            Icons.map,
            color: Theme.of(context).colorScheme.secondary,
          )
        ),
      ),
    );
  }

  /// shows map or placeholder
  Widget _positionMapOrPlaceholder(){
    if (isMapExpanded) {
      return location == null ? _positionMapPlaceholder() : _positionMap();
    } else {
      return const SizedBox.shrink();
    }
  }

  /// shows main image of retrieved posts
  Widget _imageGrid() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PostView(post: posts[index], isOwnPost: false))),
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.5-5,
              height: MediaQuery.of(context).size.width*0.5-5,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.file(
                  posts[index].postElements[posts[index].mainImageIndex!].imageFile, 
                  fit: BoxFit.cover
                ),
              )
            ),
          );
        },
      ),
    );
  }

  /// information that no images have been posted yet
  Widget _noImagesInfo(){
    return const Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          "Noch keine Posts mit diesem Ort verbunden.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _locationTitle(),
            _positionMapOrPlaceholder(),
            posts.isNotEmpty ? _imageGrid() : _noImagesInfo(),
          ],
        )
      ),
    );
  }
}