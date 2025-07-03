import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupViewModel extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> signup({required String email, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 이 부분만 다릅니다!
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
    });
  }
}

final signupViewmodelProvider =
    AsyncNotifierProvider.autoDispose<SignupViewModel, void>(
      () => SignupViewModel(),
    );
