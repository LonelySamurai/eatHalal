import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class RestaurantMarker extends StatelessWidget {
  final double lat;
  final double lon;
  final String name;

  const RestaurantMarker({
    required this.lat,
    required this.lon,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.location_on,
          color: Colors.green, // Green marker for halal restaurants
          size: 40.0,
        ),
        Text(name, style: TextStyle(color: Colors.black, fontSize: 12)),
      ],
    );
  }
}
