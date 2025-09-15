import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthExpansesBarChart extends StatefulWidget {
  const MonthExpansesBarChart({super.key});

  @override
  State<MonthExpansesBarChart> createState() => _MonthExpansesBarChartState();
}

class _MonthExpansesBarChartState extends State<MonthExpansesBarChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1.5,
      child: Card(
        color: theme.colorScheme.surfaceDim,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 20,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final style = TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = Text('Mn', style: style);
                          break;
                        case 1:
                          text = Text('Te', style: style);
                          break;
                        case 2:
                          text = Text('Wd', style: style);
                          break;
                        case 3:
                          text = Text('Tu', style: style);
                          break;
                        case 4:
                          text = Text('Fr', style: style);
                          break;
                        case 5:
                          text = Text('St', style: style);
                          break;
                        case 6:
                          text = Text('Sn', style: style);
                          break;
                        default:
                          text = Text('', style: style);
                          break;
                      }
                      return SideTitleWidget(
                        meta: meta,
                        space: 4.0,
                        child: text,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 28,
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: 8,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: 10,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(
                      toY: 14,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(
                      toY: 15,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 4,
                  barRods: [
                    BarChartRodData(
                      toY: 13,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 5,
                  barRods: [
                    BarChartRodData(
                      toY: 10,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 6,
                  barRods: [
                    BarChartRodData(
                      toY: 16,
                      color: Colors.lightBlueAccent,
                      width: 20,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
            ),
            curve: Curves.easeInOutCubic,
            duration: const Duration(milliseconds: 150),
          ),
        ),
      ),
    );
  }
}
