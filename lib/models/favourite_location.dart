import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FavouriteLocation {
  final String? formattedAddress;
  final String? name;
  final LatLng location;

  FavouriteLocation({
    this.formattedAddress,
    this.name,
    required this.location,
  });

  factory FavouriteLocation.fromJson(Map<String, dynamic> json) {
    var geometry = json['geometry']?['location'];
    if (geometry == null) {
      throw Exception('Invalid JSON: geometry location is missing');
    }
    return FavouriteLocation(
      formattedAddress: json['formatted_address'] as String?,
      name: json['name'] as String?,
      location: LatLng(
        (geometry['lat'] as num).toDouble(),
        (geometry['lng'] as num).toDouble(),
      ),
    );
  }

  factory FavouriteLocation.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return FavouriteLocation(
      formattedAddress: data['formattedAddress'],
      name: data['name'],
      location: LatLng(
        data['location'].latitude,
        data['location'].longitude,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'formattedAddress': formattedAddress,
        'name': name,
        'location': GeoPoint(location.latitude, location.longitude),
      };
}

