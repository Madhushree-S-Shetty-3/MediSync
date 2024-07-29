import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'pricePoints.dart'; // Make sure to import your Pricepoints class

class Linechart extends StatelessWidget {
  final String documentId; // Document ID to fetch data
  static const int maxPoints = 7; // Maximum points to display

  const Linechart({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 170,
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('medisync')
              .doc(documentId)
              .get(), // Fetch document data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text('No data found'));
            }

            // Parse data from Firestore
            final data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data == null ||
                !data.containsKey('beforeMealSugar') ||
                !data.containsKey('afterMealSugar')) {
              return const Center(child: Text('Data format error'));
            }

            // Extract latest 7 points from Firestore data
            List<Pricepoints> beforeSugarPoints =
                extractPoints(data['beforeMealSugar']);
            List<Pricepoints> afterSugarPoints =
                extractPoints(data['afterMealSugar']);

            // Handle the case where there are no points to display
            if (beforeSugarPoints.isEmpty && afterSugarPoints.isEmpty) {
              return const Center(child: Text('No data points available'));
            }

            return LineChart(
              LineChartData(
                lineBarsData: [
                  if (beforeSugarPoints.isNotEmpty)
                    LineChartBarData(
                      spots: beforeSugarPoints
                          .map((point) => FlSpot(point.x, point.y))
                          .toList(),
                      isCurved: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          strokeWidth: 1,
                          color: const Color.fromARGB(255, 155, 131,
                              227), // Dot color for beforeMealSugar
                          strokeColor: const Color(
                              0xff8766EB), // Dot stroke color for beforeMealSugar
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
                      color: const Color(
                          0xff8766EB), // Line color for beforeMealSugar
                    ),
                  if (afterSugarPoints.isNotEmpty)
                    LineChartBarData(
                      spots: afterSugarPoints
                          .map((point) => FlSpot(point.x, point.y))
                          .toList(),
                      isCurved: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          strokeWidth: 1,
                          color: const Color.fromARGB(255, 140, 190,
                              221), // Dot color for afterMealSugar
                          strokeColor: const Color(
                              0xff0293ee), // Dot stroke color for afterMealSugar
                        ),
                      ),
                      belowBarData: BarAreaData(show: false),
                      color: const Color(
                          0xff0293ee), // Line color for afterMealSugar
                    ),
                ],
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval:
                      20, // Set the interval between horizontal lines
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xff37434d),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipPadding: const EdgeInsets.all(0),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        final flSpot = touchedSpot;
                        return LineTooltipItem(
                          flSpot.y.toStringAsFixed(2), // Display y-value on click
                          const TextStyle(color: Colors.black),
                        );
                      }).toList();
                    },
                  ),
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((spotIndex) {
                      return const TouchedSpotIndicatorData(
                        FlLine(
                            color: Colors
                                .transparent), // Disable the vertical line
                        FlDotData(show: true),
                      );
                    }).toList();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Function to extract latest 7 points from Firestore data
  List<Pricepoints> extractPoints(List<dynamic> data) {
    List<Pricepoints> points = [];
    int startIndex = data.length > maxPoints ? data.length - maxPoints : 0;
    for (int i = startIndex; i < data.length; i++) {
      // Ensure data[i] is convertible to double
      if (data[i] is int || data[i] is double) {
        points.add(
            Pricepoints(x: (i - startIndex).toDouble(), y: data[i].toDouble()));
      } else if (data[i] is String) {
        // Handle conversion from string to double if possible
        try {
          double value = double.parse(data[i]);
          points.add(Pricepoints(x: (i - startIndex).toDouble(), y: value));
        } catch (e) {
          print('Error parsing string to double: $e');
          // Handle error or fallback behavior if conversion fails
        }
      }
    }
    return points;
  }
}
