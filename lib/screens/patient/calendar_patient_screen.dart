import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/repositories/event_repository.dart';
import 'package:licenta/widgets/app_drawer_patient.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:licenta/models/event.dart';

class CalendarPatientScreen extends StatefulWidget {
  const CalendarPatientScreen({super.key});

  @override
  CalendarPatientScreenState createState() => CalendarPatientScreenState();
}

class CalendarPatientScreenState extends State<CalendarPatientScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    EventsRepository().getEvents().then((events) {
      setState(() {
        _events = events;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerPatient(),
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
      body: Column(
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
                        const Divider(),
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
                        if (event.isTimeAdded) const Divider(),
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
                ],
              ),
            ),
          ),
      ],
    );
  }
}
