

class Location{
  String googleMapsId;
  String city;
  String region;

  Location({required this.googleMapsId, required this.city, required this.region});

  factory Location.fromMap(Map<String, dynamic> map){
    return Location(
      googleMapsId: map["place_id"],
      city: map["structured_formatting"]["main_text"],
      region: map["structured_formatting"]["secondary_text"]
    );
  }

  @override
  String toString(){
    return "Location(googleMapsId: $googleMapsId, city: $city, region: $region)";
  }
}