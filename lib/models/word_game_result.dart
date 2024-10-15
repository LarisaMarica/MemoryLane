import 'package:cloud_firestore/cloud_firestore.dart';

class WordGameResult{
  int score;
  DateTime date;

  WordGameResult({required this.score, required this.date});

  factory WordGameResult.fromFirestore(Map<String, dynamic> data) {
    return WordGameResult(
      score: data['score'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  get id => null;

  Map<String, dynamic> toFirestore() {
    return {
      'score': score,
      'date': date,
    };
  }
}