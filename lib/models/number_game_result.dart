import 'package:cloud_firestore/cloud_firestore.dart';

class NumberGameResult{
  int score;
  DateTime date;

  NumberGameResult({
    required this.score,
    required this.date,
  });

  factory NumberGameResult.fromFirestore(Map<String, dynamic> json) {
    return NumberGameResult(
      score: json['score'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'score': score,
    'date': Timestamp.fromDate(date),
  };
}