import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Notifier 클래스 생성
// AsyncValue<void>는 비동기 작업의 상태를 의미하며, 특별한 데이터는 없다는 뜻입니다.
class SigninViewModel extends AutoDisposeAsyncNotifier<void> {
  // 2. build 메서드 (초기 상태 설정)
  @override
  FutureOr<void> build() {
    // 초기에는 아무 일도 일어나지 않음
  }

  // 3. 로그인 메서드
  Future<void> signin({
    required String email,
    required String password,
  }) async {
    // 로딩 상태로 변경 -> UI에서 로딩 인디케이터를 보여줄 수 있음
    state = const AsyncValue.loading();

    // state = await AsyncValue.guard(...) 패턴 사용
    // 이 패턴은 try-catch 블록을 훨씬 깔끔하게 만들어 줍니다.
    state = await AsyncValue.guard(() async {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    });
  }
}

// 4. Provider 생성
// 이 provider를 통해 UI에서 ViewModel을 사용합니다.
final signinViewmodelProvider =
AsyncNotifierProvider.autoDispose<SigninViewModel, void>(
      () => SigninViewModel(),
);