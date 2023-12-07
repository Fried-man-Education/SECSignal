import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:intl/intl.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart' as yahoo;
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class StockGraphCard extends StatefulWidget {
  final String ticker;

  const StockGraphCard({Key? key, required this.ticker}) : super(key: key);

  @override
  _StockGraphCardState createState() => _StockGraphCardState();
}

class _StockGraphCardState extends State<StockGraphCard> {
  late Future<Map<String, dynamic>> _stockDataFuture;

  @override
  void initState() {
    super.initState();
    _stockDataFuture = yahoo.YahooFinanceDailyReader().getDailyData(widget.ticker);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Stock Chart",
                  style: PlatformProvider.of(context)!.platform == TargetPlatform.iOS ? CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle : Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                    "Up to last five years",
                    style: Platform.isIOS ? CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                        color: Colors.grey
                    ) : Theme.of(context).textTheme.headlineMedium!
                ),
              ),
              SizedBox(
                height: 700,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _stockDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return PlatformCircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData) {
                        return Text('No data available');
                      } else {
                        List<FlSpot> spots = _getSpots(snapshot.data!);

                        double maxY = List<double>.from(snapshot.data!["indicators"]["quote"].first["open"]).reduce(max) * 1.15;  // 110% of the highest value
                        if (maxY > 1) {
                          maxY = maxY.roundToDouble();
                        }

                        double interval = (maxY - 0) * 0.15;  // 15% of the range
                        if (interval > 1) {
                          interval = interval.roundToDouble();
                        }

                        return LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: maxY,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: interval,
                              getDrawingHorizontalLine: (value) {
                                return const FlLine(
                                  color: Color(0xff37434d),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: const Duration(days: 365).inMilliseconds / 1000,
                                    getTitlesWidget: _bottomTitleWidgets,
                                  )
                              ),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 44,
                                    interval: interval,
                                  )
                              ),
                              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: const Color(0xff37434d), width: 1),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: Theme.of(context).primaryColor,
                                barWidth: 5,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                tooltipBgColor: Theme.of(context).primaryColor, // Set your desired color here
                                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    return LineTooltipItem(
                                      '${(barSpot.y * 100).roundToDouble() / 100}',
                                      const TextStyle(color: Colors.white),
                                    );
                                  }).toList();
                                },
                              ),
                            )
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(Map<String, dynamic> data) {
    List<int> timestamps = List<int>.from(data["timestamp"]);
    List<double> openPrices = List<double>.from(data["indicators"]["quote"].first["open"]);

    // Determine the cutoff timestamp for one year ago
    int oneYearAgoTimestamp = DateTime.now().subtract(const Duration(days: 365 * 5)).millisecondsSinceEpoch ~/ 1000;

    List<FlSpot> spots = [];
    for (int i = 0; i < timestamps.length; i++) {
      if (timestamps[i] >= oneYearAgoTimestamp) {
        double x = timestamps[i].toDouble(); // Adjust if needed
        double y = openPrices[i];
        spots.add(FlSpot(x, y));
      }
    }

    return spots;
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Color(0xff68737d), fontWeight: FontWeight.bold, fontSize: 16);
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
    String year = DateFormat('yyyy').format(date);

    // Calculate the start of the current year
    DateTime startOfCurrentYear = DateTime(DateTime.now().year);
    int startOfCurrentYearTimestamp = startOfCurrentYear.millisecondsSinceEpoch ~/ 1000;

    // Display the label if it's the start of a year or the current year
    bool shouldDisplayYear = ((date.millisecondsSinceEpoch ~/ 1000) % (365 * 24 * 3600) == 0) || (date.millisecondsSinceEpoch ~/ 1000) >= startOfCurrentYearTimestamp;

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: shouldDisplayYear ? Text(year, style: style) : Container(),
    );
  }
}
