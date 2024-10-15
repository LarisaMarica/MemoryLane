import 'dart:io';

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
import 'package:licenta/widgets/app_drawer_caregiver.dart';

class MemoryCaregiverScreen extends StatefulWidget {
  const MemoryCaregiverScreen({super.key});

  @override
  MemoryCaregiverScreenState createState() => MemoryCaregiverScreenState();
}

class MemoryCaregiverScreenState extends State<MemoryCaregiverScreen> {
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

  // Handle popup menu selection
  void _handlePopupMenuSelection(String value) {
    switch (value) {
      case 'family':
        showDialog(
          context: context,
          builder: (context) => _addFamilyMemeber(),
        );
        break;
      case 'friend':
        showDialog(
          context: context,
          builder: (context) => _addFriend(),
        );
        break;
    }
  }

  AlertDialog _addFamilyMemeber() {
    String name = '';
    String relation = '';
    String description = '';
    File? familyImage;
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Add New Family Member'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Relation (e.g. son, daughter, spouse, etc.)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a relation';
                  }
                  return null;
                },
                onSaved: (value) {
                  relation = value!;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
                onSaved: (value) {
                  description = value!;
                },
              ),
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
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            String familyImagePath =
                await uploadFamilyImageForUser(familyImage!);
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              final familyMember = Family(
                name: name,
                relation: relation,
                description: description,
                imageURL: familyImagePath,
              );
              FamilyRepository().addFamilyMember(familyMember).then((_) {
                Navigator.of(context).pop();
                _fetchFamilyMembers();
              });
            }
          },
        ),
      ],
    );
  }

  AlertDialog _addFriend() {
    String name = '';
    String description = '';
    File? friendImage;
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      title: const Text('Add New Friend'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Description (optional)'),
                onSaved: (value) {
                  description = value!;
                },
              ),
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
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () async {
            String friendImagePath =
                await uploadFriendImageForUser(friendImage!);
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              final friend = Friend(
                name: name,
                description: description,
                imageURL: friendImagePath,
              );
              FriendRepository().addFriend(friend).then((_) {
                Navigator.of(context).pop();
                _fetchFriends();
              });
            }
          },
        ),
      ],
    );
  }

  void _deleteFamilyMember(String familyMemberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this family member?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              await FamilyRepository().deleteFamilyMember(familyMemberId);
              _fetchFamilyMembers();
            },
          ),
        ],
      ),
    );
  }

  void _deleteFriend(String friendId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this friend?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () async {
              Navigator.of(context).pop();
              await FriendRepository().deleteFriend(friendId);
              _fetchFriends();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerCaregiver(),
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
      body: Stack(
        children: [
          SingleChildScrollView(
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
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: PopupMenuButton<String>(
                onSelected: _handlePopupMenuSelection,
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'family',
                    child: Text('Add Family Member'),
                  ),
                  const PopupMenuItem(
                    value: 'friend',
                    child: Text('Add Friend'),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name: ${familyMember.name}',
                              style: GoogleFonts.workSans(fontSize: 20),
                              overflow:
                                  TextOverflow.ellipsis, 
                            ),
                            Text('Relation: ${familyMember.relation}',
                                style: GoogleFonts.workSans(fontSize: 20)),
                            if (familyMember.description!.isNotEmpty)
                              Text('Description: ${familyMember.description}',
                                  style: GoogleFonts.workSans(fontSize: 20),
                                  overflow:
                                      TextOverflow.ellipsis, 
                                  maxLines: 2), 
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteFamilyMember(familyMember.id!);
                        },
                      ),
                    ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: ${friend.name}',
                            style: GoogleFonts.workSans(fontSize: 20),
                            overflow:
                                TextOverflow.ellipsis,
                          ),
                          if (friend.description != null &&
                              friend.description!.isNotEmpty)
                            Text('Description: ${friend.description}',
                                style: GoogleFonts.workSans(fontSize: 20),
                                overflow:
                                    TextOverflow.ellipsis,
                                    maxLines: 2),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteFriend(friend.id!);
                        },
                      ),
                    ],
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
                              style: TextStyle(
                                  fontSize: 20, fontStyle: FontStyle.italic));
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
