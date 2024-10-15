import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/task.dart';
import 'package:licenta/repositories/task_repository.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  NewTaskScreenState createState() => NewTaskScreenState();
}

class NewTaskScreenState extends State<NewTaskScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late DateTime selectedDate = DateTime.now();
  late TimeOfDay selectedTime = TimeOfDay.now();
  bool repeatDaily = true;
  bool repeatWeekly = false;
  DateTime? specificDay;

  List<String> categories = [
    'Personal',
    'Shopping',
    'Health',
    'Home',
    'Hygiene',
    'Other'
  ];
  String? selectedCategory;
  List<bool> selectedDays = List.generate(7, (index) => false);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a new task',
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: GoogleFonts.workSans(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: GoogleFonts.workSans(color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                items: categories.map((String category) {
                  IconData icon;
                  switch (category) {
                    case 'Personal':
                      icon = Icons.person;
                      break;
                    case 'Shopping':
                      icon = Icons.shopping_cart;
                      break;
                    case 'Health':
                      icon = Icons.medical_services;
                      break;
                    case 'Home':
                      icon = Icons.home;
                      break;
                    case 'Hygiene':
                      icon = Icons.bathtub;
                      break;
                    default:
                      icon = Icons.lock_clock;
                      break;
                  }
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Icon(icon),
                        const SizedBox(width: 10),
                        Text(category, style: GoogleFonts.workSans()),
                      ],
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: GoogleFonts.workSans(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text("Select Time: ${selectedTime.format(context)}",
                    style: GoogleFonts.workSans(fontSize: 20)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const Divider(),
              CheckboxListTile(
                title: Text("Repeat Every Day",
                    style: GoogleFonts.workSans(fontSize: 20)),
                value: repeatDaily,
                onChanged: (bool? value) {
                  setState(() {
                    repeatDaily = value ?? false;
                    if (repeatDaily) {
                      repeatWeekly = false;
                      specificDay = null;
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: Text("Repeat Every Week",
                    style: GoogleFonts.workSans(fontSize: 20)),
                value: repeatWeekly,
                onChanged: (bool? value) {
                  setState(() {
                    repeatWeekly = value ?? false;
                    if (repeatWeekly) {
                      repeatDaily = false;
                      specificDay = null;
                    }
                  });
                },
              ),
              if (repeatWeekly) ...[
                const SizedBox(height: 10),
                Text("Repeat on Specific Days:",
                    style: GoogleFonts.workSans(fontSize: 18)),
                CheckboxListTile(
                  title: Text("Monday", style: GoogleFonts.workSans()),
                  value: selectedDays[0],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[0] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Tuesday", style: GoogleFonts.workSans()),
                  value: selectedDays[1],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[1] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Wednesday", style: GoogleFonts.workSans()),
                  value: selectedDays[2],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[2] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Thursday", style: GoogleFonts.workSans()),
                  value: selectedDays[3],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[3] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Friday", style: GoogleFonts.workSans()),
                  value: selectedDays[4],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[4] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Saturday", style: GoogleFonts.workSans()),
                  value: selectedDays[5],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[5] = value ?? false;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text("Sunday", style: GoogleFonts.workSans()),
                  value: selectedDays[6],
                  onChanged: (value) {
                    setState(() {
                      selectedDays[6] = value ?? false;
                    });
                  },
                ),
              ],
              ListTile(
                title: Text("Specific Day: ", style: GoogleFonts.workSans()),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected date: ${selectedDate.toString().substring(0, 10)}',
                style: GoogleFonts.workSans(),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                          ),
                        );
                        return;
                      }
                      await _saveTask();
                      Navigator.pop(context);
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

  Future<void> _saveTask() async {
    if (titleController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    Task task = Task(
      title: titleController.text,
      category: selectedCategory ?? 'Other',
      description: descriptionController.text,
      doneDates: {},
      repeatDaily: repeatDaily,
      repeatWeekly: repeatWeekly,
      specificDays: selectedDays,
      date: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );
    print('Saving task: ${task.title}');

    await TaskRepository().addTask(task);

    print('Task saved successfully');
  }
}
