import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String title;
  DateTime date;
  bool isTimeAdded;
  String? description;

  Event({
      required this.title,
      required this.date,
      required this.isTimeAdded,
      this.description});

  factory Event.fromFirestore(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      date: (json['date'] as Timestamp).toDate(),
      isTimeAdded: json['isTimeAdded'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'date': Timestamp.fromDate(date),
        'isTimeAdded': isTimeAdded,
        'description': description,
      };
}
