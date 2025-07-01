import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/providers/fcm_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(fcmServiceProvider).requestPermission();
      await ref.read(fcmServiceProvider).initializeListeners();

      final bool isLoggedIn = true; // TODO: 로그인 상태 확인 로직으로 바꾸기

      if (!mounted) return;

      if (isLoggedIn) {
        context.pushNamed('home');
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
