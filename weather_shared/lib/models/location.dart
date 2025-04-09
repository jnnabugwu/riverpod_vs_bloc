class Location {
  final String cityName;
  final double lat;
  final double lon;

  Location({required this.cityName, required this.lat, required this.lon});

  factory Location.fromJson(Map<String, dynamic> json) {
    // Implementation details
    return Location(cityName: json['name'], lat: json['lat'], lon: json['lon']);
  }

  Map<String, dynamic> toJson() {
    return {'cityName': cityName, 'lat': lat, 'lon': lon};
  }
}
