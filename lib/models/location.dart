import 'package:latlong2/latlong.dart';

class MundoLocation{
  String googleMapsId;
  String city;
  String region;
  LatLng coordinates;

  MundoLocation({required this.googleMapsId, required this.city, required this.region, required this.coordinates});

  changeCoordinates(LatLng newCoordinates){
    coordinates = newCoordinates;
  }

  @override
  String toString(){
    return "MundoLocation(googleMapsId: $googleMapsId, city: $city, region: $region, coordinates: $coordinates)";
  }
}

class MundoLocationWithoutCoordinates{
  String googleMapsId;
  String city;
  String region;


  MundoLocationWithoutCoordinates({required this.googleMapsId, required this.city, required this.region});

  factory MundoLocationWithoutCoordinates.fromMap(Map<String, dynamic> map){
    return MundoLocationWithoutCoordinates(
      googleMapsId: map["place_id"],
      city: map["structured_formatting"]["main_text"],
      region: map["structured_formatting"]["secondary_text"],
    );
  }

  @override
  String toString(){
    return "MundoLocationWithoutCoordinates(googleMapsId: $googleMapsId, city: $city, region: $region)";
  }
}