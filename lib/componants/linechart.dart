import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Linechart extends StatelessWidget {
  final double temperature;
  final double moisture;
  final double pH;

  const Linechart({super.key,
  required this.temperature,
  required this.moisture,
  required this.pH}); 

  @override
  Widget build(BuildContext context) {
    return  Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, temperature),
                        FlSpot(1, moisture),
                        FlSpot(2, pH),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                ),
              ),
            );
  }
}