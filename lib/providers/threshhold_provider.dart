import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/data/models/threshold_setting.dart';
import 'package:nerdycatcher_flutter/data/repositories/threshold_repository.dart';

final thresholdRepositoryProvider = Provider((ref) => ThresholdRepository());

final thresholdSettingProvider =
FutureProvider.family<ThresholdSetting?, int>((ref, plantId) async {
  final repo = ref.read(thresholdRepositoryProvider);
  return await repo.fetchByPlantId(plantId);
});