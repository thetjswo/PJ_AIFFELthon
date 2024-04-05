// import 'package:flutter/material.dart';
//
// class SecurityPage extends StatefulWidget {
//   @override
//   _SecurityPageState createState() => _SecurityPageState();
// }
//
// class _SecurityPageState extends State<SecurityPage> {
//   bool _toggleState = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Container(
//         margin: EdgeInsets.only(top: 180),
//         child: Column(
//           children: [
//             AnimatedSwitcher(
//               duration: Duration(milliseconds: 500),
//               transitionBuilder: (Widget child, Animation<double> animation) {
//                 return FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 );
//               },
//               child: _toggleState
//                   ? Image.asset(
//                 'assets/images/icon/shield_4_green.png',
//                 key: UniqueKey(),
//                 width: 200,
//                 height: 200,
//               )
//                   : Image.asset(
//                 'assets/images/icon/shield_4_red.png',
//                 key: UniqueKey(),
//                 width: 200,
//                 height: 200,
//               ),
//             ),
//             SizedBox(height: 20),
//             Switch(
//               value: _toggleState,
//               onChanged: (value) {
//                 setState(() {
//                   _toggleState = value;
//                 });
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//

// 원+테두리 구현코드

// import 'dart:math';
// import 'package:flutter/material.dart';
//
//
// class SecurityPage extends StatefulWidget {
//   @override
//   _SecurityPageState createState() => _SecurityPageState();
// }
//
// class _SecurityPageState extends State<SecurityPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   bool _toggleState = false;
//   bool _firstToggle = true; // 첫 번째 토글 여부를 추적
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }
//
//   void _toggleImage() {
//     setState(() {
//       _toggleState = !_toggleState;
//       if (_toggleState) {
//         _controller.forward(from: 0.0);
//         _firstToggle = false; // 첫 번째 토글 완료
//       } else {
//         _controller.reverse(from: 1.0);
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: _toggleImage,
//         child: AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return CustomPaint(
//               size: Size(200, 200), // 원 크기를 조절
//               painter: MyPainter(_animation.value, 200, _firstToggle), // 크기 조절
//               child: Center(),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class MyPainter extends CustomPainter {
//   final double animationValue;
//   final double circleSize; // 원의 크기를 나타내는 변수 추가
//   final bool firstToggle; // 첫 번째 토글 여부를 나타내는 변수 추가
//
//   MyPainter(this.animationValue, this.circleSize, this.firstToggle);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = firstToggle
//           ? Colors.lightGreen.withOpacity(0.5)
//           : Colors.red.withOpacity(0.5) // 토글 상태에 따라 색상 변경
//       ..strokeWidth = 5.0
//       ..style = PaintingStyle.fill; // 원 내부 채우기
//
//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       circleSize / 2, // circleSize를 사용하여 원의 크기 조절
//       paint,
//     );
//
//     // 회색 테두리 그리기
//     paint.color = firstToggle ? Colors.green : Colors.red; // 토글 상태에 따라 색상 변경
//     paint.style = PaintingStyle.stroke;
//     paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가
//
//     final double sweepAngle = 2 * pi * animationValue;
//     final double strokeWidth = 5.0; // 테두리의 두께
//     final double radius = circleSize / 2 - strokeWidth / 2; // circleSize를 사용하여 원의 크기 조절
//
//     canvas.drawArc(
//       Rect.fromCircle(
//           center: Offset(size.width / 2, size.height / 2), radius: radius),
//       -pi / 2, // 시작 각도
//       sweepAngle, // 화면 크기에 따른 그림자 이동 각도
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }


//////////////////////////////////////////////////////////
// import 'dart:math';
// import 'package:flutter/material.dart';
//
// class SecurityPage extends StatefulWidget {
//   @override
//   _SecurityPageState createState() => _SecurityPageState();
// }
//
// class _SecurityPageState extends State<SecurityPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   bool _toggleState = false;
//   bool _firstToggle = true; // 첫 번째 토글 여부를 추적
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }
//
//   void _toggleImage() {
//     setState(() {
//       _toggleState = !_toggleState;
//       if (_toggleState) {
//         _controller.forward(from: 0.0);
//         _firstToggle = true; // 토글 ON
//       } else {
//         _controller.reverse(from: 1.0);
//         _firstToggle = false; // 토글 OFF
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: _toggleImage,
//         child: AnimatedBuilder(
//           animation: _animation,
//           builder: (context, child) {
//             return CustomPaint(
//               size: Size(220, 220), // 원 크기를 조절
//               painter: MyPainter(_animation.value, 220, _firstToggle), // 크기 조절
//               child: Center(),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class MyPainter extends CustomPainter {
//   final double animationValue;
//   final double circleSize; // 원의 크기를 나타내는 변수 추가
//   final bool firstToggle; // 첫 번째 토글 여부를 나타내는 변수 추가
//
//   MyPainter(this.animationValue, this.circleSize, this.firstToggle);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = firstToggle
//           ? Color(0xFFC8E6C9).withOpacity(0.3) // 토글 ON 시 초록색
//           : Color(0xFFFFCDD2).withOpacity(0.3) // 토글 OFF 시 빨간색
//       ..strokeWidth = 5.0
//       ..style = PaintingStyle.fill; // 원 내부 채우기
//
//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       circleSize / 2, // circleSize를 사용하여 원의 크기 조절
//       paint,
//     );
//
//     // 테두리 그리기
//     paint.color = firstToggle ? Color(0xFFAED581) : Color(0xFFEF9A9A); // 토글 ON 시 초록색, OFF 시 빨간색
//     paint.style = PaintingStyle.stroke;
//     paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가
//
//     final double sweepAngle = 2 * pi * animationValue;
//     final double strokeWidth = 3.0; // 테두리의 두께
//     final double radius = circleSize / 2 - strokeWidth / 2; // circleSize를 사용하여 원의 크기 조절
//
//     canvas.drawArc(
//       Rect.fromCircle(
//           center: Offset(size.width / 2, size.height / 2), radius: radius),
//       -pi / 2, // 시작 각도
//       sweepAngle, // 화면 크기에 따른 그림자 이동 각도
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }



//
// import 'dart:math';
// import 'package:flutter/material.dart';
//
// class SecurityPage extends StatefulWidget {
//   @override
//   _SecurityPageState createState() => _SecurityPageState();
// }
//
// class _SecurityPageState extends State<SecurityPage>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   bool _toggleState = false;
//   bool _firstToggle = true; // 첫 번째 토글 여부를 추적
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: Duration(milliseconds: 1000),
//     );
//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_controller);
//   }
//
//   void _toggleImage() {
//     setState(() {
//       _toggleState = !_toggleState;
//       if (_toggleState) {
//         _controller.forward(from: 0.0);
//         _firstToggle = true; // 토글 ON
//       } else {
//         _controller.reverse(from: 1.0);
//         _firstToggle = false; // 토글 OFF
//       }
//     });
//   }
//
//       @override
//       Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Rectangle40(), // Design elements
//         Center(
//           child: GestureDetector(
//             onTap: _toggleImage,
//             child: AnimatedBuilder(
//               animation: _animation,
//               builder: (context, child) {
//                 return CustomPaint(
//                   size: Size(220, 220), // 원 크기를 조절
//                   painter: MyPainter(_animation.value, 220, _firstToggle), // 크기 조절
//                   child: Center(),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
//
// class MyPainter extends CustomPainter {
//   final double animationValue;
//   final double circleSize; // 원의 크기를 나타내는 변수 추가
//   final bool firstToggle; // 첫 번째 토글 여부를 나타내는 변수 추가
//
//   MyPainter(this.animationValue, this.circleSize, this.firstToggle);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = firstToggle
//           ? Color(0xFFC8E6C9).withOpacity(0.3) // 토글 ON 시 초록색
//           : Color(0xFFFFCDD2).withOpacity(0.3) // 토글 OFF 시 빨간색
//       ..strokeWidth = 5.0
//       ..style = PaintingStyle.fill; // 원 내부 채우기
//
//     canvas.drawCircle(
//       Offset(size.width / 2, size.height / 2),
//       circleSize / 2, // circleSize를 사용하여 원의 크기 조절
//       paint,
//     );
//
//     // 테두리 그리기
//     paint.color = firstToggle ? Color(0xFFAED581) : Color(0xFFEF9A9A); // 토글 ON 시 초록색, OFF 시 빨간색
//     paint.style = PaintingStyle.stroke;
//     paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가
//
//     final double sweepAngle = 2 * pi * animationValue;
//     final double strokeWidth = 3.0; // 테두리의 두께
//     final double radius = circleSize / 2 - strokeWidth / 2; // circleSize를 사용하여 원의 크기 조절
//
//     canvas.drawArc(
//       Rect.fromCircle(
//           center: Offset(size.width / 2, size.height / 2), radius: radius),
//       -pi / 2, // 시작 각도
//       sweepAngle, // 화면 크기에 따른 그림자 이동 각도
//       false,
//       paint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
// class Rectangle40 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView( // SingleChildScrollView로 감싸기
//       child: Column(
//         children: [
//           Container(
//             width: 1080,
//             height: 2160,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment(0.00, -1.00),
//                 end: Alignment(0, 1),
//                 colors: [Colors.white, Color(0xFFE7E7E7)],
//               ),
//             ),
//           ),
//           Transform(
//             transform: Matrix4.identity()..translate(0.0, 0.0)..rotateZ(3.14),
//             child: Container(
//               width: 838.64,
//               height: 811.27,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: NetworkImage("https://via.placeholder.com/839x811"),
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 770,
//             height: 108,
//             child: Text.rich(
//               TextSpan(
//                 children: [
//                   TextSpan(
//                     text: '실시간 모니터링은 항상 진행 중입니다.\n만약 당신이',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400,
//                       height: 0,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' 켜기/끄기',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w600,
//                       height: 0,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' 버튼을 누르면,',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400,
//                       height: 0,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' 객체 감지 기능이 활성화되었다면,',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w600,
//                       height: 0,
//                     ),
//                   ),
//                   TextSpan(
//                     text: ' 버튼을 누르세요.',
//                     style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 24,
//                       fontFamily: 'Inter',
//                       fontWeight: FontWeight.w400,
//                       height: 0,
//                     ),
//                   ),
//                 ],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ),
//           SizedBox(
//             width: 798,
//             height: 102,
//             child: Text(
//               '스마트 홈 보안',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 48,
//                 fontFamily: 'Inter',
//                 fontWeight: FontWeight.w200,
//                 height: 0,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 934,
//             height: 155,
//             child: Text(
//               '아늑한 집',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 110,
//                 fontFamily: 'Inter',
//                 fontWeight: FontWeight.w700,
//                 height: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _toggleState = false;
  bool _firstToggle = true; // 첫 번째 토글 여부를 추적

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  void _toggleImage() {
    setState(() {
      _toggleState = !_toggleState;
      if (_toggleState) {
        _controller.forward(from: 0.0);
        _firstToggle = true; // 토글 ON
      } else {
        _controller.reverse(from: 1.0);
        _firstToggle = false; // 토글 OFF
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Color(0xFFE0E0E0),
              // Colors.grey,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4, // 비율에 따른 section 배정
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COZY HOUSE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36, // 설정 가능한 폰트 사이즈
                        ),
                      ),
                      SizedBox(height: 15), // 2번과 3번 사이의 줄간 간격
                      Text(
                        'SMART HOME SECURITY',
                        style: TextStyle(
                          fontWeight: FontWeight.w200, // Extra Light
                          fontSize: 18, // 설정 가능한 폰트 사이즈
                        ),
                      ),
                      SizedBox(height: 5), // 3번과 4번 사이의 줄간 간격
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '실시간 모니터링은 항상 진행 중입니다. \n ',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: '객체 감지 기능을 ',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'On/Off ',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '하려면 ',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: '버튼을 누르세요.',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4, // 비율에 따른 section 배정
                child: GestureDetector(
                  onTap: _toggleImage,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size(170, 170), // 원 크기를 조절
                        painter: MyPainter(
                            _animation.value, 170, _firstToggle), // 크기 조절
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 3, // 비율에 따른 section 배정
                child: Container(
                  width: double.infinity, // Expanded 위젯의 가로 크기를 꽉 채우게 설정
                  height: double.infinity,
                  child: Image.asset(
                    'assets/images/icon/camera_img2.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MyPainter extends CustomPainter {
  final double animationValue;
  final double circleSize; // 원의 크기를 나타내는 변수 추가
  final bool firstToggle; // 첫 번째 토글 여부를 나타내는 변수 추가

  MyPainter(this.animationValue, this.circleSize, this.firstToggle);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = firstToggle
          ? Color(0xFFC8E6C9).withOpacity(0.3) // 토글 ON 시 초록색
          : Color(0xFFFFCDD2).withOpacity(0.3) // 토글 OFF 시 빨간색
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill; // 원 내부 채우기

    // 원 그리기
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), // 원의 중심점
      circleSize / 2, // circleSize를 사용하여 원의 크기 조절
      paint,
    );

    // 테두리 그리기
    paint.color = firstToggle ? Color(0xFFAED581) : Color(0xFFEF9A9A); // 토글 ON 시 초록색, OFF 시 빨간색
    paint.style = PaintingStyle.stroke;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가

    final double sweepAngle = 2 * pi * animationValue;
    final double strokeWidth = 3.0; // 테두리의 두께
    final double radius = circleSize / 2 - strokeWidth / 2; // circleSize를 사용하여 원의 크기 조절

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      -pi / 2, // 시작 각도
      sweepAngle, // 화면 크기에 따른 그림자 이동 각도
      false,
      paint,
    );

    // 원 내부 이미지 추가
    if (firstToggle) {
      drawImage(canvas, size, 'assets/images/icon/security_img_green.png');
    } else {
      drawImage(canvas, size, 'assets/images/icon/security_img_red.png');
    }
  }

  void drawImage(Canvas canvas, Size size, String imagePath) {
    final ImageStream stream = AssetImage(imagePath).resolve(ImageConfiguration.empty);
    stream.addListener(ImageStreamListener((ImageInfo info, bool synchronousCall) {
      // 이미지의 원래 너비와 높이
      double imageWidth = info.image!.width.toDouble();
      double imageHeight = info.image!.height.toDouble();

      // 이미지의 원하는 너비 (현재 캔버스의 너비의 절반)
      final double desiredWidth = size.width * 0.5;

      // 이미지의 원하는 높이를 원래 비율을 유지하면서 계산
      final double desiredHeight = (desiredWidth * imageHeight) / imageWidth;

      // 이미지 크기 조정
      canvas.drawImageRect(
        info.image!,
        Rect.fromLTRB(0, 0, imageWidth, imageHeight), // 원본 이미지 크기 지정
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2), // 캔버스의 중앙을 기준으로 중심점 설정
          width: desiredWidth,
          height: desiredHeight,
        ),
        Paint(),
      );
    }));
  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

