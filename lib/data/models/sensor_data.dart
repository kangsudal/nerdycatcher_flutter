// lib/data/models/sensor_data.dart

class SensorData {
  final double temperature;
  final double humidity;
  final int lightLevel;
  final int plantId;
  final DateTime timestamp; // 데이터 수신 시점 추가 (차트 X축 등에 유용)

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.lightLevel,
    required this.plantId,
    required this.timestamp,
  });

  // 서버에서 받은 JSON Map을 SensorData 객체로 변환하는 팩토리 생성자
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(), // num 타입을 double로 안전하게 변환
      humidity: (json['humidity'] as num).toDouble(),
      lightLevel: (json['light_level'] as int),
      plantId: (json['plant_id'] as int),
      timestamp: DateTime.now(), // 앱에서 데이터를 받는 시점의 시간을 기록
    );
  }

  // 디버깅을 위한 toString 오버라이드
  @override
  String toString() {
    return 'SensorData(T: ${temperature.toStringAsFixed(1)}°C, H: ${humidity.toStringAsFixed(1)}%, L: $lightLevel, P: $plantId, Time: ${timestamp.toIso8601String()})';
  }
}