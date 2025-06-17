// lib/providers/sensor_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/websocket_repository.dart'; // 수정: repositories 폴더로 경로 변경
import '../data/models/sensor_data.dart'; // 수정: models 폴더로 경로 변경
import 'package:fl_chart/fl_chart.dart'; // FlSpot 사용

const String webSocketUrl = "wss://nerdycatcher-server.onrender.com/";

// 1. WebSocket 리포지토리 프로바이더
// 앱이 시작될 때 한 번만 생성되고 앱 전체에서 공유됩니다.
final webSocketRepositoryProvider = Provider<WebSocketRepository>((ref) {
  // 개발/테스트 시 실제 서버 연결이 어려울 경우 DummyWebSocketRepository 사용
  // final repository = DummyWebSocketRepository();
  final repository = NerdyCatcherSocketRepository(webSocketUrl);

  // 프로바이더가 dispose될 때 WebSocket 연결을 정리합니다.
  ref.onDispose(() => repository.dispose());

  // 앱 시작 시 WebSocket 연결 시도
  repository.connect();
  return repository;
});

// 2. 전체 센서 데이터 스트림 프로바이더
// 리포지토리에서 제공하는 SensorData 스트림을 listen합니다.
final sensorDataStreamProvider = StreamProvider<SensorData>((ref) {
  final repository = ref.watch(webSocketRepositoryProvider);
  return repository.sensorDataStream;
});

// 3. 각 센서 값 (온도, 습도, 조도) 스트림 프로바이더
// SensorData 스트림에서 필요한 값만 추출하여 제공합니다.
final temperatureStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(sensorDataStreamProvider).when(
    data: (data) => Stream.value(data.temperature),
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err), // 에러 스트림으로 전달
  );
});

final humidityStreamProvider = StreamProvider<double>((ref) {
  return ref.watch(sensorDataStreamProvider).when(
    data: (data) => Stream.value(data.humidity),
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err),
  );
});

final lightLevelStreamProvider = StreamProvider<int>((ref) {
  return ref.watch(sensorDataStreamProvider).when(
    data: (data) => Stream.value(data.lightLevel),
    loading: () => const Stream.empty(),
    error: (err, stack) => Stream.error(err),
  );
});


// 4. 차트 데이터를 관리하는 StateNotifier
// FlSpot은 x, y 값을 가지며, x축은 시간(millisecondsSinceEpoch)으로 사용합니다.
class ChartDataNotifier extends StateNotifier<List<FlSpot>> {
  ChartDataNotifier() : super([]);

  // 최대 저장 데이터 포인트 수
  static const int maxDataPoints = 20;

  void add(double value, DateTime timestamp) {
    final newSpot = FlSpot(timestamp.millisecondsSinceEpoch.toDouble(), value);

    if (state.length >= maxDataPoints) {
      // 가장 오래된 데이터 제거 후 새 데이터 추가
      state = [...state.sublist(1), newSpot];
    } else {
      // 데이터 추가
      state = [...state, newSpot];
    }
  }
}

// 5. 각 센서별 차트 데이터 프로바이더
// 각 센서 스트림의 변화를 감지하여 차트 데이터 Notifier를 업데이트합니다.
final temperatureChartDataProvider = StateNotifierProvider<ChartDataNotifier, List<FlSpot>>((ref) {
  final notifier = ChartDataNotifier();
  ref.listen<AsyncValue<SensorData>>( // 전체 SensorData 스트림을 listen
    sensorDataStreamProvider,
        (previous, next) {
      next.whenData((sensorData) {
        notifier.add(sensorData.temperature, sensorData.timestamp);
      });
    },
  );
  return notifier;
});

final humidityChartDataProvider = StateNotifierProvider<ChartDataNotifier, List<FlSpot>>((ref) {
  final notifier = ChartDataNotifier();
  ref.listen<AsyncValue<SensorData>>(
    sensorDataStreamProvider,
        (previous, next) {
      next.whenData((sensorData) {
        notifier.add(sensorData.humidity, sensorData.timestamp);
      });
    },
  );
  return notifier;
});

final lightLevelChartDataProvider = StateNotifierProvider<ChartDataNotifier, List<FlSpot>>((ref) {
  final notifier = ChartDataNotifier();
  ref.listen<AsyncValue<SensorData>>(
    sensorDataStreamProvider,
        (previous, next) {
      next.whenData((sensorData) {
        notifier.add(sensorData.lightLevel.toDouble(), sensorData.timestamp); // int를 double로 변환
      });
    },
  );
  return notifier;
});