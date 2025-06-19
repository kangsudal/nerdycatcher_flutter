// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/other/routes/app_router.dart';

void main() {
  // Riverpod 사용을 위해 ProviderScope로 앱을 감싸줍니다.
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        // 테마 색상 설정
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF79747E),
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: false,
      ),
      routerConfig: appRouter,
    );
  }
}
