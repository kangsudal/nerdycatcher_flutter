import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nerdycatcher_flutter/other/routes/route_names.dart';

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
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 50,
        ),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Spacer(),
              Text('당신의 건강 도우미'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '리터러시',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      'K',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
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
                      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$')
                      .hasMatch(value)) {
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
                      try{
                        context.goNamed(RouteNames.resetPassword);
                      }catch(e){
                        debugPrint('tap');

                      }
                    },
                    child: Text('비밀번호 재설정하기'),
                  )
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // final signinViewmodel =
                    // ref.read(signinViewmodelProvider.notifier);
                    final form = formKey.currentState;
                    if (form == null || !form.validate()) return;
                    form.save();
                    // try {
                    //   await signinViewmodel.signin(
                    //       email: email!, password: password!);
                    // } on CustomError catch (e) {
                    //   if (!context.mounted) return;
                    //   ScaffoldMessenger.of(context)
                    //       .showSnackBar(SnackBar(content: Text(e.message)));
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '로그인',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
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
                      padding:
                      WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                    ),
                    onPressed: () {
                      context.goNamed(RouteNames.signup);
                    },
                    child: Text(' 회원가입 하기'),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}