import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nerdycatcher_flutter/providers/fcm_provider.dart';
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
      try{

      } catch (error) {
        throw Exception(error);
        debugPrint('error: $error');
      }
    });
  }
}

final signupViewmodelProvider =
    AsyncNotifierProvider.autoDispose<SignupViewModel, void>(
      () => SignupViewModel(),
    );
