import 'package:flutter/material.dart';


class Styles {
  static final buttonStyle =
      ElevatedButton.styleFrom(fixedSize: const Size(120.0, 10.0));

  static final buttonStyle2 = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 30),
    backgroundColor: Colors.blue,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(30),
      ),
    ),
    minimumSize: const Size(200, 40),
  );

  // 로그인 페이지 버튼 스타일 정의
  static final buttonStyle_bg = ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 80),
    backgroundColor: Color(0xFFA1DEFF),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    minimumSize: const Size(200, 30),
  );


  static const textStyle = TextStyle(
      color: Colors.blue,
      fontFamily: 'Kalam',
      fontSize: 20,
      fontWeight: FontWeight.bold);
}
