import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/event.dart';
import 'package:licenta/repositories/event_repository.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key});

  @override
  NewEventScreenState createState() => NewEventScreenState();
}

class NewEventScreenState extends State<NewEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _setTime = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a new event',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.workSans(color: Colors.black),
                ),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.workSans(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                    "Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                    style: GoogleFonts.workSans(fontSize: 20)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const Divider(),
              CheckboxListTile(
                title: Text('Do you want to set a time for this event?',
                    style: GoogleFonts.workSans(fontSize: 20)),
                value: _setTime,
                onChanged: (value) {
                  setState(() {
                    _setTime = value!;
                  });
                },
              ),
              if (_setTime)
                ListTile(
                  title: Text("Time: ${_selectedTime.format(context)}",
                      style: GoogleFonts.workSans(fontSize: 20)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_titleController.text.isNotEmpty) {
                        _addNewEvent();
                        Navigator.pop(
                            context); 
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryLightColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 10.0),
                    ),
                    child: Text(
                      'Save Changes',
                      style: GoogleFonts.workSans(
                          fontSize: 17, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _addNewEvent() async {
    Event newEvent = Event(
      title: _titleController.text,
      description: _descriptionController.text,
      isTimeAdded: _setTime,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
    );
    await EventsRepository().addEvent(newEvent);
  }
}
