// lib/providers/websocket_notifier.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/constants/app_constants.dart';
import 'package:nerdycatcher_flutter/data/models/sensor_data.dart';
import 'package:nerdycatcher_flutter/data/repositories/websocket_repository.dart';
import 'package:nerdycatcher_flutter/providers/sensor_providers.dart';

class WebSocketNotifier extends AutoDisposeAsyncNotifier<void> {
  final NerdyCatcherSocketRepository _repository = NerdyCatcherSocketRepository(
    AppConstants.webSocketUrl,
  );

  // 센서 데이터 스트림을 관리할 컨트롤러
  final StreamController<SensorData> _sensorDataController =
      StreamController<SensorData>.broadcast();

  Timer? _reconnectTimer;

  // 외부에 센서 데이터 스트림을 노출하는 부분
  Stream<SensorData> get sensorDataStream => _sensorDataController.stream;

  @override
  FutureOr<void> build() {
    // Notifier가 소멸될 때 Repository도 함께 정리
    ref.onDispose(() {
      _reconnectTimer?.cancel();
      _repository.dispose();
      _sensorDataController.close();
    });
    // 처음에는 아무것도 하지 않음
  }

  // UI가 소켓연결 요청하면 이 함수를 호출
  Future<void> connect() async {
    _reconnectTimer?.cancel(); // 새로운 연결 시도시, 기존 타이머는 중지
    state = const AsyncValue.loading(); // "지금 연결 중입니다" 상태로 변경

    // WebsocketRepository에게 "연결하고 데이터 수신 시작해줘" 라고 시킴
    // 소켓통신이 성공하거나 실패하면, 그 상태가 자동으로 state에 반영됨
    state = await AsyncValue.guard(
      () => _repository.connectAndListen(_sensorDataController),
    );
    if (state is AsyncError) {
      _startReconnectTimer();
    }
  }

  // UI가 연결 끊어주라고 요청하면 이 함수를 호출
  void disconnect() {
    _reconnectTimer?.cancel();
    _repository.dispose();
    state = const AsyncValue.data(null); // 초기 상태로 복귀
  }

  // 주기적으로 재연결을 시도하는 로직
  void _startReconnectTimer() {
    //만약 재연결 타이머가 이미 돌고 있다면, 또 실행하지 말고 그냥 함수를 끝내기
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      debugPrint('소켓통신 재연결을 시도합니다...');
      connect(); // 5초마다 다시 연결 시도
    });
  }
}

// 1. 매니저(Notifier)를 UI에 제공하는 Provider
final webSocketNotifierProvider =
    AsyncNotifierProvider.autoDispose<WebSocketNotifier, void>(
      () => WebSocketNotifier(),
    );

// 2. 센서 데이터 스트림을 UI에 제공하는 Provider
// final sensorDataStreamProvider = StreamProvider.autoDispose
//     .family<SensorData, int>((ref, plantId) {
//       final stream =
//           ref.watch(webSocketNotifierProvider.notifier).sensorDataStream;
//       stream.listen((data){
//         debugPrint('전체 데이터 도착: plantId = ${data.plantId}');
//       });
//       // Notifier를 통해 센서 데이터 스트림을 가져옴
//       return stream.where((data) {
//         debugPrint('데이터 plantId: ${data.plantId}, 내가 원하는 plantId: $plantId');
//         return data.plantId == plantId;
//       });
//     });
