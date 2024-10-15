import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:licenta/games/number_game.dart';
import 'package:licenta/games/squares_game.dart';
import 'package:licenta/games/word_game.dart';
import 'package:licenta/screens/caregiver/calendar_caregiver_screen.dart';
import 'package:licenta/firebase/firebase_options.dart';
import 'package:licenta/screens/caregiver/games_statistics_screen.dart';
import 'package:licenta/screens/caregiver/health_stats_screen.dart';
import 'package:licenta/screens/caregiver/memory_caregiver_screen.dart';
import 'package:licenta/screens/caregiver/new_event_screen.dart';
import 'package:licenta/screens/caregiver/new_task_screen.dart';
import 'package:licenta/screens/caregiver/search_location_screen.dart';
import 'package:licenta/screens/caregiver/settings_caregiver.dart';
import 'package:licenta/screens/caregiver/map_caregiver_screen.dart';
import 'package:licenta/screens/caregiver/timetable_caregiver_screen.dart';
import 'package:licenta/screens/patient/calendar_patient_screen.dart';
import 'package:licenta/screens/patient/games_screen.dart';
import 'package:licenta/screens/caregiver/home_caregiver_screen.dart';
import 'package:licenta/screens/caregiver/quiz_screen.dart';
import 'package:licenta/screens/caregiver/login_screen.dart';
import 'package:licenta/screens/patient/biometric_screen.dart';
import 'package:licenta/screens/caregiver/register_screen.dart';
import 'package:licenta/screens/patient/home_patient_screen.dart';
import 'package:licenta/screens/patient/map_patient_screen.dart';
import 'package:licenta/screens/patient/memory_patient_screen.dart';
import 'package:licenta/screens/patient/timetable_patient_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:licenta/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const WelcomeScreen(),
    routes: {
      '/home-caregiver': (context) => const HomeCaregiverScreen(),
      '/home-patient': (context) => const HomePatientScreen(),
      '/login': (context) => const LoginScreen(),
      '/biometric': (context) => const BiometricScreen(),
      '/register': (context) => const RegisterScreen(),
      '/calendar-caregiver': (context) => const CalendarCaregiverScreen(),
      '/calendar-patient': (context) => const CalendarPatientScreen(),
      '/memory-caregiver': (context) => const MemoryCaregiverScreen(),
      '/memory-patient': (context) => const MemoryPatientScreen(),
      '/timetable-patient': (context) => const TimetablePatientScreen(),
      '/timetable-caregiver': (context) => const TimetableCaregiverScreen(),
      '/games': (context) => const GamesScreen(),
      '/games-statistics': (context) => const GamesStatisticScreen(),
      '/word-game': (context) => const WordGame(),
      '/number-game': (context) => const NumberGame(),
      '/squares-game': (context) => const SquaresGame(),
      '/quiz': (context) => const QuizScreen(),
      '/new-task': (context) => const NewTaskScreen(),
      '/new-event': (context) => const NewEventScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/welcome': (context) => const WelcomeScreen(),
      '/map-caregiver': (context) => const MapCaregiverScreen(),
      '/map-patient': (context) => const MapPatientScreen(),
      '/health-stats': (context) => const HealthStatisticsScreen(),
      '/search-location': (context) => const SearchLocationScreen(),
    },
  ));
}
