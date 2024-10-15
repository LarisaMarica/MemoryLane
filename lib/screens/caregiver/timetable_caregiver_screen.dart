import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/task.dart';
import 'package:licenta/repositories/task_repository.dart';
import 'package:licenta/widgets/app_drawer_caregiver.dart';

class TimetableCaregiverScreen extends StatefulWidget {
  const TimetableCaregiverScreen({super.key});

  @override
  TimetableCaregiverScreenState createState() =>
      TimetableCaregiverScreenState();
}

class TimetableCaregiverScreenState extends State<TimetableCaregiverScreen> {
  DateTime _selectedDate = DateTime.now();
  late List<Task> _tasks = [];
  final TaskRepository _tasksRepository = TaskRepository();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final tasks = await _tasksRepository.getTasks();
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching tasks: $e');
    }
  }

  List<Task> getTasksForSelectedDate(DateTime selectedDate) {
    List<Task> filteredTasks = _tasks.where((task) {
      if (task.repeatDaily) {
        return true;
      } else if (task.repeatWeekly) {
        return task.specificDays[selectedDate.weekday - 1];
      } else {
        return task.date.year == selectedDate.year &&
            task.date.month == selectedDate.month &&
            task.date.day == selectedDate.day;
      }
    }).toList();

    filteredTasks.sort((a, b) => a.date.hour.compareTo(b.date.hour));

    return filteredTasks;
  }

  Icon buildIcon(Task task) {
    Icon icon = const Icon(Icons.lock_clock, color: Colors.black45);

    switch (task.category) {
      case 'Hygiene':
        icon = const Icon(Icons.bathtub, color: Colors.black45);
        break;
      case 'Health':
        icon = const Icon(Icons.medical_services, color: Colors.black45);
        break;
      case 'Home':
        icon = const Icon(Icons.home, color: Colors.black45);
        break;
      case 'Personal':
        icon = const Icon(Icons.person, color: Colors.black45);
        break;
      case 'Shopping':
        icon = const Icon(Icons.shopping_cart, color: Colors.black45);
        break;
      default:
        icon = const Icon(Icons.lock_clock, color: Colors.black45);
        break;
    }

    return icon;
  }

  Map<String, Color> categoryColors = {
    'Hygiene': const Color.fromARGB(255, 197, 230, 245), // Light Blue
    'Health': const Color(0xFFC8E6C9), // Light Green
    'Home': const Color(0xFFFFF59D), // Light Yellow
    'Personal': const Color.fromARGB(255, 212, 200, 237), // Light Purple
    'Shopping': const Color(0xFFFFCCBC), // Light Orange
  };

  Card buildEventCard(Task task) {
    Color cardColor = categoryColors.containsKey(task.category)
        ? categoryColors[task.category]!
        : Colors.grey;

    bool isTaskDoneForSelectedDate = false;
    Map<String, bool> doneDates = task.doneDates;
    String formattedSelectedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    for(String key in doneDates.keys) {
      String formattedKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(key));
      if(formattedKey == formattedSelectedDate) {
        if(doneDates[key] == true) {
          isTaskDoneForSelectedDate = true;
        }
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: cardColor,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isTaskDoneForSelectedDate)
                  const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                buildIcon(task),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: GoogleFonts.workSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(task);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${task.category}',
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${DateFormat('HH:mm').format(task.date)}',
              style: GoogleFonts.workSans(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            if (task.description != null && task.description != '')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Description: ${task.description}',
                    style: GoogleFonts.workSans(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasks() {
    final tasksForSelectedDate = getTasksForSelectedDate(_selectedDate);

    return ListView(
      children: <Widget>[
        const SizedBox(height: 8),
        if (tasksForSelectedDate.isEmpty)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'No tasks for this date.',
                  style: GoogleFonts.workSans(fontSize: 18),
                ),
              ),
            ),
          ),
        for (Task task in tasksForSelectedDate) buildEventCard(task),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Timetable', style: GoogleFonts.workSans(color: Colors.white)),
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
      body: Column(
        children: <Widget>[
          EasyDateTimeLine(
            initialDate: DateTime.now(),
            onDateChange: (selectedDate) {
              setState(() {
                _selectedDate = selectedDate;
              });
            },
            headerProps: const EasyHeaderProps(
                monthPickerType: MonthPickerType.switcher,
                dateFormatter: DateFormatter.fullDateDMonthAsStrY()),
            dayProps: const EasyDayProps(
              dayStructure: DayStructure.dayStrDayNum,
              activeDayStyle: DayStyle(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kPrimaryColor,
                      kSecondaryColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildTasks(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/new-task');
          await _fetchTasks();
          setState(() {}); 
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteTask(Task task) async {
    await _tasksRepository.deleteTask(task);
    await _fetchTasks();
    setState(() {}); 
  }
}
