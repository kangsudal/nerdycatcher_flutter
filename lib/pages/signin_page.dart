import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/app/routes/route_names.dart';
import 'package:nerdycatcher_flutter/pages/signin_viewmodel.dart';

class SigninPage extends ConsumerStatefulWidget {
  const SigninPage({super.key});

  @override
  ConsumerState<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends ConsumerState<SigninPage> {
  String? email;

  String? password;

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      children: [
                        Text(
                          'Nerdy',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          'Catcher',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 60,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 36),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '이메일',
                    hintText: 'example@kangsudal.com',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력하세요';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return '올바른 이메일 형식을 입력하세요';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    email = value;
                  },
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요';
                    }
                    if (!RegExp(
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$',
                    ).hasMatch(value)) {
                      return '영문자, 숫자, 특수문자를 포함하여 최소 8자 이상이어야 합니다';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    password = value;
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () async {
                        try {
                          context.pushNamed(RouteNames.resetPassword);
                        } catch (e) {
                          debugPrint('tap');
                        }
                      },
                      child: Text(
                        '비밀번호 재설정하기',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoButton(
                    color: Colors.black,
                    onPressed:
                        ref.watch(signinViewmodelProvider).isLoading
                            ? null
                            : () async {
                              final signinViewmodel = ref.read(
                                signinViewmodelProvider.notifier,
                              );
                              final form = formKey.currentState;
                              if (form == null || !form.validate()) return;
                              form.save();
                              try {
                                await signinViewmodel.signin(
                                  email: email!,
                                  password: password!,
                                );
                                final result = ref.read(
                                  signinViewmodelProvider,
                                );

                                if (result.hasError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('로그인 실패'),
                                    ),
                                  );

                                  debugPrint('로그인 실패: ${result.error}');
                                  return;
                                }

                                await signinViewmodel.ensureUserExists();
                                if (context.mounted) {
                                  context.goNamed(RouteNames.home);
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                    child:
                        ref.watch(signinViewmodelProvider).isLoading
                            ? const CupertinoActivityIndicator()
                            : Text(
                              '로그인',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('계정이 없으신가요? '),
                    TextButton(
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.zero,
                        ),
                      ),
                      onPressed: () {
                        context.pushNamed(RouteNames.signup);
                      },
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide()),
                        ),
                        child: Text(
                          ' 회원가입 하기',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
