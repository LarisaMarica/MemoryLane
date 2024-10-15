import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/family.dart';
import 'package:licenta/models/friend.dart';
import 'package:licenta/models/patient.dart';
import 'package:licenta/repositories/friend_repository.dart';
import 'package:licenta/repositories/patient_repository.dart';
import 'package:licenta/repositories/family_repository.dart';
import 'package:licenta/widgets/app_drawer_patient.dart';

class MemoryPatientScreen extends StatefulWidget {
  const MemoryPatientScreen({super.key});

  @override
  MemoryPatientScreenState createState() => MemoryPatientScreenState();
}

class MemoryPatientScreenState extends State<MemoryPatientScreen> {
  Patient _patient = Patient(
    dob: DateTime.now(),
    firstName: '',
    lastName: '',
    gender: '',
  );
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');
  List<Family> _familyMembers = [];
  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchFamilyMembers();
    _fetchFriends();
  }

  _fetchUser() async {
    PatientRepository().getPatient().then((patient) {
      setState(() {
        _patient = patient!;
      });
    });
  }

  _fetchFamilyMembers() async {
    FamilyRepository().getFamilyMembers().then((familyMembers) {
      setState(() {
        _familyMembers = familyMembers;
      });
    });
  }

  _fetchFriends() async {
    FriendRepository().getFriends().then((friends) {
      setState(() {
        _friends = friends;
      });
    });
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    final age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      return age - 1;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerPatient(),
      appBar: AppBar(
        title: Text('Memory Book',
            style: GoogleFonts.workSans(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              Text(
                'Personal Information',
                style: GoogleFonts.workSans(
                    fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('First Name: ${_patient.firstName}',
                            style: GoogleFonts.workSans(fontSize: 20)),
                        Text('Last Name: ${_patient.lastName}',
                            style: GoogleFonts.workSans(fontSize: 20)),
                        Text('Gender: ${_patient.gender}',
                            style: GoogleFonts.workSans(fontSize: 20)),
                        Text(
                            'Date of Birth: ${_dateFormat.format(_patient.dob)}',
                            style: GoogleFonts.workSans(fontSize: 20)),
                        Text('Age: ${_calculateAge(_patient.dob)}',
                            style: GoogleFonts.workSans(fontSize: 20)),
                      ],
                    ),
                  ),
                ),
              ),
              _buildFamilyMembers(),
              _buildFriends(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyMembers() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20.0),
        Text(
          'Family Members',
          style:
              GoogleFonts.workSans(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20.0),
        if (_familyMembers.isEmpty)
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No family members added yet.',
                style: GoogleFonts.workSans(fontSize: 20),
              ),
            ),
          ),
        for (final familyMember in _familyMembers)
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Name: ${familyMember.name}',
                    style: GoogleFonts.workSans(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Relation: ${familyMember.relation}',
                    style: GoogleFonts.workSans(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (familyMember.description != null &&
                      familyMember.description != '')
                    Text(
                      'Description: ${familyMember.description}',
                      style: GoogleFonts.workSans(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  const SizedBox(height: 10.0),
                  if (familyMember.imageURL == null ||
                      familyMember.imageURL!.isEmpty)
                    const Text("Image not available",
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.italic)),
                  if (familyMember.imageURL != null &&
                      familyMember.imageURL!.isNotEmpty)
                    FutureBuilder<String>(
                      future: getImage(familyMember.imageURL),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Image.network(snapshot.data!);
                        } else {
                          return const Text("Image not available",
                              style: TextStyle(fontSize: 20));
                        }
                      },
                    ),
                ],
              ),
            ),
          )
      ],
    );
  }

  Widget _buildFriends() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20.0),
        Text(
          'Friends',
          style:
              GoogleFonts.workSans(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20.0),
        if (_friends.isEmpty)
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No friends added yet.',
                style: GoogleFonts.workSans(fontSize: 20),
              ),
            ),
          ),
        for (final friend in _friends)
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Name: ${friend.name}',
                    style: GoogleFonts.workSans(fontSize: 20),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (friend.description != null && friend.description != '')
                    Text(
                      'Description: ${friend.description}',
                      style: GoogleFonts.workSans(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  const SizedBox(height: 10.0),
                  if (friend.imageURL == null || friend.imageURL!.isEmpty)
                    const Text("Image not available",
                        style: TextStyle(
                            fontSize: 20, fontStyle: FontStyle.italic)),
                  if (friend.imageURL != null && friend.imageURL!.isNotEmpty)
                    FutureBuilder<String>(
                      future: getImage(friend.imageURL),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          return Image.network(snapshot.data!);
                        } else {
                          return const Text("Image not available",
                              style: TextStyle(fontSize: 20));
                        }
                      },
                    ),
                ],
              ),
            ),
          )
      ],
    );
  }
}
