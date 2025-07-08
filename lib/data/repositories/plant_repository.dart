import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nerdycatcher_flutter/data/models/plant.dart';

class PlantRepository {
  final _client = Supabase.instance.client;

  Future<int> insertPlant(Plant plant) async {
    final response =
        await _client
            .from('plants')
            .insert(plant.toMap())
            .select('id')
            .single();

    return response['id'] as int;
  }

  Future<List<Plant>> fetchPlants() async {
    final currentUserId = _client.auth.currentUser?.id;
    // 등록된 모든 작물 목록을 가져온다.
    // deleted_at 컬럼이 null인, 즉 삭제되지 않은 작물만 불러온다.
    // 홈화면에서 작물 리스트를 보여줄 때 사용.
    final data = await _client
        .from('plants')
        .select()
        // .eq('user_id',currentUserId!)
        .isFilter('deleted_at', null);
    return (data as List<dynamic>)
        .map((e) => Plant.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkIsMemberOf(int plantId) async {
    final currentUserId = _client.auth.currentUser!.id;
    final List<dynamic> res = await _client
        .from('monitoring_members')
        .select('user_id')
        .eq('user_id', currentUserId)
        .eq('plant_id', plantId);

    return res.isNotEmpty;
  }

  Future<void> beMemberOf(int plantId) async {
    final currentUserId = _client.auth.currentUser!.id;
    final response = await _client.from('monitoring_members').insert({
      'user_id': currentUserId,
      'plant_id': plantId,
    });

    if (response != null && response.error != null) {
      throw Exception('모니터링 멤버 등록 실패: ${response.error!.message}');
    }
  }

  Future<Plant?> fetchPlantById(int plantId) async {
    //특정 plant_id를 가진 작물 1개의 정보를 가져온다.
    final data =
        await _client.from('plants').select().eq('id', plantId).maybeSingle();
    if (data == null) return null;
    return Plant.fromMap(data);
  }

  Future<bool> checkIfVarietyCodeExists(String varietyCode) async {
    final response = await _client
        .from('plants')
        .select('id')
        .eq('variety_code', varietyCode)
        .limit(1); // 하나만 확인하면 됨

    return response.isNotEmpty;
  }
}
