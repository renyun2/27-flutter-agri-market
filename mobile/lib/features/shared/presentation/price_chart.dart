import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PriceTrendChart extends StatelessWidget {
  const PriceTrendChart({super.key, required this.prices});

  final List<double> prices;

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 120,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                prices.length,
                (i) => FlSpot(i.toDouble(), prices[i]),
              ),
              isCurved: true,
              color: Colors.green.shade700,
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
