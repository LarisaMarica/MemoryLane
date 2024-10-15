import 'package:cloud_firestore/cloud_firestore.dart';

class SquaresGameResult {
  int score;
  DateTime date;

  SquaresGameResult({required this.score, required this.date});

  factory SquaresGameResult.fromFirestore(Map<String, dynamic> json) {
    return SquaresGameResult(
      score: json['score'],
      date: (json['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'score': score,
        'date': Timestamp.fromDate(date),
      };
}
