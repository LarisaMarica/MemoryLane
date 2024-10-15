import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/squares_game_result.dart';
import 'package:licenta/repositories/squares_game_repository.dart';

class SquaresGame extends StatefulWidget {
  const SquaresGame({super.key});

  @override
  SquaresGameState createState() => SquaresGameState();
}

class SquaresGameState extends State<SquaresGame> {
  late List<bool> squares;
  late int numberOfSquares;
  int lives = 3;
  List<int> litSquares = [];
  bool gameStarted = false;
  bool gameEnded = false;
  int score = 0;
  int currentLevel = 1;
  late Random random;
  bool _isGameStarted = false;

  @override
  void initState() {
    super.initState();
    numberOfSquares = _getCrossAxisCount() * _getCrossAxisCount();
    squares = List.filled(numberOfSquares, false);
    random = Random();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visual Memory Game',
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
      body: _isGameStarted ? _buildGameView() : _buildInstructions(),
    );
  }

  Widget _buildInstructions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Memorize the positions of the lit squares. Tap the squares you remember being lit. The number of squares will increase with each level.',
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

  Widget _buildGameView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
            ),
            itemCount: squares.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  if (gameStarted && !gameEnded) {
                    setState(() {
                      squares[index] = !squares[index];
                    });
                    if (squares[index]) {
                      if (litSquares.contains(index)) {
                        score++;
                        if (score == litSquares.length) {
                          _advanceToNextLevel();
                        }
                      } else {
                        _handleGameOver();
                      }
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(2),
                  color: squares[index] ? kSecondaryColor : Colors.grey,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount() {
    if (currentLevel <= 2) {
      return 3;
    } else if (currentLevel <= 4) {
      return 4;
    } else if (currentLevel <= 6) {
      return 5;
    } else {
      return 6;
    }
  }

  void startGame() {
    setState(() {
      _isGameStarted = true;
      gameStarted = true;
      gameEnded = false;
      score = 0;
      litSquares = _generateLitSquares();
      numberOfSquares = _getCrossAxisCount() * _getCrossAxisCount();

      squares = List.filled(numberOfSquares, false);
      for (int index in litSquares) {
        squares[index] = true;
      }

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          squares = List.filled(numberOfSquares, false);
        });
      });
    });
  }

  List<int> _generateLitSquares() {
    List<int> litSquares = [];
    while (litSquares.length < numberOfSquares ~/ 2 + currentLevel) {
      int index = random.nextInt(numberOfSquares);
      if (!litSquares.contains(index)) {
        litSquares.add(index);
      }
    }
    return litSquares;
  }

  void _advanceToNextLevel() {
    setState(() {
      currentLevel++;
      startGame();
    });
  }

  void _handleGameOver() {
    SquaresGameRepository().addResult(SquaresGameResult(
      score: currentLevel - 1,
      date: DateTime.now(),
    ));
    gameEnded = true;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over', style: GoogleFonts.workSans()),
          content: Text('Your score: ${currentLevel - 1}',
              style: GoogleFonts.workSans()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
              child: Text('Play Again', style: GoogleFonts.workSans()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Exit', style: GoogleFonts.workSans()),
            )
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      gameStarted = false;
      _isGameStarted = false;
      currentLevel = 1; 
    });
  }
}
