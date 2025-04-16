import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/database_helper.dart';

class TemperatureHistoryScreen extends StatelessWidget {
  const TemperatureHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbHelper = Provider.of<DatabaseHelper>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Temperature History')),
      body: FutureBuilder<List<double>>(
        future: dbHelper.getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return StreamBuilder<double>(
            stream: dbHelper.temperatureUpdates,
            builder: (context, streamSnapshot) {
              List<double> data = List.from(snapshot.data!);
              if (streamSnapshot.hasData) data.insert(0, streamSnapshot.data!);
              if (data.length > 50) data = data.sublist(0, 50);

              List<FlSpot> spots =
                  data.reversed.toList().asMap().entries.map((entry) {
                    return FlSpot(entry.key.toDouble(), entry.value);
                  }).toList();

              return Padding(
                padding: const EdgeInsets.all(20),
                child: LineChart(
                  LineChartData(
                    minY: 10,
                    maxY: 30,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 5,
                      verticalInterval: 5,
                      getDrawingHorizontalLine:
                          (value) => FlLine(
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 1,
                          ),
                      getDrawingVerticalLine:
                          (value) => FlLine(
                            color: Colors.grey.withOpacity(0.3),
                            strokeWidth: 1,
                          ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}°C',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.teal,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval:
                              spots.length > 5
                                  ? (spots.length / 5).floorToDouble()
                                  : 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.cyan,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey, width: 1),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: Colors.blueAccent,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '${spot.y.toStringAsFixed(1)}°C',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
