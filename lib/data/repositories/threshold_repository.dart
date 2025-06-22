import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/threshold_setting.dart';

class ThresholdRepository {
  final supabase = Supabase.instance.client;
  final String table = 'threshold_settings';

  Future<ThresholdSetting?> fetchByPlantId(int plantId) async {
    final data = await supabase
        .from(table)
        .select()
        .eq('plant_id', plantId)
        .single()
        .maybeSingle();

    if (data == null) return null;
    return ThresholdSetting.fromJson(data);
  }

  Future<void> upsertThreshold(ThresholdSetting setting) async {
    // upsert는 있으면 수정, 없으면 삽입
    await supabase.from(table).upsert(setting.toJson(), onConflict: 'plant_id');
  }

  Future<ThresholdSetting?> loadThresholdSettingValue(int plantId) async {
    // 설정 페이지 열었을 때 기존 설정 값이 로딩
    final response = await supabase
        .from('threshold_settings')
        .select()
        .eq('plant_id', plantId)
        .maybeSingle();

    if (response == null) return null;

    return ThresholdSetting.fromJson(response);
  }
}