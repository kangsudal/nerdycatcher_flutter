class ThresholdSetting {
  final int? id; //nullable로 변경한 이유는 insert할 때 id를 모르고, Supabase가 자동 생성해 주기 때문
  final int plantId;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? humidityMin;
  final double? humidityMax;
  final double? lightMin;
  final double? lightMax;

  ThresholdSetting({
    this.id,
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
      if (id != null) 'id': id,
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
