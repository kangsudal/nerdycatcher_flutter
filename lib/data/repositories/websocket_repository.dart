// lib/data/repositories/websocket_repository.dart

import 'dart:async';
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:nerdycatcher_flutter/services/fcm_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  // --- 인증 상태를 관리하기 위한 스트림 추가 ---
  final BehaviorSubject<bool> _authStatus = BehaviorSubject.seeded(false);

  Stream<bool> get authStatusStream => _authStatus.stream;

  bool get isAuthenticated => _authStatus.value;

  Timer? _reconnectTimer;
  static const Duration _reconnectInterval = Duration(seconds: 5); // 재연결 시도 간격

  NerdyCatcherSocketRepository(this.url); // 생성자에서 URL을 받음

  @override
  Future<void> connect() async {
    // 현재 로그인 세션에서 Access Token을 가져옵니다.
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    if (accessToken == null) {
      print('❌ 로그인 상태가 아니므로 소켓에 연결할 수 없습니다.');
      return;
    }

    if (_channel != null && _channel!.closeCode == null) {
      print('WebSocket is already connected.');
      return; // 이미 연결되어 있으면 다시 연결 시도하지 않음
    }
    _reconnectTimer?.cancel(); // 기존 재연결 타이머가 있다면 취소

    print('Attempting to connect to WebSocket: $url');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 연결 후 인증 로직 실행
      _authenticate();
      _channel!.stream.listen(
        (message) {
          handleWebSocketMessage(message);
        },
        onError: (error) {
          print('WebSocket Error: $error');
          _authStatus.add(false); // 에러시 인증 해제
          _reconnect(); // 오류 발생 시 재연결 시도
        },
        onDone: () {
          print('WebSocket disconnected. Attempting to reconnect...');
          _authStatus.add(false); // 연결 종료 시 인증 해제
          _reconnect(); // 연결 종료 시 재연결 시도
        },
      );
    } catch (e) {
      print('WebSocket connection initial failure: $e');
      _authStatus.add(false);
      _reconnect(); // 초기 연결 실패 시 재연결 시도
    }
  }

  // 인증 로직을 별도 메서드로 분리
  Future<void> _authenticate() async {
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null) {
      print('❌ 로그인 토큰이 없어 인증할 수 없습니다.');
      _channel?.sink.close();
      return;
    }

    final authMessage = {'type': 'auth', 'token': accessToken};
    _channel!.sink.add(jsonEncode(authMessage));
    print('🔐 인증 메시지 전송...');
  }

  //서버에서 받은 메시지를 JSON으로 파싱하고 SensorData로 변환
  void handleWebSocketMessage(String message) {
    try {
      final Map<String, dynamic> json = jsonDecode(message);

      switch (json['type']) {
        case 'auth_success':
          print('✅ 웹소켓 인증 성공! 재연결 시도를 중단합니다.');
          _authStatus.add(true);
          // 👇 인증 성공 시, 재연결 타이머를 확실하게 중지합니다.
          _reconnectTimer?.cancel();
          break;
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
    // 이미 타이머가 돌고 있다면 새로 만들지 않습니다.
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectTimer = Timer.periodic(_reconnectInterval, (timer) {
      print('Reattempting WebSocket connection...');
      // 그냥 연결만 시도합니다. 성공 여부 판단은 다른 곳에서 합니다.
      connect();
    });
  }

  @override
  Stream<SensorData> get sensorDataStream => _controller.stream;

  @override
  void dispose() {
    _reconnectTimer?.cancel(); // 타이머 정리
    _authStatus.close(); // 인증 해제
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
