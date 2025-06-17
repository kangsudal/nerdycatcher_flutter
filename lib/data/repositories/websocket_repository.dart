// lib/data/repositories/websocket_repository.dart

import 'dart:async';
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket 통신 라이브러리
import '../models/sensor_data.dart'; // SensorData 모델 임포트
import 'dart:math'; // 더미 데이터 생성을 위해 임포트

// 모든 WebSocket 관련 로직을 캡슐화하는 추상 클래스
abstract class WebSocketRepository {
  Stream<SensorData> get sensorDataStream;
  void connect();
  void dispose();
}

// 실제 WebSocket 통신을 구현하는 클래스
class NerdyCatcherSocketRepository implements WebSocketRepository {
  final String url;
  WebSocketChannel? _channel;
  final StreamController<SensorData> _controller =
      StreamController<SensorData>.broadcast();
  Timer? _reconnectTimer;
  static const Duration _reconnectInterval = Duration(seconds: 5); // 재연결 시도 간격

  NerdyCatcherSocketRepository(this.url); // 생성자에서 URL을 받음

  @override
  void connect() {
    if (_channel != null && _channel!.closeCode == null) {
      print('WebSocket is already connected.');
      return; // 이미 연결되어 있으면 다시 연결 시도하지 않음
    }
    _reconnectTimer?.cancel(); // 기존 재연결 타이머가 있다면 취소

    print('Attempting to connect to WebSocket: $url');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.sink.add(
        jsonEncode({'type': 'identify', 'name': 'Flutter App'}),
      );

      _channel!.stream.listen(
        (message) {
          handleWebSocketMessage(message);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _reconnect(); // 오류 발생 시 재연결 시도
        },
        onDone: () {
          print('WebSocket disconnected. Attempting to reconnect...');
          _reconnect(); // 연결 종료 시 재연결 시도
        },
      );
    } catch (e) {
      print('WebSocket connection initial failure: $e');
      _reconnect(); // 초기 연결 실패 시 재연결 시도
    }
  }

  void handleWebSocketMessage(String message) {
    try {
      final Map<String, dynamic> json = jsonDecode(message);

      switch (json['type']) {
        case 'sensor_data':
          final data = json['data'];
          if (data != null) {
            final sensorData = SensorData.fromJson(data);
            print('📥 수신된 센서 데이터: $sensorData');
            _controller.add(sensorData); //스트림에 전송
          }
          break;

        case 'identify':
          print('👋 Identify 메시지 수신: ${json['name']}');
          break;

        default:
          print('⚠️ 알 수 없는 메시지 타입: ${json['type']}');
      }
    } catch (e) {
      print('❌ JSON 파싱 실패: $e');
    }
  }

  // 주기적으로 재연결을 시도하는 내부 메서드
  void _reconnect() {
    // 연결이 완전히 끊겼을 때만 재연결 타이머 시작 (closeCode가 null이 아님)
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      // 이미 타이머가 돌고 있지 않을 때만
      _reconnectTimer = Timer.periodic(_reconnectInterval, (timer) {
        if (_channel == null || _channel!.closeCode != null) {
          // 채널이 없거나 끊겨있을 때만
          print('Reattempting WebSocket connection...');
          connect(); // 연결 시도
          if (_channel != null && _channel!.closeCode == null) {
            // 연결 성공시
            print('WebSocket reconnected successfully!');
            timer.cancel(); // 타이머 중지
            _reconnectTimer = null; // 타이머 참조 제거
          }
        } else {
          // 이미 연결되었거나 연결 시도 중
          timer.cancel();
          _reconnectTimer = null;
        }
      });
    }
  }

  @override
  Stream<SensorData> get sensorDataStream => _controller.stream;

  @override
  void dispose() {
    _reconnectTimer?.cancel(); // 타이머 정리
    _channel?.sink.close(); // WebSocket 연결 종료
    _controller.close(); // 스트림 컨트롤러 종료
    print('RealWebSocketRepository disposed.');
  }
}

// ----------- 더미 WebSocketRepository (개발/테스트 용) -----------
// 실제 서버 연결 없이 앱의 UI나 로직 테스트 시 사용
class DummyWebSocketRepository implements WebSocketRepository {
  final StreamController<SensorData> _controller =
      StreamController<SensorData>.broadcast();
  Timer? _timer;

  DummyWebSocketRepository() {
    _startDummyData();
  }

  void _startDummyData() {
    print('Starting Dummy WebSocket Service...');
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final dummyData = SensorData(
        temperature: 20.0 + sin(DateTime.now().second * pi / 30) * 5,
        humidity: 50.0 + cos(DateTime.now().second * pi / 30) * 10,
        lightLevel: (300 + sin(DateTime.now().second * pi / 30) * 100).toInt(),
        plantId: 1,
        timestamp: DateTime.now(),
      );
      _controller.add(dummyData);
      // print('Dummy data sent: ${dummyData.temperature}');
    });
  }

  @override
  Stream<SensorData> get sensorDataStream => _controller.stream;

  @override
  void connect() {
    print('Dummy WebSocket Repository connected.');
    // 더미는 연결 시도하자마자 데이터 생성 시작
    if (_timer == null || !_timer!.isActive) {
      _startDummyData();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.close();
    print('DummyWebSocketRepository disposed.');
  }
}
