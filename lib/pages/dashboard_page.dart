// lib/pages/dashboard_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/providers/sensor_providers.dart'; // providers 폴더 임포트
import 'package:nerdycatcher_flutter/pages/widgets/sensor_line_chart.dart'; // widgets 폴더 임포트
import 'package:nerdycatcher_flutter/data/models/sensor_data.dart'; // models 폴더 임포트
import 'package:intl/intl.dart'; // DateFormat 사용

class DashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 모든 센서 데이터를 하나의 AsyncValue로 감시
    final AsyncValue<SensorData> sensorDataAsync = ref.watch(sensorDataStreamProvider);

    // 각 차트 데이터 프로바이더 감시
    final List<FlSpot> tempChartData = ref.watch(temperatureChartDataProvider);
    final List<FlSpot> humidChartData = ref.watch(humidityChartDataProvider);
    final List<FlSpot> lightChartData = ref.watch(lightLevelChartDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nerdycatcher Dashboard'),
        centerTitle: true,
      ),
      body: sensorDataAsync.when(
        data: (data) {
          // 데이터가 있을 때만 내용 표시
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCurrentDataCard(context, data), // context 전달
                const SizedBox(height: 20),
                SensorLineChart(
                  data: tempChartData,
                  title: '온도 변화',
                  unit: '°C',
                  minY: 10, // 작물에 맞는 최소/최대값으로 조정
                  maxY: 35,
                  lineColor: Colors.redAccent,
                ),
                SensorLineChart(
                  data: humidChartData,
                  title: '습도 변화',
                  unit: '%',
                  minY: 30, // 작물에 맞는 최소/최대값으로 조정
                  maxY: 90,
                  lineColor: Colors.blueAccent,
                ),
                SensorLineChart(
                  data: lightChartData,
                  title: '조도 변화',
                  unit: 'Lux', // 또는 'ADC Value'
                  minY: 0,   // 작물에 맞는 최소/최대값으로 조정
                  maxY: 1000,
                  lineColor: Colors.orangeAccent,
                ),
                // --- DLI (적산광량) 계산 및 표시 영역 (개념적) ---
                // 실제 DLI 계산은 광센서의 ADC 값을 Lux 또는 PPFD로 변환 후,
                // 이를 시간당 누적하는 복잡한 로직이 필요합니다.
                // 여기서는 아이디어를 보여주는 자리입니다.
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '🌱 적산광량 (DLI) 계산 예정: 식물 생장에 필요한 누적 광량',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 오류: $err\nStack: $stack')),
      ),
    );
  }

  // 현재 센서 데이터를 보여주는 카드 위젯
  Widget _buildCurrentDataCard(BuildContext context, SensorData data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('현재 센서 데이터', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
            const Divider(height: 20, thickness: 1),
            _buildDataRow('온도', '${data.temperature.toStringAsFixed(1)} °C', Icons.thermostat_outlined),
            _buildDataRow('습도', '${data.humidity.toStringAsFixed(1)} %', Icons.water_drop_outlined),
            _buildDataRow('조도', '${data.lightLevel} Lux', Icons.light_mode_outlined),
            _buildDataRow('식물 ID', '${data.plantId}', Icons.grass_outlined),
            _buildDataRow('수신 시간', DateFormat('yyyy-MM-dd HH:mm:ss').format(data.timestamp), Icons.access_time_outlined),
          ],
        ),
      ),
    );
  }

  // 데이터 한 줄을 표시하는 보조 위젯
  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Text('$label: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded( // 텍스트가 길어질 경우를 대비해 Expanded
            child: Text(value, style: TextStyle(fontSize: 18, color: Colors.blueGrey[700]), softWrap: true),
          ),
        ],
      ),
    );
  }
}