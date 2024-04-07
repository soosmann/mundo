import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

import 'package:mundo/models/location.dart';
//import 'package:location/location.dart';

class LocationDataManager{
  final apiKey = "AIzaSyB45xBI5721owAX0Xf8qw6566bgwOBPlJg";

  Future<List<MundoLocationWithoutCoordinates>> getAutoCompletionData(String input) async {
    final apiUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&language=de&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<MundoLocationWithoutCoordinates> predictedLocations = [];

        if (data['status'] == 'OK' && data['predictions'] != null && data['predictions'].isNotEmpty) {
          for (var prediction in data['predictions']) {
            predictedLocations.add(MundoLocationWithoutCoordinates.fromMap(prediction));
          }
          return predictedLocations;
        } else {
          throw Exception('No results found for the provided address');
        }
      } else {
        throw Exception('Failed to fetch autocompletion data from the Google Maps API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<LatLng> getCoordinatesByPlaceId(String placeId) async {
    final apiUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data["status"] == "OK" && data["result"] != null && data["result"]["geometry"] != null) {
          LatLng coordinates = LatLng(
            data["result"]["geometry"]["location"]["lat"], 
            data["result"]["geometry"]["location"]["lng"]
          );
          return coordinates;
        } else {
          throw Exception('No results found for the provided place ID');
        }
      } else {
        throw Exception('Failed to fetch data from the Google Maps API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> getPlaceByCoordinates(LatLng coordinates) async {
    final apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${coordinates.latitude},${coordinates.longitude}&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data["status"] == "OK" && data["plus_code"] != null && data["plus_code"]["compound_code"] != null) {
          String place = data["plus_code"]["compound_code"];
          place = place.substring(place.indexOf(" ") + 1); // remove global code
          return place;
        } else {
          throw Exception('No results found for the provided coordinates');
        }
      } else {
        throw Exception('Failed to fetch place data from the Google Maps API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<MundoLocation> getMundoLocationByCoordinates(LatLng coordinates) async{
    final placeString = await getPlaceByCoordinates(coordinates);
    //print("Place: $placeString");
    final resultsFromString = await getAutoCompletionData(placeString);

    if (resultsFromString.isNotEmpty) {
      final location = MundoLocation(
        googleMapsId: resultsFromString.first.googleMapsId, 
        city: resultsFromString.first.city, 
        region: resultsFromString.first.region, 
        coordinates: coordinates
      );
      return location;
    } else {
      throw Exception('No results found for the provided coordinates');
    }
  }
}