import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/models/restaurant.dart';

class YelpService {
  final String apiKey = '4k6TxO57_bHm1F6_eEM6wRKtM0usZhdD6lw3HpTnd9hzA9ddkFY5BnwDRhMJQcyRHlXZ5w3FnIVYu5cVJ5GBH6I8kNkbsrZ-qRDRUhNMwpICFIT34hRuXaU6DnZBZ3Yx';  // Replace with your Yelp API key

  Future<List<Restaurant>> getHalalRestaurants(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://api.yelp.com/v3/businesses/search?term=halal&latitude=$latitude&longitude=$longitude&categories=restaurants&limit=10');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $apiKey'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final businesses = data['businesses'];

      // Return the list of restaurants
      return businesses.map<Restaurant>((business) {
        return Restaurant.fromJson({
          'lat': business['coordinates']['latitude'],
          'lon': business['coordinates']['longitude'],
          'name': business['name'],
        });
      }).toList();
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}
