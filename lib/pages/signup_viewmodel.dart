import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupViewModel extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signup({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('회원가입에 실패하였습니다.');
      }

      // public.users 테이블에 해당 유저 등록
      await Supabase.instance.client.from('users').insert({
        'id': user.id,
        'email': email,
        // 필요시 fcm_token이나 닉네임 등 추가 필드 여기에!
      });
    });
  }
}

final signupViewmodelProvider =
    AsyncNotifierProvider.autoDispose<SignupViewModel, void>(
      () => SignupViewModel(),
    );
