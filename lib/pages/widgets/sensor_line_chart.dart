// lib/pages/widgets/sensor_line_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // 날짜/시간 포맷팅

class SensorLineChart extends StatelessWidget {
  final List<FlSpot> data;
  final String title;
  final String unit;
  final double minY;
  final double maxY;
  final Color lineColor;

  SensorLineChart({
    Key? key,
    required this.data,
    required this.title,
    required this.unit,
    required this.minY,
    required this.maxY,
    this.lineColor = Colors.blue, // 기본 색상 설정
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text('데이터 없음', style: TextStyle(color: Colors.grey)),
      );
    }

    // X축 (시간) 레이블 포맷터
    SideTitles getBottomTitles() {
      // 데이터 범위에 따라 간격 조정 (예: 20개 데이터 기준)
      double interval =
          (data.last.x - data.first.x) /
          (data.length > 1 ? (data.length / 4).round() : 1);
      if (interval < 60000) interval = 60000; // 최소 1분 간격

      return SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: interval, // 동적으로 간격 조정
        getTitlesWidget: (value, meta) {
          final dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
          // 데이터가 너무 많을 때 레이블 겹침 방지
          if (value == data.first.x ||
              value == data.last.x ||
              value == data[data.length ~/ 2].x) {
            // 첫, 중간, 끝만 표시 예시
            return SideTitleWidget(
              space: 8.0,
              meta: meta,
              child: Text(
                DateFormat('hh:mm').format(dateTime), // 시간만 표시 (예: 08:30)
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          }
          return Container(); // 다른 데이터는 레이블 숨김
        },
      );
    }

    // Y축 레이블 포맷터
    SideTitles getLeftTitles() {
      return SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) {
          return Text(
            '${value.toStringAsFixed(0)}$unit',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          );
        },
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  minX: data.isNotEmpty ? data.first.x : 0,
                  // 데이터가 없으면 0으로 설정
                  maxX: data.isNotEmpty ? data.last.x : 1,
                  // 데이터가 없으면 1로 설정
                  minY: minY,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(sideTitles: getBottomTitles()),
                    leftTitles: AxisTitles(sideTitles: getLeftTitles()),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    getDrawingHorizontalLine:
                        (value) => FlLine(
                          color: const Color(0xff37434d),
                          strokeWidth: 0.5,
                        ),
                    getDrawingVerticalLine:
                        (value) => FlLine(
                          color: const Color(0xff37434d),
                          strokeWidth: 0.5,
                        ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: const Color(0xff37434d),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
