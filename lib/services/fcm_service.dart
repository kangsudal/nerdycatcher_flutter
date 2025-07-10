import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/app/routes/app_router.dart';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// FcmService는 반드시 [fcmServiceProvider]를 통해 주입받아야 합니다.
/// 예: `ref.read(fcmServiceProvider)`

class FcmService {
  final FirebaseMessaging _messaging;

  FcmService._(this._messaging);

  factory FcmService(FirebaseMessaging messaging) {
    return FcmService._(messaging);
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission();
    print('알림 권한 설정 상태: ${settings.authorizationStatus}');
    switch (settings.authorizationStatus) {
      case AuthorizationStatus.authorized:
        print('사용자가 알림 권한을 허용했습니다.');
        break;
      case AuthorizationStatus.provisional:
        print('임시로 알림 권한이 허용되었습니다.');
        break;
      case AuthorizationStatus.denied:
        print('사용자가 알림 권한을 거부했습니다.');
        break;
      default:
        print('알 수 없는 권한 상태입니다.');
        break;
    }
  }

  Future<String?> getFcmToken() async {
    // iOS에서는 APNs 토큰이 준비될 때까지 기다려야 합니다.
    if (Platform.isIOS) {
      String? apnsToken = await _messaging.getAPNSToken();
      if (apnsToken == null) {
        print('APNs 토큰을 가져올 수 없습니다. 잠시 후 다시 시도합니다.');
        // 잠시 대기 후 다시 시도하는 로직을 추가할 수 있습니다.
        await Future.delayed(Duration(seconds: 1));
        apnsToken = await _messaging.getAPNSToken();
      }
      print('APNS 토큰: $apnsToken');
    }

    // APNs 토큰이 준비된 후 FCM 토큰을 요청합니다.
    final fcmToken = await _messaging.getToken();
    print('FCM 토큰: $fcmToken');
    return fcmToken;
  }

  Future<void> initializeListeners() async {
    // Foreground 수신
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification == null) {
        return;
      }
      print('포그라운드 수신: ${message.notification?.title}');
      //연동하기-3 강의 11:34 참고하기

      final context = navigatorKey.currentContext;
      ScaffoldMessenger.of(context!).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(message.notification!.title!,textAlign: TextAlign.left,),
              Text(message.notification!.body!),
            ],
          ),
          action: SnackBarAction(
            label: '보기',
            onPressed: () {
              GoRouter.of(context).goNamed(
                'dashboard',
                pathParameters: {'plantId': message.data['plant_id']!},
              );
            },
          ),
        ),
      );
    });

    // Background 수신
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final context = navigatorKey.currentContext;
      final deeplink = message.data['deeplink'];
      if (context != null && deeplink != null) {
        GoRouter.of(context).goNamed(
          'dashboard',
          pathParameters: {'plantId': message.data['plant_id']!},
        );
      }
    });

    // 앱이 종료상태일때
    final firstMessage = await _messaging.getInitialMessage();
    if (firstMessage != null) {
      final context = navigatorKey.currentContext;
      final deeplink = firstMessage.data['deeplink'];
      if (context != null && context.mounted && deeplink != null) {
        GoRouter.of(context).goNamed(
          'dashboard',
          pathParameters: {'plantId': firstMessage.data['plantId']!},
        );
      }
    }

    final currentToken = await getFcmToken();
    print('현재 FCM 토큰: $currentToken');

    _messaging.onTokenRefresh.listen((newToken) {
      print('새로운 FCM 토큰: $newToken');
      updateFcmTokenIfNeeded(newToken);
    });
  }

  Future<void> updateFcmTokenIfNeeded(String token) async {
    final session = Supabase.instance.client.auth.currentSession;
    final user = session?.user;

    if (user != null) {
      await Supabase.instance.client
          .from('users')
          .update({'fcm_token': token})
          .eq('id', user.id);
      print('FCM 토큰을 성공적으로 갱신했습니다.');
    }
  }
}
