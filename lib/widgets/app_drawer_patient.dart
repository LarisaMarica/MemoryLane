import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';

class AppDrawerPatient extends StatelessWidget {
  const AppDrawerPatient({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.of(context).pushReplacementNamed(routeName);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Memory Lane', style: GoogleFonts.workSans()),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text('Home', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/home-patient'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: Text('Calendar', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/calendar-patient'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text('Timetable', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/timetable-patient'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map),
            title: Text('Map', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/map-patient'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.games),
            title: Text('Games', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/games'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.memory),
            title: Text('Memory Book', style: GoogleFonts.workSans()),
            onTap: () => _navigateTo(context, '/memory-patient'),
          ),
        ],
      ),
    );
  }
}
