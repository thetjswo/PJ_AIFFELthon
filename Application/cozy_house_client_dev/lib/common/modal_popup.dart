import 'package:flutter/material.dart';

import '../page/login_page.dart';

class ModalPopUp {
  static void showSignUpSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '축하합니다!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
            '''회원가입이 성공적으로 완료되었습니다. \
이메일 인증 후, 로그인 부탁드립니다.'''
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement( // 현재 화면을 대체하면서 이동
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                );
              },
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.blue
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  static void showSignUpFailedExistAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '회원가입 실패',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
              '''이미 생성된 계정이 있습니다. \
기존 계정으로 로그인 부탁드립니다.'''
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement( // 현재 화면을 대체하면서 이동
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                );
              },
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  '확인',
                  style: TextStyle(
                      color: Colors.blue
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showSignUpFailedWeakPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '회원가입 실패',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
              '''패스워드가 해킹 위험이 있습니다. \
복잡한 패스워드로 설정해주세요.'''
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement( // 현재 화면을 대체하면서 이동
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // 로그인 페이지로 이동
                );
              },
              child: Container(
                alignment: Alignment.center,
                child: const Text(
                  '확인',
                  style: TextStyle(
                      color: Colors.blue
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
