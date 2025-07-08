import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/providers/fcm_provider.dart';
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
  Future<void> signin({required String email, required String password}) async {
    // 로딩 상태로 변경 -> UI에서 로딩 인디케이터를 보여줄 수 있음
    state = const AsyncValue.loading();

    // state = await AsyncValue.guard(...) 패턴 사용
    // 이 패턴은 try-catch 블록을 훨씬 깔끔하게 만들어 줍니다.
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw Exception('로그인 실패: 사용자 없음');
      }

      // public.users 테이블에 유저가 없으면 추가
      await ensureUserExists();
    });
  }

  Future<void> ensureUserExists() async {
    final user = Supabase.instance.client.auth.currentUser;
    final fcmToken =
        await ref.read(fcmServiceProvider).getFcmToken(); // FCM 토큰 비동기로 얻기
    final nickname = user?.email?.split('@').first ?? '익명'; // 기본 닉네임 처리 예시

    if (user == null) return;

    // 이미 등록된 유저인지 확인
    final existing =
        await Supabase.instance.client
            .from('users')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
    // 등록되어 있지 않다면 추가
    if (existing == null) {
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'fcmToken': fcmToken,
        'nickname': nickname,
      });
    }
  }
}

// 4. Provider 생성
// 이 provider를 통해 UI에서 ViewModel을 사용합니다.
final signinViewmodelProvider =
    AsyncNotifierProvider.autoDispose<SigninViewModel, void>(
      () => SigninViewModel(),
    );
