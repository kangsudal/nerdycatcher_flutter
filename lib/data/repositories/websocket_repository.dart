// lib/data/repositories/websocket_repository.dart

import 'dart:async';
import 'dart:convert'; // JSON 파싱을 위해 필요
import 'package:flutter/foundation.dart';
import 'package:nerdycatcher_flutter/services/fcm_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket 통신 라이브러리
import '../models/sensor_data.dart'; // SensorData 모델 임포트
import 'dart:math'; // 더미 데이터 생성을 위해 임포트

// 모든 WebSocket 관련 로직을 캡슐화하는 추상 클래스
abstract class WebSocketRepository {
  Future<void> connectAndListen(
    StreamController<SensorData> sensorDataController,
  );

  void dispose();
}

// 실제 WebSocket 통신을 구현하는 클래스
class NerdyCatcherSocketRepository implements WebSocketRepository {
  final String url;
  WebSocketChannel? _channel;

  NerdyCatcherSocketRepository(this.url); // 생성자에서 URL을 받음

  // 연결하고 듣기
  @override
  Future<void> connectAndListen(
    StreamController<SensorData> sensorDataController,
  ) async {
    // 현재 로그인 세션에서 Access Token을 가져옵니다.
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;

    if (accessToken == null) {
      throw Exception('로그인 상태가 아니므로 소켓에 연결할 수 없습니다.');
    }

    try {
      debugPrint('소켓 연결을 시작합니다: $url');
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 서버에 인증 메시지 보냄
      _authenticate(accessToken);
      // WebSocket에서 응답받은 받은 메시지를 처리
      _channel!.stream.listen(
        (message) {
          // UI, Provider, ViewModel 등 sensorDataController.stream을 구독하는 모등 대상에게 센서 데이터를 전달
          handleWebSocketMessage(message, sensorDataController);
        },
        onError: (error) {
          debugPrint('소켓에서 응답받은 메시지 처리하는데 에러 발생: $error');
        },
        onDone: () {
          debugPrint('소켓 연결이 종료되었습니다.');
        },
      );
    } catch (e) {
      debugPrint('소켓 연결에 실패했습니다: $e');
      throw Exception('소켓 연결에 실패했습니다.');
    }
  }

  // 인증 메시지 보내기
  // 나 로그인된 사용자야! 이 토큰으로 확인해줘
  // token은 Supabase에서 로그인한 사용자의 JWT(접근 토큰)
  Future<void> _authenticate(String accessToken) async {
    final authMessage = {'type': 'auth', 'token': accessToken};
    _channel!.sink.add(jsonEncode(authMessage));
    print('서버에 인증 메시지를 보냈습니다.');
  }

  //서버에서 받은 메시지를 JSON으로 파싱하고 SensorData로 변환
  void handleWebSocketMessage(
    String message,
    StreamController<SensorData> sensorDataController,
  ) {
    try {
      final Map<String, dynamic> json = jsonDecode(message);

      switch (json['type']) {
        case 'auth_success':
          // Flutter -> 서버 : {'type': 'auth', 'token': '...'}로 메세지를 보냈을때ㅣ
          // 서버 -> Flutter : 서버가 토큰을 성공적으로 검증하면, {'type': 'auth_success'} 메시지를 응답으로 보내줌
          debugPrint('웹소켓 인증 성공!');
          break;
        case 'sensor_data':
          final data = json['data'];
          if (data != null) {
            final sensorData = SensorData.fromJson(data);
            print('📥 수신된 센서 데이터: $sensorData');
            sensorDataController.add(sensorData); //스트림에 전송
          }
          break;

        case 'identify':
          print('👋 Identify 메시지 수신: ${json['name']}');
          break;

        default:
          print('⚠️ 알 수 없는 메시지 타입: ${json['type']}');
      }
    } catch (e) {
      print('JSON 파싱 실패: $e');
    }
  }

  @override
  void dispose() {
    // _reconnectTimer?.cancel(); // 타이머 정리
    // _authStatus.close(); // 인증 해제
    _channel?.sink.close(); // WebSocket 연결 종료
  }
}
