import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/caregiver.dart';

class CaregiverRepository{
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<Caregiver?> getCaregiver() async {
    String? uid = await _authService
        .getAuthenticatedUserId(); 
    if (uid != null) {
      final snapshot = await db.collection('user').doc(uid).collection('caregiver').get();
      if (snapshot.docs.isNotEmpty) {
        return Caregiver.fromFirestore(snapshot.docs.first.data());
      }
    }
    return null;
  }

  Future<void> addCaregiver(Caregiver caregiver) async {
    User? user = await _authService.getCurrentUser();
    String? uid = user?.uid;
    if (uid != null) {
      await db.collection('user').doc(uid).collection('caregiver').add(caregiver.toFirestore());
    }
  }
}