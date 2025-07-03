import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/app/routes/route_names.dart';
import 'package:nerdycatcher_flutter/providers/fcm_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  @override
  void dispose() {
    // 페이지가 사라질 때 리스너를 반드시 해제해야 메모리 누수가 없습니다.
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _redirect() async {
    // 위젯이 마운트될 때까지 잠시 기다립니다.
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    // 인증 상태 스트림을 구독합니다.
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final session = data.session;
      if (session != null) {
        // 로그인 상태이면 홈 화면으로 보냅니다.
        context.goNamed(RouteNames.home);
      } else {
        // 로그아웃 상태이면 로그인 화면으로 보냅니다.
        context.goNamed(RouteNames.signin);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset('assets/images/nerdy.png', height: 200),
          Text(
            'Nerdy',
            style: TextStyle(
              fontFamily: 'Intl',
              fontSize: 50,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Catcher',
            style: TextStyle(
              fontFamily: 'Intl',
              fontSize: 50,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
