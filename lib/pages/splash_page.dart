import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2)).then((_) {
      if (!mounted) return;
      final bool isLoggedIn = false; // TODO: 로그인 상태 확인 로직으로 바꿔야함

      if (isLoggedIn) {
        context.goNamed('dashboard'); // 홈 라우트 이름
      } else {
        context.goNamed('authSelection');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          '🌱 Nerdy Catcher',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
