import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/favourite_location.dart';

class FavouriteLocationRepository {
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<void> addLocation(FavouriteLocation location) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('favourite_locations')
          .doc(uid)
          .collection('location')
          .add(location.toJson());
    }
  }

  Future<List<FavouriteLocation>> getLocations() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot = await db
          .collection('favourite_locations')
          .doc(uid)
          .collection('location')
          .get();
      return snapshot.docs
          .map((doc) => FavouriteLocation.fromFirestore(doc))
          .toList();
    }
    return [];
  }

  Future<void> updateLocation(FavouriteLocation location) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot = await db
          .collection('favourite_locations')
          .doc(uid)
          .collection('location')
          .where('name', isEqualTo: location.name)
          .get();
      if (snapshot.docs.isNotEmpty) {
        await db
            .collection('favourite_locations')
            .doc(uid)
            .collection('location')
            .doc(snapshot.docs.first.id)
            .update(location.toJson());
      }
      else{
        addLocation(location);
      }
    }
  }
}
