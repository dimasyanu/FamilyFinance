import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MonthExpansesBarChart extends StatefulWidget {
  const MonthExpansesBarChart({super.key});

  @override
  State<MonthExpansesBarChart> createState() => _MonthExpansesBarChartState();
}

class _MonthExpansesBarChartState extends State<MonthExpansesBarChart> {
  BarChartRodData incomeBar(double toY) {
    return BarChartRodData(
      toY: toY,
      color: Colors.green.shade300,
      width: 20,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    );
  }

  BarChartRodData expenseBar(List<ExpanseData> expanses) {
    return BarChartRodData(
      toY: expanses.fold(0, (sum, item) => sum + item.amount),
      color: Colors.redAccent,
      width: 20,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceDim,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'Monthly Expenses Overview',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          AspectRatio(
            aspectRatio: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        incomeBar(3),
                        BarChartRodData(
                          toY: 8,
                          color: Colors.lightBlueAccent,
                          width: 20,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          rodStackItems: [
                            BarChartRodStackItem(0, 3, Colors.redAccent),
                            BarChartRodStackItem(3, 8, Colors.lightBlueAccent),
                          ],
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
        ],
      ),
    );
  }
}
