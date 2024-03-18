import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:cozy_house_client_dev/common/styles.dart';
import 'package:cozy_house_client_dev/utils/validate.dart';
import 'package:cozy_house_client_dev/page/signup_page.dart';
import 'package:flutter/cupertino.dart';
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
  FocusNode _emailFocus = new FocusNode();
  FocusNode _passwordFocus = new FocusNode();

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
                        textInputAction: TextInputAction.next,
                        focusNode: _emailFocus,
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
                        validator: (value) => CheckValidate().validateEmail(_emailFocus, value!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                      TextFormField(
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        focusNode: _passwordFocus,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력하세요.',
                          hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                          prefixIcon: Icon(Icons.password_rounded),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          Navigator.push(
                            context,
                            // 메인 화면으로 이동
                            MaterialPageRoute(builder: (context) => SignUpPage()),
                          );
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