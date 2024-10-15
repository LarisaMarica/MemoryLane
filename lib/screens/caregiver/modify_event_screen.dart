import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/event.dart';
import 'package:licenta/repositories/event_repository.dart';

class ModifyEventScreen extends StatefulWidget {
  final Event event;

  const ModifyEventScreen({required this.event, super.key});

  @override
  ModifyEventScreenState createState() => ModifyEventScreenState();
}

class ModifyEventScreenState extends State<ModifyEventScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late bool _setTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _selectedDate = widget.event.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.date);
    _setTime = widget.event.isTimeAdded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Modify Event', style: TextStyle(color: Colors.white)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveChanges();
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

  void _saveChanges() async {
    Event updatedEvent = Event(
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
    await EventsRepository().updateEvent(widget.event, updatedEvent);

    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(true);
  }
}
