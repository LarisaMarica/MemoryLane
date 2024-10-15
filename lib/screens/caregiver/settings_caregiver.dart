import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/firebase/auth_service.dart';
import 'package:licenta/models/caregiver.dart';
import 'package:licenta/repositories/caregiver_repository.dart';
import 'package:licenta/widgets/app_drawer_caregiver.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  Caregiver caregiver =
      Caregiver(firstName: '', lastName: '', accountCreated: DateTime.now());
  String? email;

  @override
  void initState() {
    CaregiverRepository().getCaregiver().then((value) {
      setState(() {
        caregiver = value!;
      });
    });
    setEmail();
    super.initState();
  }

  setEmail() async {
    email = await AuthService().getCurrentEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Account Details', style: GoogleFonts.workSans(color: Colors.white)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                'Name',
                style: GoogleFonts.workSans(fontSize: 20),
              ),
              subtitle: Text(
                '${caregiver.firstName} ${caregiver.lastName}',
                style: GoogleFonts.workSans(fontSize: 25),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Email',
                style: GoogleFonts.workSans(fontSize: 20),
              ),
              subtitle: Text(
                email ?? '',
                style: GoogleFonts.workSans(fontSize: 25),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                'Account created on',
                style: GoogleFonts.workSans(fontSize: 20),
              ),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(caregiver.accountCreated),
                style: GoogleFonts.workSans(fontSize: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
