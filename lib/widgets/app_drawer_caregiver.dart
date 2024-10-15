import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';

class AppDrawerCaregiver extends StatelessWidget {
  const AppDrawerCaregiver({super.key});

  void _navigateTo(BuildContext context, String routeName) {
    if (ModalRoute.of(context)?.settings.name != routeName) {
      Navigator.of(context).pushReplacementNamed(routeName);
    } else {
      Navigator.of(context)
          .pop();
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
            title: const Text('Home'),
            onTap: () => _navigateTo(context, '/home-caregiver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Calendar'),
            onTap: () => _navigateTo(context, '/calendar-caregiver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Timetable'),
            onTap: () => _navigateTo(context, '/timetable-caregiver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Map'),
            onTap: () => _navigateTo(context, '/map-caregiver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.games),
            title: const Text('Games Statistics'),
            onTap: () => _navigateTo(context, '/games-statistics'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.memory),
            title: const Text('Memory Book'),
            onTap: () => _navigateTo(context, '/memory-caregiver'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Account Details'),
            onTap: () => _navigateTo(context, '/settings'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => _navigateTo(context, '/welcome'),
          ),
        ],
      ),
    );
  }
}
