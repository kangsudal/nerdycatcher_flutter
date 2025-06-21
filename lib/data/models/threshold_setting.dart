class ThresholdSetting {
  final int id;
  final int plantId;
  final double temperatureMin;
  final double temperatureMax;
  final double humidityMin;
  final double humidityMax;
  final double lightMin;
  final double lightMax;

  ThresholdSetting({
    required this.id,
    required this.plantId,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.humidityMin,
    required this.humidityMax,
    required this.lightMin,
    required this.lightMax,
  });

  factory ThresholdSetting.fromJson(Map<String, dynamic> json) {
    return ThresholdSetting(
      id: json['id'],
      plantId: json['plant_id'],
      temperatureMin: json['temperature_min'],
      temperatureMax: json['temperature_max'],
      humidityMin: json['humidity_min'],
      humidityMax: json['humidity_max'],
      lightMin: json['light_min'],
      lightMax: json['light_max'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plant_id': plantId,
      'temperature_min': temperatureMin,
      'temperature_max': temperatureMax,
      'humidity_min': humidityMin,
      'humidity_max': humidityMax,
      'light_min': lightMin,
      'light_max': lightMax,
    };
  }
}