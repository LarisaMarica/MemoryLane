import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/repositories/event_repository.dart';
import 'package:licenta/screens/caregiver/modify_event_screen.dart';
import 'package:licenta/widgets/app_drawer_caregiver.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:licenta/models/event.dart';

class CalendarCaregiverScreen extends StatefulWidget {
  const CalendarCaregiverScreen({super.key});

  @override
  CalendarCaregiverScreenState createState() => CalendarCaregiverScreenState();
}

class CalendarCaregiverScreenState extends State<CalendarCaregiverScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<Event> _events = [];
  bool _isFetchingEvents = false;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isFetchingEvents = true;
    });
    try {
      final events = await EventsRepository().getEvents();
      if (mounted) {
        setState(() {
          _events = events;
          _isFetchingEvents = false;
        });
        debugPrint("Events fetched and state updated");
      }
    } catch (error) {
      debugPrint("Error fetching events: $error");
      if (mounted) {
        setState(() {
          _isFetchingEvents = false;
        });
      }
    }
  }


  Future<void> _modifyEvent(Event event) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyEventScreen(event: event),
      ),
    ).then((value) {
      if (value == true) {
        _fetchEvents();
      }
    });
  }


  void _deleteEvent(Event event) {
    if (mounted) {
      setState(() {
        _events.remove(event);
      });
      EventsRepository().deleteEvent(event);
    }
  }

  void _handlePopupMenuSelection(String value, Event event) {
    switch (value) {
      case 'delete':
        _showDeleteConfirmationDialog(event);
        break;
      case 'modify':
        _modifyEvent(event);
        break;
      default:
        break;
    }
  }

  void _showDeleteConfirmationDialog(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteEvent(event);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEvents() {
    final eventsForSelectedDay =
        _events.where((event) => isSameDay(event.date, _selectedDay)).toList();

    return ListView(
      children: <Widget>[
        const SizedBox(height: 20.0),
        if (eventsForSelectedDay.isEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No events for this day',
                style: GoogleFonts.workSans(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        for (final event in eventsForSelectedDay)
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 4,
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            'Title:',
                            style: GoogleFonts.workSans(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          subtitle: Text(
                            event.title,
                            style: GoogleFonts.workSans(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        if (event.description != "")
                          ListTile(
                            title: Text(
                              'Description:',
                              style: GoogleFonts.workSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              event.description ?? '',
                              style: GoogleFonts.workSans(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (event.isTimeAdded)
                          ListTile(
                            title: Text(
                              'Time:',
                              style: GoogleFonts.workSans(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('HH:mm').format(event.date),
                              style: GoogleFonts.workSans(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: PopupMenuButton<String>(
                        onSelected: (value) =>
                            _handlePopupMenuSelection(value, event),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                          const PopupMenuItem(
                            value: 'modify',
                            child: Text('Modify'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerCaregiver(),
      appBar: AppBar(
        title:
            Text('Calendar', style: GoogleFonts.workSans(color: Colors.white)),
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
      body: _isFetchingEvents
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: const CalendarStyle(
                    weekendTextStyle: TextStyle(
                      color: kPrimaryColor,
                    ),
                  ),
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2021, 1, 1),
                  lastDay: DateTime.utc(2024, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: (day) {
                    return _events
                        .where((event) => isSameDay(event.date, day))
                        .toList();
                  },
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Events for ${DateFormat('d MMMM yyyy').format(_selectedDay)}',
                  style: GoogleFonts.workSans(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Expanded(
                  child: _buildEvents(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/new-event').then((_) {
            _fetchEvents();
          });
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
