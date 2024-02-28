import 'package:demo/page/main_page.dart';
import 'package:flutter/material.dart';

//TODO: 추후 main()은 splash 화면으로 대체
void main() {
  runApp(const LoginPage());
}

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
          margin: EdgeInsets.only(top: 70),
          child: Text(
            '로그인',
            style: TextStyle(
                color: Colors.black,
                fontSize: 35,
                fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 70,top: 100, right: 70),
            child: Column(
              children: [
                //TODO: 구글 로그인 이미지로 대체
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp())
                    );
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/symbol/google_symbol.png',
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 20),
                      Text('구글 로그인하기')
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                //TODO: 네이버 로그인 이미지로 대체
                ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/symbol/naver_symbol.png',
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 20),
                      Text('네이버 로그인하기')
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: 15,),
                //TODO: 카카오 로그인 이미지로 대체
                ElevatedButton(
                  onPressed: () {},
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/symbol/kakao_symbol.png',
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 20),
                      Text('카카오 로그인하기')
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            )
        ),
      ],
    );
  }
}