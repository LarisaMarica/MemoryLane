import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/widgets/app_drawer_patient.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawerPatient(),
      appBar: AppBar(
        title: Text('Games', style: GoogleFonts.workSans(color: Colors.white)),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              Center(
                child: Text(
                  'These games will help you improve your memory.\n Have fun!',
                  style: GoogleFonts.workSans(
                    fontSize: 24.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20.0),
              buildGameCard(
                context,
                title: 'Verbal Memory Game',
                instructions:
                    'You will be shown a word, one at a time. If you\'ve seen the word before, tap "Seen". If you haven\'t seen the word before, tap "New".',
                routeName: '/word-game',
              ),
              const SizedBox(height: 20.0),
              buildGameCard(
                context,
                title: 'Number Memory Game',
                instructions:
                    'You will be shown a number for a few seconds and you have to remember it. After that, you have to enter the number you just saw.',
                routeName: '/number-game',
              ),
              const SizedBox(height: 20.0),
              buildGameCard(
                context,
                title: 'Visual Memory Game',
                instructions:
                    'Memorize the positions of the lit squares. Tap the squares you remember being lit. The number of squares will increase with each level.',
                routeName: '/squares-game',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildGameCard(BuildContext context,
      {required String title,
      required String instructions,
      required String routeName}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  title,
                  style: GoogleFonts.workSans(
                      fontSize: 25.0, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12.0),
              Text(instructions, style: GoogleFonts.workSans(fontSize: 20.0)),
              const SizedBox(height: 20.0),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(routeName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryLightColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70.0, vertical: 12.0),
                      ),
                      child: Text(
                        'Play Game',
                        style: GoogleFonts.workSans(
                            fontSize: 18, color: Colors.black),
                      ),
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
}
