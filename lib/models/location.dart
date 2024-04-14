import 'package:latlong2/latlong.dart';

/// class that represents a location in the app
class MundoLocation{
  String googleMapsId;
  String city;
  String region;
  LatLng coordinates;

  MundoLocation({required this.googleMapsId, required this.city, required this.region, required this.coordinates});

  /// change coordinates of a MundoLocation
  changeCoordinates(LatLng newCoordinates){
    coordinates = newCoordinates;
  }

  /// standardmethod toString()
  @override
  String toString(){
    return "MundoLocation(googleMapsId: $googleMapsId, city: $city, region: $region, coordinates: $coordinates)";
  }
}

/// class that represents a location in the app without coordinates\
/// this class exists because the Google Maps API does not provide coordinates in auto completion
class MundoLocationWithoutCoordinates{
  String googleMapsId;
  String city;
  String region;


  MundoLocationWithoutCoordinates({required this.googleMapsId, required this.city, required this.region});

  /// create an instance from Flutter map
  factory MundoLocationWithoutCoordinates.fromMap(Map<String, dynamic> map){
    return MundoLocationWithoutCoordinates(
      googleMapsId: map["place_id"],
      city: map["structured_formatting"]["main_text"],
      region: map["structured_formatting"]["secondary_text"],
    );
  }

  /// standardmethod toString()
  @override
  String toString(){
    return "MundoLocationWithoutCoordinates(googleMapsId: $googleMapsId, city: $city, region: $region)";
  }
}