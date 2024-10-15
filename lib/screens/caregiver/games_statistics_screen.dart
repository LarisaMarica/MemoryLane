import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/number_game_result.dart';
import 'package:licenta/models/squares_game_result.dart';
import 'package:licenta/models/word_game_result.dart';
import 'package:licenta/repositories/number_game_repository.dart';
import 'package:licenta/repositories/squares_game_repository.dart';
import 'package:licenta/repositories/word_game_repository.dart';
import 'package:licenta/widgets/app_drawer_caregiver.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class GamesStatisticScreen extends StatefulWidget {
  const GamesStatisticScreen({super.key});

  @override
  GamesStatisticScreenState createState() => GamesStatisticScreenState();
}

class GamesStatisticScreenState extends State<GamesStatisticScreen> {
  late List<NumberGameResult> numberGameResults = [];
  late List<WordGameResult> wordGameResults = [];
  late List<SquaresGameResult> squaresGameResults = [];

  @override
  void initState() {
    super.initState();
    // Fetch game results
    NumberGameRepository().getResults().then((value) {
      setState(() {
        numberGameResults = value;
      });
    });
    WordGameRepository().getResults().then((value) {
      setState(() {
        wordGameResults = value;
      });
    });
    SquaresGameRepository().getResults().then((value) {
      setState(() {
        squaresGameResults = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Statistics',
            style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGameStatistic(
              title: 'Number Game Statistics',
              gameResults: numberGameResults,
              color: Colors.blue, 
            ),
            const SizedBox(height: 20),
            _buildGameStatistic(
              title: 'Verbal Game Statistics',
              gameResults: wordGameResults,
              color: Colors.green, 
            ),
            const SizedBox(height: 20),
            _buildGameStatistic(
              title: 'Squares Game Statistics',
              gameResults: squaresGameResults,
              color: Colors.orange, 
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStatistic({
    required String title,
    required List<dynamic> gameResults,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              GoogleFonts.workSans(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (gameResults.isNotEmpty) ...[
          _buildChart(gameResults, color),
          const SizedBox(height: 10),
          _buildSummaryStatistics(gameResults),
        ] else ...[
          const Text('No data available'),
        ],
      ],
    );
  }

  Widget _buildChart(List<dynamic> gameResults, Color color) {
    List<_GameData> chartData = gameResults
        .map((result) => _GameData(
              DateFormat('yyyy-MM-dd').format(result.date), 
              result.score,
            ))
        .toList();

    return SfCartesianChart(
      primaryXAxis: const CategoryAxis(
        title: AxisTitle(text: 'Date'),
        labelRotation: 45,
      ),
      primaryYAxis: const NumericAxis(
        title: AxisTitle(text: 'Score'),
        minimum: 0,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<dynamic, dynamic>>[
        LineSeries<_GameData, String>(
          dataSource: chartData,
          xValueMapper: (_GameData data, _) => data.date,
          yValueMapper: (_GameData data, _) => data.score,
          color: color,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  Widget _buildSummaryStatistics(List<dynamic> gameResults) {
    var filteredResults =
        gameResults.where((result) => result.score > 0).toList();

    int totalScores = filteredResults.fold<int>(
        0, (sum, result) => sum + (result.score as int));
    double averageScore =
        filteredResults.isNotEmpty ? totalScores / filteredResults.length : 0;
    int maxScore = filteredResults.isNotEmpty
        ? filteredResults
            .map((result) => result.score)
            .reduce((max, score) => max > score ? max : score)
        : 0;
    int minScore = filteredResults.isNotEmpty
        ? filteredResults
            .map((result) => result.score)
            .reduce((min, score) => min < score ? min : score)
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary Statistics:',
            style: GoogleFonts.workSans(
                fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Total Games: ${gameResults.length}',
            style: GoogleFonts.workSans(fontSize: 20)),
        Text('Average Score: ${averageScore.toStringAsFixed(2)}',
            style: GoogleFonts.workSans(fontSize: 20)),
        Text('Maximum Score: $maxScore',
            style: GoogleFonts.workSans(fontSize: 20)),
        Text('Minimum Score: $minScore',
            style: GoogleFonts.workSans(fontSize: 20)),
      ],
    );
  }
}

class _GameData {
  _GameData(this.date, this.score);

  final String date;
  final int score;
}
