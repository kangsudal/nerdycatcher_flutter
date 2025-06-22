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

    Future.delayed(const Duration(seconds: 1)).then((_) {
      if (!mounted) return;
      final bool isLoggedIn = true; // TODO: 로그인 상태 확인 로직으로 바꿔야함

      if (isLoggedIn) {
        context.pushNamed('home'); // 홈 라우트 이름
      } else {
        context.pushNamed('authSelection');
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
