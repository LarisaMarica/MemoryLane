import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/favourite_location.dart';
import 'package:licenta/models/medical_data.dart';
import 'package:licenta/models/patient.dart';
import 'package:licenta/repositories/favourite_location_repository.dart';
import 'package:licenta/repositories/medical_data_repository.dart';
import 'package:licenta/repositories/patient_repository.dart';
import 'package:licenta/widgets/app_drawer_patient.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePatientScreen extends StatefulWidget {
  const HomePatientScreen({super.key});

  @override
  HomePatientScreenState createState() => HomePatientScreenState();
}

class HomePatientScreenState extends State<HomePatientScreen> {
  late Patient patient =
      Patient(firstName: '', lastName: '', dob: DateTime.now(), gender: '');

  String currentDate = DateFormat('d-MMMM-yyyy').format(DateTime.now());
  String currentMood = 'Happy';
  MedicalData currentMedicalData =
      MedicalData(mood: '', systolic: 0, diastolic: 0, pulse: 0, date: '');

  final Map<String, IconData> moodIcons = {
    'Very Sad': Icons.sentiment_very_dissatisfied,
    'Sad': Icons.sentiment_dissatisfied,
    'Neutral': Icons.sentiment_neutral,
    'Happy': Icons.sentiment_very_satisfied,
  };

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final fetchedPatient = await PatientRepository().getPatient();
    final fetchedMedicalData =
        await MedicalDataRepository().getTodayMedicalData();

    setState(() {
      patient = fetchedPatient!;
      currentMood = fetchedMedicalData.mood;
      currentMedicalData = fetchedMedicalData;
    });
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final age = difference.inDays ~/ 365;
    return age;
  }

  _updateMedicalData() {
    final mood = currentMood;
    final medicalData = MedicalData(
      mood: mood,
      systolic: currentMedicalData.systolic,
      diastolic: currentMedicalData.diastolic,
      pulse: currentMedicalData.pulse,
      date: currentMedicalData.date,
    );
    MedicalDataRepository().updateMedicalData(medicalData);
  }

  _updateLocation() async {
    try {
      LocationData currentLocation = await Location().getLocation();
      final LatLng location =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
      FavouriteLocation patient = FavouriteLocation(
        name: 'Patient Last Location',
        location: location,
      );
      FavouriteLocationRepository().updateLocation(patient);
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateLocation();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', style: GoogleFonts.workSans(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor, kSecondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: const AppDrawerPatient(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Today: $currentDate',
                        style: GoogleFonts.workSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Hello, ${patient.firstName}!',
                        style: GoogleFonts.workSans(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${patient.firstName} ${patient.lastName}',
                            style: GoogleFonts.workSans(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Age: ${_calculateAge(patient.dob)}',
                            style: GoogleFonts.workSans(
                                fontSize: 20, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'How are you feeling today?',
                        style: GoogleFonts.workSans(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: moodIcons.entries.map((entry) {
                          return IconButton(
                            icon: Icon(
                              entry.value,
                              color: currentMood == entry.key
                                  ? kPrimaryColor
                                  : Colors.grey,
                              size: 40,
                            ),
                            onPressed: () {
                              setState(() {
                                currentMood = entry.key;
                              });
                              _updateMedicalData();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Current Mood: $currentMood',
                        style: GoogleFonts.workSans(
                            fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Do you want to play a game?',
                      style: GoogleFonts.workSans(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/word-game');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryLightColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 10.0),
                        ),
                        child: Text(
                          'Verbal Memory Game',
                          style: GoogleFonts.workSans(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/number-game');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryLightColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 10.0),
                        ),
                        child: Text(
                          'Number Memory Game',
                          style: GoogleFonts.workSans(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/squares-game');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryLightColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32.0, vertical: 10.0),
                        ),
                        child: Text(
                          'Visual Memory Game',
                          style: GoogleFonts.workSans(
                              fontSize: 20, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
