import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/patient.dart';

class PatientRepository {
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<Patient?> getPatient() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot =
          await db.collection('user').doc(uid).collection('patient').get();
      if (snapshot.docs.isNotEmpty) {
        return Patient.fromFirestore(snapshot.docs.first.data());
      }
    }
    return null;
  }

  Future<void> addPatient(Patient patient) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('user')
          .doc(uid)
          .collection('patient')
          .add(patient.toFirestore());
    }
  }
}