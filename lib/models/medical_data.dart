import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MedicalData {
  final String date;
  final String mood;
  final int systolic;
  final int diastolic;
  final int pulse;

  MedicalData({
    required this.date,
    required this.mood,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
  });

  int get moodScore {
    switch (mood) {
      case 'Very Sad':
        return 1;
      case 'Sad':
        return 2;
      case 'Neutral':
        return 3;
      case 'Happy':
        return 4;
      default:
        return 0;
    }
  }

  factory MedicalData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MedicalData(
      date: (doc.exists)
          ? doc.id
          : DateFormat('d-MMMM-yyyy').format(DateTime.now()),
      mood: data['mood'],
      systolic: data['systolic'],
      diastolic: data['diastolic'],
      pulse: data['pulse'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mood': mood,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
    };
  }
}
