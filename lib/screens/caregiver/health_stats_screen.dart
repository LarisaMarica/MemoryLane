import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:licenta/constants.dart';
import 'package:licenta/models/medical_data.dart';
import 'package:licenta/repositories/medical_data_repository.dart';

class HealthStatisticsScreen extends StatefulWidget {
  const HealthStatisticsScreen({super.key});

  @override
  HealthStatisticsScreenState createState() => HealthStatisticsScreenState();
}

class HealthStatisticsScreenState extends State<HealthStatisticsScreen> {
  List<MedicalData> medicalDataEntries = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicalData();
  }

  Future<void> _fetchMedicalData() async {
    final allMedicalData = await MedicalDataRepository().getAllMedicalData();
    setState(() {
      medicalDataEntries = allMedicalData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Statistics',
          style: GoogleFonts.workSans(
            fontSize: 24.0,
            color: Colors.white,
          ),
        ),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMoodChart(),
            _buildBloodPressureChart(),
            const SizedBox(height: 16.0),
            Text(
              'Blood Pressure Statistics',
              style: GoogleFonts.workSans(
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Highest: ${_getHighestBloodPressure()}',
              style: GoogleFonts.workSans(
                fontSize: 18.0,
              ),
            ),
            Text(
              'Lowest: ${_getLowestBloodPressure()}',
              style: GoogleFonts.workSans(
                fontSize: 18.0,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildPulseChart(),
            const SizedBox(height: 16.0),
            Text(
              'Pulse Statistics',
              style: GoogleFonts.workSans(
                fontSize: 24.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Highest Pulse: ${_getHighestPulse()}',
              style: GoogleFonts.workSans(
                fontSize: 18.0,
              ),
            ),
            Text(
              'Lowest Pulse: ${_getLowestPulse()}',
              style: GoogleFonts.workSans(
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodPressureChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              interval: 1,
              labelIntersectAction: AxisLabelIntersectAction.rotate45,
              labelStyle: GoogleFonts.workSans(),
            ),
            series: <LineSeries<MedicalData, String>>[
              LineSeries<MedicalData, String>(
                dataSource: medicalDataEntries,
                xValueMapper: (MedicalData data, _) => data.date,
                yValueMapper: (MedicalData data, _) => data.systolic,
                name: 'Systolic',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
              LineSeries<MedicalData, String>(
                dataSource: medicalDataEntries,
                xValueMapper: (MedicalData data, _) => data.date,
                yValueMapper: (MedicalData data, _) => data.diastolic,
                name: 'Diastolic',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
            legend: const Legend(isVisible: true),
            title: ChartTitle(
                text: 'Blood Pressure Over Time',
                textStyle: GoogleFonts.workSans(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                )),
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ],
    );
  }

  Widget _buildPulseChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              interval: 1,
              labelIntersectAction: AxisLabelIntersectAction.rotate45,
              labelStyle: GoogleFonts.workSans(),
            ),
            series: <LineSeries<MedicalData, String>>[
              LineSeries<MedicalData, String>(
                dataSource: medicalDataEntries,
                xValueMapper: (MedicalData data, _) => data.date,
                yValueMapper: (MedicalData data, _) => data.pulse,
                name: 'Pulse',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
            legend: const Legend(isVisible: true),
            title: ChartTitle(
                text: 'Pulse Over Time',
                textStyle: GoogleFonts.workSans(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                )),
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
      ],
    );
  }

  _getHighestBloodPressure() {
    if (medicalDataEntries.isNotEmpty) {
      final entryWithHighestSystolic =
          medicalDataEntries.reduce((a, b) => a.systolic > b.systolic ? a : b);
      final highestSystolic = entryWithHighestSystolic.systolic;
      final correspondingDiastolic = entryWithHighestSystolic.diastolic;
      return '$highestSystolic / $correspondingDiastolic mmHg';
    } else {
      return null;
    }
  }

  _getLowestBloodPressure() {
    if (medicalDataEntries.isNotEmpty) {
      final filteredEntries = medicalDataEntries
          .where((entry) => entry.systolic != 0 && entry.diastolic != 0)
          .toList();

      if (filteredEntries.isNotEmpty) {
        final entryWithLowestSystolic =
            filteredEntries.reduce((a, b) => a.systolic < b.systolic ? a : b);

        final lowestSystolic = entryWithLowestSystolic.systolic;
        final correspondingDiastolic = entryWithLowestSystolic.diastolic;

        return '$lowestSystolic / $correspondingDiastolic mmHg';
      }
    }
    return 'No valid data';
  }

  _getLowestPulse() {
    if (medicalDataEntries.isNotEmpty) {
      final filteredPulses = medicalDataEntries
          .map((entry) => entry.pulse)
          .where((pulse) => pulse != 0)
          .toList();
      if (filteredPulses.isNotEmpty) {
        final lowestPulse = filteredPulses
            .reduce((value, element) => value < element ? value : element);
        return '$lowestPulse bpm';
      }
    }
    return 'No valid data';
  }

  _getHighestPulse() {
    if (medicalDataEntries.isNotEmpty) {
      final pulse = medicalDataEntries
          .map((entry) => entry.pulse)
          .reduce((value, element) => value > element ? value : element);
      return '$pulse bpm';
    } else {
      return null;
    }
  }

  Widget _buildMoodChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 300,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              interval: 1,
              labelIntersectAction: AxisLabelIntersectAction.rotate45,
              labelStyle: GoogleFonts.workSans(),
            ),
            series: <LineSeries<MedicalData, String>>[
              LineSeries<MedicalData, String>(
                dataSource: medicalDataEntries,
                xValueMapper: (MedicalData data, _) => data.date,
                yValueMapper: (MedicalData data, _) => data.moodScore,
                name: 'Mood',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
            legend: const Legend(isVisible: true),
            title: ChartTitle(
                text: 'Mood Over Time',
                textStyle: GoogleFonts.workSans(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                )),
            tooltipBehavior: TooltipBehavior(enable: true),
          ),
        ),
        const SizedBox(height: 16.0),
        _buildMoodScoreLegend(),
      ],
    );
  }

  Widget _buildMoodScoreLegend() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Score Legend:',
            style: GoogleFonts.workSans(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            '1 - Very Sad: Feeling extremely negative, stressed, or anxious.',
            style: GoogleFonts.workSans(fontSize: 16.0),
          ),
          const SizedBox(height: 4.0),
          Text(
            '2 - Sad: Generally feeling down or unhappy.',
            style: GoogleFonts.workSans(fontSize: 16.0),
          ),
          const SizedBox(height: 4.0),
          Text(
            '3 - Neutral: Neither good nor bad, feeling okay.',
            style: GoogleFonts.workSans(fontSize: 16.0),
          ),
          const SizedBox(height: 4.0),
          Text(
            '4 - Good: Feeling positive and happy.',
            style: GoogleFonts.workSans(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
