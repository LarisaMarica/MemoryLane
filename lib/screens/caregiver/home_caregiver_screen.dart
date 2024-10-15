import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/medical_data.dart';
import 'package:licenta/models/patient.dart';
import 'package:licenta/repositories/medical_data_repository.dart';
import 'package:licenta/repositories/patient_repository.dart';
import 'package:licenta/widgets/app_drawer_caregiver.dart';

class HomeCaregiverScreen extends StatefulWidget {
  const HomeCaregiverScreen({super.key});

  @override
  HomeCaregiverScreenState createState() => HomeCaregiverScreenState();
}

class HomeCaregiverScreenState extends State<HomeCaregiverScreen> {
  late Patient patient =
      Patient(firstName: '', lastName: '', dob: DateTime.now(), gender: '');

  TextEditingController systolicController = TextEditingController();
  TextEditingController diastolicController = TextEditingController();
  TextEditingController pulseController = TextEditingController();

  String currentDate = DateFormat('d-MMMM-yyyy').format(DateTime.now());
  String currentMood = 'Happy';

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
    systolicController.addListener(_updateMedicalData);
    diastolicController.addListener(_updateMedicalData);
    pulseController.addListener(_updateMedicalData);
  }

  Future<void> _fetchInitialData() async {
    final fetchedPatient = await PatientRepository().getPatient();
    final fetchedMedicalData =
        await MedicalDataRepository().getTodayMedicalData();

    setState(() {
      patient = fetchedPatient!;
      systolicController.text = fetchedMedicalData.systolic.toString();
      diastolicController.text = fetchedMedicalData.diastolic.toString();
      pulseController.text = fetchedMedicalData.pulse.toString();
      currentMood = fetchedMedicalData.mood;
    });
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final age = difference.inDays ~/ 365;
    return age;
  }

  _updateMedicalData() {
    final systolic = int.tryParse(systolicController.text) ?? 0;
    final diastolic = int.tryParse(diastolicController.text) ?? 0;
    final pulse = int.tryParse(pulseController.text) ?? 0;
    final mood = currentMood;
    final medicalData = MedicalData(
      mood: mood,
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      date: currentDate,
    );
    MedicalDataRepository().updateMedicalData(medicalData);
  }

  @override
  Widget build(BuildContext context) {
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
      drawer: const AppDrawerCaregiver(),
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
                        'Patient Information',
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
                        'Mood Tracker',
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
            SizedBox(
              width: double.infinity,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Medical Data',
                        style: GoogleFonts.workSans(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Blood Pressure',
                        style: GoogleFonts.workSans(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildDataBox('Systolic (mmHg):', systolicController),
                    _buildDataBox('Diastolic (mmHg):', diastolicController),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Pulse',
                        style: GoogleFonts.workSans(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                    _buildDataBox('Pulse (bpm):', pulseController),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/health-stats');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kSecondaryLightColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 16.0),
                          ),
                          child: Text(
                            'View Health Statistics',
                            style: GoogleFonts.workSans(
                                fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBox(String label, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          children: [
            Text(label, style: GoogleFonts.workSans(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
