import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String title;
  String category;
  String? description;
  bool repeatDaily;
  bool repeatWeekly;
  List<bool> specificDays;
  DateTime date;
  Map<String, bool> doneDates;

  Task({
    required this.title,
    required this.category,
    this.description,
    required this.repeatDaily,
    required this.repeatWeekly,
    required this.specificDays,
    required this.date,
    Map<String, bool>? doneDates,
  }) : doneDates = doneDates ?? {};

  factory Task.fromFirestore(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      category: json['category'],
      description: json['description'],
      repeatDaily: json['repeatDaily'],
      repeatWeekly: json['repeatWeekly'],
      specificDays: (json['specificDays'] as List<dynamic>).cast<bool>(),
      date: (json['date'] as Timestamp).toDate(),
      doneDates: json['doneDates'] != null
          ? Map<String, bool>.from(json['doneDates'])
          : {},
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'category': category,
        'description': description,
        'repeatDaily': repeatDaily,
        'repeatWeekly': repeatWeekly,
        'specificDays': specificDays,
        'date': Timestamp.fromDate(date),
        'doneDates': doneDates,
      };
}
