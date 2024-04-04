import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../page/login_page.dart';
import '../page/main_page.dart';
import '../utils/provider.dart';

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

  static void showSignInFailedEmailVerification(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '로그인 실패',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
              '''이메일 인증이 완료되지 않았습니다. \
등록한 이메일을 확인하시어 메일 인증을 진행해주세요.'''
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

  static void showSuccessToUpdateUserInfo(BuildContext context, Map<String, dynamic> user_info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '회원정보 수정 완료',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
              '회원 정보 수정이 완료됐습니다.'
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String encoded_data = jsonEncode(user_info);
                Provider.of<SharedPreferencesProvider>(context, listen: false).setData('user_info', encoded_data);

                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => MainPage()),
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

  static void showSuccessToUpdateEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Container(
            alignment: Alignment.center,
            child: const Text(
              '회원정보 수정 완료',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.blue
              ),
            ),
          ),
          content: const Text(
              '''회원 정보 수정이 완료됐습니다. \
등록된 이메일을 확인 후, 메일 인증을 진행해주세요.'''
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Provider.of<SharedPreferencesProvider>(context, listen: false).deleteData();

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
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

  static void showCheckVideoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("경보를 해제합니다."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Icon(
                Icons.check_circle_outline_outlined,
                color: Colors.green,
                size: 80,
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                style: ButtonStyle(
                  foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.lightGreen),
                ),
                // TODO : 경보 해제시 알림 꺼지는 기능 구현 필요
                child: Text("확인"),
              ),
            ),
          ],
        );
      },
    );
  }
}
