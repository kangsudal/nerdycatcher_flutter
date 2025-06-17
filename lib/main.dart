// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/pages/dashboard_page.dart'; // 수정: screens/dashboard_page.dart

void main() {
  // Riverpod 사용을 위해 ProviderScope로 앱을 감싸줍니다.
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nerdycatcher',
      theme: ThemeData(
        primarySwatch: Colors.green, // 테마 색상 설정
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: Colors.white,
        ),
      ),
      home: DashboardPage(), // 시작 화면을 DashboardPage로 설정
    );
  }
}