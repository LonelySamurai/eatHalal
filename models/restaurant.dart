class Restaurant {
  final double lat;
  final double lon;
  final String name;

  Restaurant({required this.lat, required this.lon, required this.name});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      lat: json['lat'],
      lon: json['lon'],
      name: json['name'] ?? 'Unnamed',  // default name if missing
    );
  }
}
