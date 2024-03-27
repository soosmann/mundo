import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';

import 'package:mundo/models/location.dart';

class LocationDataManager{
  final apiKey = "AIzaSyB45xBI5721owAX0Xf8qw6566bgwOBPlJg";

  Future<List<Location>> getAutoCompletionData(String input) async {
    final apiUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=(cities)&language=de&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<Location> predictedLocations = [];

        if (data['status'] == 'OK' && data['predictions'] != null && data['predictions'].isNotEmpty) {
          for (var prediction in data['predictions']) {
            predictedLocations.add(Location.fromMap(prediction));
          }
          return predictedLocations;
        } else {
          throw Exception('No results found for the provided address');
        }
      } else {
        throw Exception('Failed to fetch data from the Google Maps API');
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
}