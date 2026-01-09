import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fyp/modules/global_import.dart';

// ---------------------------
// Model
// ---------------------------
class WeightData {
  final DateTime date;
  final double weight;

  WeightData({required this.date, required this.weight});
}

// ---------------------------
// Controller
// ---------------------------
class ChartController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<WeightData>> fetchWeightData({
    required void Function(double? latestWeight, String? latestDate) onLatestData,
    required void Function() onError,
  }) async {
    final userId = await _storage.read(key: 'userId');
    if (userId == null) return [];

    try {
      final response = await http.post(
        Uri.parse('http://$activeIP/get_weight_history.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        List<WeightData> weights = [];
        double? latestWeight;
        String? latestDate;

        for (var entry in data['data']) {
          final weight = double.tryParse(entry['weight'].toString()) ?? 0;
          final date = DateTime.parse(entry['date']);
          weights.add(WeightData(date: date, weight: weight));

          if (latestDate == null || date.isAfter(DateTime.parse(latestDate))) {
            latestWeight = weight;
            latestDate = entry['date'];
          }
        }

        onLatestData(latestWeight, latestDate);
        return weights;
      } else {
        onError();
        return [];
      }
    } catch (e) {
      onError();
      return [];
    }
  }
}

// ---------------------------
// Widget
// ---------------------------
class WeightChart extends StatelessWidget {
  final bool isLoading;
  final List<WeightData> weightHistory;

  const WeightChart({
    super.key,
    required this.isLoading,
    required this.weightHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (weightHistory.isEmpty) {
      return const Text('No weight data found.');
    }

    weightHistory.sort((a, b) => a.date.compareTo(b.date));
    final minDate = weightHistory.first.date;

    final spots = weightHistory.map((entry) {
      final x = entry.date.difference(minDate).inDays.toDouble();
      return FlSpot(x, entry.weight);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightbackground, // Dark background
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 240,
        child: LineChart(
          LineChartData(
            backgroundColor: AppColors.lightbackground,
            gridData: FlGridData(
              show: false,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (_) => FlLine(
                color: Colors.white.withOpacity(0.05),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 32,
                  interval: (spots.length == 1) ? 1 : (spots.last.x / (spots.length - 1)),
                  getTitlesWidget: (value, _) {
                    final date = minDate.add(Duration(days: value.toInt()));
                    return Text(
                      DateFormat('dd/MM').format(date),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: spots.last.x,
            minY: weightHistory.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 2,
            maxY: weightHistory.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 2,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Colors.pinkAccent,
                barWidth: 3,
                isStrokeCapRound: true,
                belowBarData: BarAreaData(show: false), // No gradient area
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3,
                      color: Colors.pinkAccent,
                      strokeWidth: 0,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}