import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/word_game_result.dart';
import 'package:licenta/repositories/word_game_repository.dart';

class WordGame extends StatefulWidget {
  const WordGame({super.key});

  @override
  WordGameState createState() => WordGameState();
}

class WordGameState extends State<WordGame> {
  List<String> words = [];
  List<String> batch = [];
  Random random = Random();
  String currentWord = '';
  int score = 0;
  Set<String> displayedWords = {};
  bool isGameOver = false;
  bool isGameStarted = false;

  @override
  void initState() {
    initializeGame();
    super.initState();
  }

  Future<void> initializeGame() async {
    await loadWordList();
    selectRandomBatch();
    currentWord = getRandomWord();
  }

  Future<void> loadWordList() async {
    final ref = FirebaseStorage.instance.refFromURL(
        'gs://alzheimerapp-6c843.appspot.com/google-10000-english-usa-no-swears-long.txt');
    final data = await ref.getData();
    if (data != null) {
      final text = String.fromCharCodes(data);
      setState(() {
        words = text.trim().split('\n');
      });
    }
  }

  void selectRandomBatch() {
    final randomBatch = <String>{};
    while (randomBatch.length < 10) {
      final randomIndex = random.nextInt(words.length);
      randomBatch.add(words[randomIndex]);
    }
    batch = randomBatch.toList();
  }

  String getRandomWord() {
    String newWord;
    do {
      newWord = batch[random.nextInt(batch.length)];
    } while (newWord == currentWord);
    return newWord;
  }

  void newButtonPressed() {
    if (!displayedWords.contains(currentWord)) {
      setState(() {
        score++;
        displayedWords.add(currentWord);
        currentWord = getRandomWord();
      });
    } else {
      endGame();
    }
  }

  void seenButtonPressed() {
    if (displayedWords.contains(currentWord)) {
      setState(() {
        score++;
        displayedWords.add(currentWord);
        currentWord = getRandomWord();
      });
    } else {
      endGame();
    }
  }

  void endGame() {
    WordGameRepository()
        .addResult(WordGameResult(score: score, date: DateTime.now()));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game Over', style: GoogleFonts.workSans(fontSize: 25.0)),
          content: Text('Your score: $score',
              style: GoogleFonts.workSans(fontSize: 20.0)),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Play Again', style: GoogleFonts.workSans()),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  score = 0;
                  selectRandomBatch();
                  currentWord = getRandomWord();
                  displayedWords.clear();
                });
              },
            ),
            ElevatedButton(
              child: Text('Close', style: GoogleFonts.workSans()),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/games');
              },
            ),
          ],
        );
      },
    );
  }

  void showInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Instructions', style: GoogleFonts.workSans(fontSize: 25.0)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                    'Press "Seen" if you have seen the word before, press "New" if it is a new word.',
                    style: GoogleFonts.workSans(fontSize: 20.0)),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: GoogleFonts.workSans()),
            ),
          ],
        );
      },
    );
  }

  void startGame() {
    setState(() {
      isGameStarted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Verbal Memory Game',
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
        body: Center(
          child: isGameStarted
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentWord,
                      style: GoogleFonts.workSans(fontSize: 40.0),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: seenButtonPressed,
                          child: Text('Seen',
                              style: GoogleFonts.workSans(fontSize: 20.0)),
                        ),
                        const SizedBox(width: 20.0),
                        ElevatedButton(
                          onPressed: newButtonPressed,
                          child: Text('New',
                              style: GoogleFonts.workSans(fontSize: 20.0)),
                        ),
                      ],
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Press "Seen" if you have seen the word before, press "New" if it is a new word.',
                        style: GoogleFonts.workSans(fontSize: 25.0),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20.0),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Expanded(
                            child: ElevatedButton(
                              onPressed: startGame,
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
        ));
  }
}
