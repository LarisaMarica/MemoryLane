import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/number_game_result.dart';
import 'package:licenta/repositories/number_game_repository.dart';
import 'package:linear_timer/linear_timer.dart';

class NumberGame extends StatefulWidget {
  const NumberGame({super.key});

  @override
  NumberGameState createState() => NumberGameState();
}

class NumberGameState extends State<NumberGame> {
  Timer? _timer;
  bool _showNumber = true;
  bool _isGameStarted = false;
  int level = 0;
  int randomNumber = 0;
  TextEditingController numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startNewLevel() {
    setState(() {
      randomNumber = generateRandomNumber(level);
      _showNumber = true;
      _timer = Timer(Duration(seconds: 2 + level), () {
        setState(() {
          _showNumber = false;
        });
      });
    });
  }

  int generateRandomNumber(int level) {
    final random = Random();
    final minValue = pow(10, level).toInt();
    final maxValue = pow(10, level + 1).toInt() - 1;
    return minValue + random.nextInt(maxValue - minValue + 1);
  }

  void startGame() {
    setState(() {
      _isGameStarted = true;
      startNewLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Memory Game',
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
      body: _isGameStarted
          ? Center(
              child: _showNumber
                  ? _showNumberWidget(randomNumber)
                  : _guessNumberWidget(randomNumber),
            )
          : _showInstructions(),
    );
  }

  Widget _showInstructions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Memorize the number displayed and enter it correctly. The number will be shown for a short duration.',
            style: GoogleFonts.workSans(fontSize: 25.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryLightColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 70.0, vertical: 12.0),
            ),
            child: Text(
              'Start Game',
              style: GoogleFonts.workSans(fontSize: 18, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showNumberWidget(int number) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Memorize the number:',
          style: GoogleFonts.workSans(fontSize: 20.0),
        ),
        const SizedBox(height: 20.0),
        Text(
          number.toString(),
          style:
              GoogleFonts.workSans(fontSize: 40.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20.0),
        LinearTimer(
          duration: Duration(seconds: 2 + level),
          color: kPrimaryColor,
        ),
      ],
    );
  }

  Widget _guessNumberWidget(int number) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Enter the number you saw:',
          style: GoogleFonts.workSans(fontSize: 20.0),
        ),
        const SizedBox(height: 20.0),
        TextField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style:
              GoogleFonts.workSans(fontSize: 40.0, fontWeight: FontWeight.bold),
          controller: numberController,
        ),
        const SizedBox(height: 20.0),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kSecondaryLightColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 10.0),
            ),
            onPressed: () {
              int guessedNumber = int.parse(numberController.text);
              if (isNumberGuessed(number, guessedNumber)) {
                level++;
                startNewLevel();
                numberController.clear();
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Wrong number!',
                          style: GoogleFonts.workSans(fontSize: 25.0)),
                      content: Text('Your final score is: $level',
                          style: GoogleFonts.workSans(fontSize: 20.0)),
                      actions: [
                        TextButton(
                          onPressed: () {
                            NumberGameResult result = NumberGameResult(
                              score: level,
                              date: DateTime.now(),
                            );
                            NumberGameRepository().addResult(result);
                            Navigator.of(context)
                                .pushReplacementNamed('/games');
                          },
                          child: Text('OK', style: GoogleFonts.workSans()),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            child: Text('Submit',
                style:
                    GoogleFonts.workSans(fontSize: 20.0, color: Colors.black)),
          ),
        ),
      ],
    );
  }

  bool isNumberGuessed(int number, int guessedNumber) {
    return number == guessedNumber;
  }
}
