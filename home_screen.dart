import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_app/models/restaurant.dart';
import 'package:location/location.dart';
import 'package:flutter_app/yelp_service.dart';  // Import Yelp service
import 'package:flutter_app/restaurant_marker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late double latitude;
  late double longitude;
  bool isLoading = false;
  bool hasLocation = false;
  List<Restaurant> restaurants = [];
  final MapController _mapController = MapController();

  // Function to request location permission
  Future<void> _getLocation() async {
    Location location = Location();

    // Request permission if not already granted
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Fetch the current location
    LocationData currentLocation = await location.getLocation();

    setState(() {
      latitude = currentLocation.latitude!;
      longitude = currentLocation.longitude!;
      hasLocation = true;
      isLoading = true;
    });

    // Fetch halal restaurants nearby
    await _fetchHalalRestaurants(latitude, longitude);
  }

  // Fetch halal restaurants around the user's location using Yelp API
  Future<void> _fetchHalalRestaurants(double latitude, double longitude) async {
    try {
      YelpService yelpService = YelpService();
      List<Restaurant> fetchedRestaurants = await yelpService.getHalalRestaurants(latitude, longitude);
      setState(() {
        restaurants = fetchedRestaurants;
        isLoading = false;
      });

      // Move the map only after it's rendered (using post-frame callback)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(latitude, longitude), 14.0); // Move map to user's location
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading restaurants: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Halal Restaurants Nearby')),
      body: Center(
        child: !hasLocation
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _getLocation,
              child: Text('Locate Yourself'),
            ),
          ],
        )
            : isLoading
            ? Center(child: CircularProgressIndicator())
            : FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            minZoom: 5.0,
            maxZoom: 18.0,

          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?lang=en", // Ensure map is in English
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                // Marker for the user's location (purple)
                Marker(
                  point: LatLng(latitude, longitude),
                  child: Icon(Icons.location_pin, color: Colors.purple, size: 40),
                ),
                // Markers for each halal restaurant (green)
                ...restaurants.map((restaurant) {
                  return Marker(
                    point: LatLng(restaurant.lat, restaurant.lon),
                    child: RestaurantMarker(
                      lat: restaurant.lat,
                      lon: restaurant.lon,
                      name: restaurant.name,
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
