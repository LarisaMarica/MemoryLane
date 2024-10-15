import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/medical_data.dart';

class MedicalDataRepository {
  final db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  String date = DateFormat('d-MMMM-yyyy').format(DateTime.now());

  Future<void> addMedicalData(MedicalData medicalData) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('medical_data')
          .doc(uid)
          .collection('entries')
          .doc(medicalData.date) 
          .set(medicalData.toFirestore());
    }
  }

  Future<MedicalData> getTodayMedicalData() async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      final snapshot =
          await db.collection('medical_data').doc(uid).collection('entries').doc(date).get();
      if (snapshot.exists) {
        return MedicalData.fromFirestore(snapshot);
      }
    }
    addMedicalData(MedicalData(
        mood: 'Happy', systolic: 0, diastolic: 0, pulse: 0, date: date));
    return MedicalData(
        mood: 'Happy', systolic: 0, diastolic: 0, pulse: 0, date: date);
  }

  Future<List<MedicalData>> getAllMedicalData() async {
    String? uid = await _authService.getAuthenticatedUserId();
    List<MedicalData> medicalDataList = [];
    if (uid != null) {
      final snapshot = await db.collection('medical_data').doc(uid).collection('entries').get();
      for (var doc in snapshot.docs) {
        medicalDataList.add(MedicalData.fromFirestore(doc));
      }
    }
    return medicalDataList;
  }

  Future<void> updateMedicalData(MedicalData medicalData) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('medical_data')
          .doc(uid)
          .collection('entries')
          .doc(medicalData.date)
          .update(medicalData.toFirestore());
    }
  }
      
    
  

  Future<void> updateMood(String mood) async {
    String? uid = await _authService.getAuthenticatedUserId();
    if (uid != null) {
      await db
          .collection('medical_data')
          .doc(uid)
          .collection('entries')
          .doc(date)
          .update({'mood': mood});
    }
  }
}
