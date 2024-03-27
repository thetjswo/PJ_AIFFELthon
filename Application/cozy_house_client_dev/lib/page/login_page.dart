import 'dart:convert';

import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:cozy_house_client_dev/common/styles.dart';
import 'package:cozy_house_client_dev/page/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/signin.dart';
import '../utils/validator.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late String _userEmail;
  late String _userPassword;

  late SharedPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _userEmail = '';
    _userPassword = '';

    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _preferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                        color: Color(0xFFA1DEFF),
                        fontSize: 25,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(left: 70, right: 70),
                    child: Column(
                      children: [
                        Image.asset('assets/images/icon/ic_login_upper.png'),
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                focusNode: _emailFocus,
                                onChanged: (value) {
                                  setState(() {
                                    _userEmail = value; // 입력 값을 상태 변수에 저장
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'example@example.com',
                                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                                  prefixIcon: const Icon(Icons.email),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                validator: (value) => CheckValidate().validateEmail(_emailFocus, value!),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                              TextFormField(
                                obscureText: true,
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                                focusNode: _passwordFocus,
                                onChanged: (value) {
                                  setState(() {
                                    _userPassword = value; // 입력 값을 상태 변수에 저장
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '비밀번호를 입력하세요.',
                                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                                  prefixIcon: const Icon(Icons.password_rounded),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                              ),
                            ],
                          ),
                        ),
                        // TODO: 계정 기억하기 기능 추가
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {
                                final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                    email: _userEmail,
                                    password: _userPassword
                                );

                                // 기기 정보 갱신(기존 정보 없으면 추가)
                                await SignIn().sendDeviceInfoToServer(credential);
                                // 사용자 정보 요청
                                Map<String, dynamic> res = await SignIn().sendSignInDataToServer(credential);
                                String encoded_data = jsonEncode(res);

                                await _preferences.setString('user_info', encoded_data);

                                Navigator.pushReplacement(
                                  context,
                                  // 메인 화면으로 이동
                                  MaterialPageRoute(builder: (context) => const MainApp()),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (e.code == 'user-not-found') {
                                  print('No user found for that email.');
                                } else if (e.code == 'wrong-password') {
                                  print('Wrong password provided for that user.');
                                }
                              }
                            }
                          },
                          style: Styles.buttonStyle_bg,
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                                color: Colors.white
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Need an account?',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    // 회원가입 화면으로 이동
                                    MaterialPageRoute(builder: (context) => SignUpPage()),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.blue
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        // TODO: 계정 찾기 기능 추가
                      ],
                    )
                ),
              ],
            ),
          )
        )
      ),
    );
  }
}