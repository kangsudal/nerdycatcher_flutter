
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/data/repositories/plant_repository.dart';

final plantRepositoryProvider = Provider((ref) => PlantRepository());