// lib/providers/sensor_providers.dart

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/providers/fcm_provider.dart';
import '../data/repositories/websocket_repository.dart'; // 수정: repositories 폴더로 경로 변경
import '../data/models/sensor_data.dart'; // 수정: models 폴더로 경로 변경
import 'package:fl_chart/fl_chart.dart'; // FlSpot 사용

const String webSocketUrl = "wss://nerdycatcher-server.onrender.com/";

// 1. WebSocket 리포지토리 프로바이더
// 앱이 시작될 때 한 번만 생성되고 앱 전체에서 공유됩니다.
// WebSocket 객체를 앱 전체에서 공유하게 해줌.
final webSocketRepositoryProvider = Provider<WebSocketRepository>((ref) {
  final fcmService = ref.watch(fcmServiceProvider);
  final repository = NerdyCatcherSocketRepository(webSocketUrl, fcmService);

  // 프로바이더가 dispose될 때 WebSocket 연결을 정리합니다.
  ref.onDispose(() => repository.dispose());

  // 앱 시작 시 WebSocket 연결 시도
  repository.connect();
  return repository;
});

// 2. 전체 센서 데이터 스트림 프로바이더
// 리포지토리에서 제공하는 SensorData 스트림을 listen합니다.
// WebSocket에서 들어오는 SensorData 스트림을 연결
final sensorDataStreamProvider = StreamProvider.family<SensorData?, int>((
  ref,
  plantId,
) {
  final repository = ref.watch(webSocketRepositoryProvider);
  return repository.sensorDataStream
      .where((data) => data.plantId == plantId)
      .timeout(
        const Duration(seconds: 8),
        onTimeout: (sink) {
          sink.addError(TimeoutException('파수꾼 연결 안됨'));
        },
      );
});

// 3. 각 센서 값 (온도, 습도, 조도) 스트림 프로바이더
// SensorData 스트림에서 필요한 값만 추출하여 제공합니다.
final temperatureStreamProvider = StreamProvider.family<double, int>((
  ref,
  plantId,
) {
  final sensorDataAsync = ref.watch(sensorDataStreamProvider(plantId));

  return sensorDataAsync.when(
    data:
        (sensorData) =>
            sensorData != null
                ? Stream.value(sensorData.temperature)
                : Stream.empty(),
    loading: () => Stream.empty(),
    error: (err, _) => Stream.error(err),
  );
});

final humidityStreamProvider = StreamProvider.family<double, int>((
  ref,
  plantId,
) {
  final sensorDataAsync = ref.watch(sensorDataStreamProvider(plantId));

  return sensorDataAsync.when(
    data:
        (sensorData) =>
            sensorData != null
                ? Stream.value(sensorData.humidity)
                : Stream.empty(),
    loading: () => Stream.empty(),
    error: (err, _) => Stream.error(err),
  );
});

final lightLevelStreamProvider = StreamProvider.family<int, int>((
  ref,
  plantId,
) {
  final sensorDataAsync = ref.watch(sensorDataStreamProvider(plantId));

  return sensorDataAsync.when(
    data:
        (sensorData) =>
            sensorData != null
                ? Stream.value(sensorData.lightLevel)
                : Stream.empty(),
    loading: () => Stream.empty(),
    error: (err, _) => Stream.error(err),
  );
});

// 4. 차트 데이터를 관리하는 Notifier
// FlSpot은 x, y 값을 가지며, x축은 시간(millisecondsSinceEpoch)으로 사용합니다.
abstract class BaseChartDataNotifier extends FamilyNotifier<List<FlSpot>, int> {
  // 최대 저장 데이터 포인트 수
  static const int maxDataPoints = 20;

  @override
  List<FlSpot> build(int plantId) {
    // 초기 상태
    return [];
  }

  // 센서 값이 들어올 때마다 이 함수를 통해 FlSpot을 만들어 저장.
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

  // 각 Notifier가 어떤 스트림을 들을지 정의하는 추상 메서드 (강제 구현)
  void listenToStream(int plantId);
}

// 5. 각 센서별 차트 데이터 프로바이더 (NotifierProvider로 변경)

// 온도 차트 데이터 Notifier
final temperatureChartDataProvider =
    NotifierProvider.family<TemperatureChartDataNotifier, List<FlSpot>, int>(
      TemperatureChartDataNotifier.new,
    );

class TemperatureChartDataNotifier extends BaseChartDataNotifier {
  late int plantId;

  TemperatureChartDataNotifier();
  @override
  List<FlSpot> build(int plantId) {
    this.plantId = plantId;
    final initialState = super.build(plantId); // 부모의 build 호출 (빈 리스트 반환)
    listenToStream(plantId); // 이 Notifier가 어떤 스트림을 들을지 설정
    return initialState;
  }

  @override
  void listenToStream(int plantId) {
    // ref.listen은 첫번째 매개변수 (temperatureStreamProvider)를 감시하고 변화가 생길 때마다 반응
    // <AsyncValue<double>>는 이 스트림이 온도 값(double)을 비동기 상태로 감싸고 있음을 의미
    ref.listen<AsyncValue<double>>(temperatureStreamProvider(plantId), (
      previous,
      next,
    ) {
      next.whenData((dataValue) {
        final currentSensorData =
            ref.read(sensorDataStreamProvider(plantId)).value;
        // temperatureStreamProvider는 double 값만 갖고 있어서 timestamp는 없기 때문에,
        // 전체 센서 데이터 (SensorData) 중에서 타임스탬프 정보를 가져오기 위한 코드
        // 실제 타임스탬프는 sensorDataStreamProvider에서 꺼내옴
        if (currentSensorData != null) {
          add(dataValue, currentSensorData.timestamp);
          // 아주 드문 비동기 타이밍 어긋남
          // 센서값만 존재 -> 현재 시간 기준 FlSpot 생성
        } else {
          add(dataValue, DateTime.now());
          // 온도값(dataValue)과 해당 시점의 시간(timestamp)을 add() 함수에 전달해서
          // FlSpot(x: timestamp, y: 온도) 형태로 차트에 찍히게 돼.
        }
      });
    });
    // 온도값은 temperatureStreamProvider에서,
    // 시간값은 sensorDataStreamProvider에서 따로 가져와서
    // “27도, 오전 10시” 이런 식으로 차트에 넣는 거
  }
}

// 습도 차트 데이터 Notifier
final humidityChartDataProvider =
    NotifierProvider.family<HumidityChartDataNotifier, List<FlSpot>, int>(
      HumidityChartDataNotifier.new,
    );

class HumidityChartDataNotifier extends BaseChartDataNotifier {
  late int plantId;

  @override
  List<FlSpot> build(int plantId) {
    this.plantId = plantId;
    final initialState = super.build(plantId);
    listenToStream(plantId);
    return initialState;
  }

  @override
  void listenToStream(int plantId) {
    ref.listen<AsyncValue<double>>(humidityStreamProvider(plantId), (
      previous,
      next,
    ) {
      next.whenData((dataValue) {
        final currentSensorData =
            ref.read(sensorDataStreamProvider(plantId)).value;
        if (currentSensorData != null) {
          add(dataValue, currentSensorData.timestamp);
        } else {
          add(dataValue, DateTime.now());
        }
      });
    });
  }
}

// 조도 차트 데이터 Notifier
final lightLevelChartDataProvider =
    NotifierProvider.family<LightLevelChartDataNotifier, List<FlSpot>, int>(
      LightLevelChartDataNotifier.new,
    );

class LightLevelChartDataNotifier extends BaseChartDataNotifier {
  late int plantId;
  @override
  List<FlSpot> build(int plantId) {
    this.plantId = plantId;

    final initialState = super.build(plantId);
    listenToStream(plantId);
    return initialState;
  }

  @override
  void listenToStream(int plantId) {
    ref.listen<AsyncValue<int>>(lightLevelStreamProvider(plantId), (
      previous,
      next,
    ) {
      next.whenData((dataValue) {
        final currentSensorData =
            ref.read(sensorDataStreamProvider(plantId)).value;
        if (currentSensorData != null) {
          add(dataValue.toDouble(), currentSensorData.timestamp);
        } else {
          add(dataValue.toDouble(), DateTime.now());
        }
      });
    });
  }
}
