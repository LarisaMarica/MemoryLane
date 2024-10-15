import 'package:cloud_firestore/cloud_firestore.dart';

class Caregiver {
  final String firstName;
  final String lastName;
  final DateTime accountCreated;

  Caregiver({
    required this.firstName,
    required this.lastName,
    required this.accountCreated,
  });

  factory Caregiver.fromFirestore(Map<String, dynamic> json) {
    return Caregiver(
      firstName: json['firstName'],
      lastName: json['lastName'],
      accountCreated: (json['accountCreated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'accountCreated': Timestamp.fromDate(accountCreated),
      };
}