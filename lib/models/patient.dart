import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String firstName;
  final String lastName;
  final String gender;
  final DateTime dob;

  Patient({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
  });

  factory Patient.fromFirestore(Map<String, dynamic> json) {
    return Patient(
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      dob: (json['dob'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'dob': Timestamp.fromDate(dob),
      };
}
