import 'dart:io';

import 'package:flutter/material.dart';
import 'package:licenta/firebase/utils.dart';
import 'package:licenta/models/family.dart';
import 'package:licenta/repositories/family_repository.dart';

class AddFamilyMemberDialog extends StatefulWidget {
  final Function(dynamic member) onSave;

  const AddFamilyMemberDialog({required this.onSave, super.key});

  @override
  AddFamilyMemberDialogState createState() => AddFamilyMemberDialogState();
}

class AddFamilyMemberDialogState extends State<AddFamilyMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _relation = '';
  String _description = '';
  File? _familyImage;
  String familyImagePath = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Family Member'),
      content: Form(
        key: _formKey,
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
                  _name = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                    labelText:
                        'Relation (e.g. son, daughter, spouse, etc.)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a relation';
                  }
                  return null;
                },
                onSaved: (value) {
                  _relation = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                onSaved: (value) {
                  _description = value!;
                },
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: IconButton(
                    onPressed: () async {
                      _familyImage = await pickImageFromGallery();
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
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              familyImagePath = await uploadFamilyImageForUser(_familyImage!);
              final member = Family(
                name: _name,
                relation: _relation,
                description: _description,
                imageURL: familyImagePath,
              );
              FamilyRepository().addFamilyMember(member);
              widget.onSave(member);
              // ignore: use_build_context_synchronously
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}
