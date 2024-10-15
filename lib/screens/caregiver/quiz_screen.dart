import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/caregiver.dart';
import 'package:licenta/models/family.dart';
import 'package:licenta/models/friend.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/patient.dart';
import 'package:licenta/repositories/caregiver_repository.dart';
import 'package:licenta/repositories/family_repository.dart';
import 'package:licenta/repositories/friend_repository.dart';
import 'package:licenta/repositories/patient_repository.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  // Caregiver information
  late TextEditingController caregiverFirstNameController;
  late TextEditingController caregiverLastNameController;

  // First page
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController dobController;
  late TextEditingController genderController;

  // Second page
  List<Family> familyMembers = [];
  late TextEditingController familyNameController;
  late TextEditingController familyDescriptionController;
  late TextEditingController relationController;
  File? familyImage;
  String familyImagePath = '';
  bool showImagePreview = false;

  // Third page
  List<Friend> friends = [];
  late TextEditingController friendNameController;
  late TextEditingController friendDescriptionController;
  File? friendImage;
  String friendImagePath = '';

  bool canProgress = false;

  @override
  void initState() {
    super.initState();
    caregiverFirstNameController = TextEditingController();
    caregiverLastNameController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    dobController = TextEditingController();
    genderController = TextEditingController();
    familyNameController = TextEditingController();
    relationController = TextEditingController();
    familyDescriptionController = TextEditingController();
    friendNameController = TextEditingController();
    friendDescriptionController = TextEditingController();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('yyyy-MMM-dd').format(picked);
      });
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introKey,
      showNextButton: true,
      showDoneButton: true,
      next: const Icon(Icons.arrow_forward, color: kPrimaryColor),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: kPrimaryColor,
        activeColor: kPrimaryLightColor,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      overrideDone: ElevatedButton(
        onPressed: () {
          if (caregiverFirstNameController.text.isEmpty ||
              caregiverLastNameController.text.isEmpty ||
              firstNameController.text.isEmpty ||
              lastNameController.text.isEmpty ||
              dobController.text.isEmpty) {
            _showSnackbar('Please fill in all required fields.');
            return;
          }

          try {
            DateTime dob = DateFormat('yyyy-MMM-dd').parse(dobController.text);
            Caregiver caregiver = Caregiver(
              firstName: caregiverFirstNameController.text,
              lastName: caregiverLastNameController.text,
              accountCreated: DateTime.now(),
            );
            CaregiverRepository().addCaregiver(caregiver);
            Patient patient = Patient(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              dob: dob,
              gender: genderController.text,
            );
            PatientRepository().addPatient(patient);
            for (Family family in familyMembers) {
              FamilyRepository().addFamilyMember(family);
            }
            for (Friend friend in friends) {
              FriendRepository().addFriend(friend);
            }
            Navigator.of(context).pushReplacementNamed('/home-caregiver');
          } catch (e) {
            _showSnackbar('Invalid date format. Please select a valid date.');
          }
        },
        child: const Text('Done'),
      ),
      onDone: () {
        if (caregiverFirstNameController.text.isEmpty ||
            caregiverLastNameController.text.isEmpty ||
            firstNameController.text.isEmpty ||
            lastNameController.text.isEmpty ||
            dobController.text.isEmpty) {
          _showSnackbar('Please fill in all required fields.');
          return;
        }

        try {
          DateTime dob = DateFormat('yyyy-MMM-dd').parse(dobController.text);
          Caregiver caregiver = Caregiver(
            firstName: caregiverFirstNameController.text,
            lastName: caregiverLastNameController.text,
            accountCreated: DateTime.now(),
          );
          CaregiverRepository().addCaregiver(caregiver);
          Patient patient = Patient(
            firstName: firstNameController.text,
            lastName: lastNameController.text,
            dob: dob,
            gender: genderController.text,
          );
          PatientRepository().addPatient(patient);
          for (Family family in familyMembers) {
            FamilyRepository().addFamilyMember(family);
          }
          for (Friend friend in friends) {
            FriendRepository().addFriend(friend);
          }
          Navigator.of(context).pushReplacementNamed('/home-caregiver');
        } catch (e) {
          _showSnackbar('Invalid date format. Please select a valid date.');
        }
      },
      pages: [
        // First page
        PageViewModel(
          title: 'Welcome to Memory Lane',
          decoration: PageDecoration(
            titleTextStyle: GoogleFonts.workSans(
              textStyle: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            bodyTextStyle: GoogleFonts.workSans(),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ease your loved one\'s Alzheimer\'s journey with our specialized app. To offer personalized support, we\'d like to gather some information about the patient.',
                  style: GoogleFonts.workSans(fontSize: 16),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.2),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Image(
                  image: AssetImage('assets/images/nursing-home.png'),
                ),
              ],
            ),
          ),
        ),
        PageViewModel(
          title: 'Caregiver Information',
          decoration: PageDecoration(
            titleTextStyle: GoogleFonts.workSans(
              textStyle: const TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            bodyTextStyle: GoogleFonts.workSans(),
          ),
          bodyWidget: Column(
            children: [
              Text(
                'Please provide your information to get started.',
                style: GoogleFonts.workSans(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Image(image: AssetImage('assets/images/stretches.png')),
              TextFormField(
                style: GoogleFonts.workSans(),
                controller: caregiverFirstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                style: GoogleFonts.workSans(),
                controller: caregiverLastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
            ],
          ),
        ),
        PageViewModel(
          title: 'Patient Personal Information',
          decoration: PageDecoration(
            titleTextStyle: GoogleFonts.workSans(
              textStyle: const TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            bodyTextStyle: GoogleFonts.workSans(),
          ),
          bodyWidget: Column(
            children: [
              Text(
                'Please provide the information about the patient you are caring for.',
                style: GoogleFonts.workSans(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const Image(
                  image: AssetImage('assets/images/mobility.png'),
                  height: 300.0),
              TextFormField(
                style: GoogleFonts.workSans(),
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextFormField(
                style: GoogleFonts.workSans(),
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextFormField(
                style: GoogleFonts.workSans(),
                controller: dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                onTap: () {
                  _selectDate(context);
                },
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Gender'),
                items: <String>['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    genderController.text = value!;
                  });
                },
              ),
            ],
          ),
        ),
        PageViewModel(
          title: 'Family Information',
          decoration: PageDecoration(
            titleTextStyle: GoogleFonts.workSans(
              textStyle: const TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            bodyTextStyle: GoogleFonts.workSans(),
          ),
          bodyWidget: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'We need some information about the patient\'s family to provide the best experience.',
                  style: GoogleFonts.workSans(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const Image(
                    image: AssetImage('assets/images/family.png'),
                    height: 220.0),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: familyNameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintStyle: GoogleFonts.workSans(),
                  ),
                ),
                TextFormField(
                  controller: relationController,
                  decoration: const InputDecoration(labelText: 'Relation'),
                ),
                TextFormField(
                  controller: familyDescriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description (optional)'),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: IconButton(
                      onPressed: () async {
                        familyImage = await pickImageFromGallery();
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image selected successfully'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                      iconSize: 48.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        familyImagePath =
                            await uploadFamilyImageForUser(familyImage!);
                        setState(() {
                          familyMembers.add(Family(
                            name: familyNameController.text,
                            relation: relationController.text,
                            imageURL: familyImagePath,
                            description: familyDescriptionController.text,
                          ));
                          familyNameController.clear();
                          relationController.clear();
                          familyDescriptionController.clear();
                          familyImage = null;
                          familyImagePath = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              kPrimaryColor,
                              kSecondaryColor,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Add Family Member',
                            style: GoogleFonts.workSans(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: familyMembers.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(
                          familyMembers[index].name,
                          style: GoogleFonts.workSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          familyMembers[index].relation,
                          style: GoogleFonts.workSans(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              deleteImageByPath(familyMembers[index].imageURL!);
                              familyMembers.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        PageViewModel(
          title: 'Friends Information',
          decoration: PageDecoration(
            titleTextStyle: GoogleFonts.workSans(
              textStyle: const TextStyle(
                fontSize: 29.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            bodyTextStyle: GoogleFonts.workSans(),
          ),
          bodyWidget: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'We need some information about the patient\'s friends to provide the best experience.',
                  style: GoogleFonts.workSans(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              const Image(
                  image: AssetImage('assets/images/friend.png'), height: 220.0),
              TextFormField(
                controller: friendNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintStyle: GoogleFonts.workSans(),
                ),
              ),
              TextFormField(
                controller: friendDescriptionController,
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: IconButton(
                    onPressed: () async {
                      friendImage = await pickImageFromGallery();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image selected successfully'),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.add_a_photo,
                    ),
                    iconSize: 48.0,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      friendImagePath =
                          await uploadFriendImageForUser(friendImage!);
                      setState(() {
                        friends.add(Friend(
                          name: friendNameController.text,
                          imageURL: friendImagePath,
                          description: friendDescriptionController.text,
                        ));
                        friendNameController.clear();
                        friendDescriptionController.clear();
                        friendImage = null;
                        friendImagePath = '';
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            kPrimaryColor,
                            kSecondaryColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'Add Friend',
                          style: GoogleFonts.workSans(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              ListView.builder(
                shrinkWrap: true,
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        friends[index].name,
                        style: GoogleFonts.workSans(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            deleteImageByPath(friends[index].imageURL!);
                            friends.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
