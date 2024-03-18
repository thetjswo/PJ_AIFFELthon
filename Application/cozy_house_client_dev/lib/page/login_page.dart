import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:cozy_house_client_dev/common/styles.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(children: [
          LoginWidget(),
        ]),
      ),
    );
  }
}

class LoginWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 30),
          child: Text(
            'LOGIN',
            style: TextStyle(
                color: Color(0xFFA1DEFF),
                fontSize: 25,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 70, right: 70),
            child: Column(
              children: [
                Image.asset('assets/images/icon/ic_login_upper.png'),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'example@example.com',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.email),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '이메일을 입력하세요';
                          }
                          // TODO: 이메일 형식 검사 추가
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요...',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.password_rounded),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '비밀번호를 입력하세요';
                          }
                          // TODO: 비밀번호 형식 검사 추가
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: Styles.buttonStyle_bg,
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Need an account?',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey
                        ),
                      ),
                      TextButton(
                        onPressed: () {

                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.blue
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
        ),
      ],
    );
  }
}