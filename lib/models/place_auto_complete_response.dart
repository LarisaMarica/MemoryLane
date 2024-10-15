import 'dart:convert';

import 'package:licenta/models/favourite_location.dart';

class PlaceAutoCompleteResponse {
  final String? status;
  final List<FavouriteLocation>? candidates;

  PlaceAutoCompleteResponse({this.status, this.candidates});

  factory PlaceAutoCompleteResponse.fromJson(Map<String, dynamic> json) {
    List<FavouriteLocation>? candidates = [];
    if (json['candidates'] != null) {
      candidates = (json['candidates'] as List<dynamic>)
          .map<FavouriteLocation>((e) => FavouriteLocation.fromJson(e))
          .toList();
    }
    return PlaceAutoCompleteResponse(
      status: json['status'] as String?,
      candidates: candidates,
    );
  }

  static PlaceAutoCompleteResponse parseAutoCompleteResponse(
      String responseBody) {
    Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
    return PlaceAutoCompleteResponse.fromJson(jsonResponse);
  }
}
