import 'dart:convert';
import 'dart:math';
import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../api/security_policy.dart';
import '../common/styles.dart';
import '../utils/provider.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static String wsUrlDetection = dotenv.get('WS_URL_DETECT');

  // Initialize WebSocket instance
  final WebSocket _socket = WebSocket(wsUrlDetection);
  bool _isConnected = false;

  bool _toggleState = false;
  bool _defaultState = true; // DB에 데이터 없는 상태(앱 첫 실행 상태)
  bool _firstToggle = false; // 첫 번째 토글 여부를 추적

  late String _uid;

  @override
  void initState() {
    super.initState();

    _uid = Provider.of<SharedPreferencesProvider>(context, listen: false)
        .getData('uid')!;

    if (Provider.of<SharedPreferencesProvider>(context, listen: false)
            .getData('detection_yn') ==
        'true')
      _firstToggle = true;
    else
      _firstToggle = false;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  void connect(BuildContext context) async {
    _socket.connect(wsUrlDetection);
    _socket.send('on');
    print('Security Policy on');
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.send('off');
    print('Security Policy off');
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  Future<void> _toggleImage() async {
    bool result = await SecurityPolicy().changeSecurityPolicyFlag(_uid);

    setState(() {
      // _toggleState = result;
      if (result) {
        _controller.forward(from: 0.0);
        _firstToggle = true; // 토글 ON
        _defaultState = false; // 토글 누르면 무조건 false
        Provider.of<SharedPreferencesProvider>(context, listen: false)
            .setData('detection_yn', _firstToggle.toString());
        connect(context);
      } else {
        _controller.reverse(from: 1.0);
        _firstToggle = false; // 토글 OFF
        _defaultState = false; // 토글 누르면 무조건 false
        disconnect();
        _firstToggle = result; // 토글 ON
        Provider.of<SharedPreferencesProvider>(context, listen: false)
            .setData('detection_yn', _firstToggle.toString());
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
                flex: 5, // 비율에 따른 section 배정
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'COZY HOUSE',
                        style: Styles.textStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 36, // 설정 가능한 폰트 사이즈
                        ),
                      ),
                      SizedBox(height: 15), // 2번과 3번 사이의 줄간 간격
                      Text(
                        'SMART HOME SECURITY',
                        style: Styles.textStyle(
                          fontWeight: FontWeight.w200, // Extra Light
                          fontSize: 18, // 설정 가능한 폰트 사이즈
                        ),
                      ),
                      SizedBox(height: 5), // 3번과 4번 사이의 줄간 간격
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '외부인이 감지되면 푸시 알람을 전송합니다.',
                              style: Styles.textStyle(
                                fontSize: 14,
                              ),
                            )
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5), // 4번과 5번 사이의 줄간 간격
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '외부인 감지 기능을 ',
                              style: Styles.textStyle(
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: 'ON / OFF ',
                              style: Styles.textStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '하려면 ',
                              style: Styles.textStyle(
                                fontSize: 15,
                              ),
                            ),
                            TextSpan(
                              text: '버튼을 누르세요.\n',
                              style: Styles.textStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: '(감지 기능이 ',
                              style: Styles.textStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: 'OFF',
                              style: Styles.textStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: '되면 ',
                              style: Styles.textStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: '푸시알람이 전송되지 않습니다.)',
                              style: Styles.textStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
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
                          _animation.value,
                          170,
                          _firstToggle,
                          _defaultState,
                        ), // 크기 조절
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
  final bool defaultState; // 앱 첫 실행 상태를 나타내는 변수

  MyPainter(
    this.animationValue,
    this.circleSize,
    this.firstToggle,
    this.defaultState,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill; // 원 내부 채우기

    // 앱 첫 실행이면 grey
    if (defaultState) {
      paint.color = Colors.grey.withOpacity(0.3);
    } else {
      paint.color = firstToggle
          ? Color(0xFFC8E6C9).withOpacity(0.3) // Toggled ON, 초록색
          : Color(0xFFFFCDD2).withOpacity(0.3); // Toggled OFF, 빨간색
    }

    // 원 그리기
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), // 원의 중심점
      circleSize / 2, // circleSize를 사용하여 원의 크기 조절
      paint,
    );

    // 테두리 그리기
    paint.color = firstToggle
        ? Color(0xFFAED581)
        : Color(0xFFEF9A9A); // 토글 ON 시 초록색, OFF 시 빨간색
    paint.style = PaintingStyle.stroke;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가

    final double sweepAngle = 2 * pi * animationValue;
    final double strokeWidth = 3.0; // 테두리의 두께
    final double radius =
        circleSize / 2 - strokeWidth / 2; // circleSize를 사용하여 원의 크기 조절

    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2), radius: radius),
      -pi / 2, // 시작 각도
      sweepAngle, // 화면 크기에 따른 그림자 이동 각도
      false,
      paint,
    );

    // // 원 내부 이미지 추가
    // if (firstToggle) {
    //   drawImage(canvas, size, 'assets/images/icon/security_img_green.png');
    // } else {
    //   drawImage(canvas, size, 'assets/images/icon/security_img_red.png');
    // }
  }

  void drawImage(Canvas canvas, Size size, String imagePath) {
    final ImageStream stream =
        AssetImage(imagePath).resolve(ImageConfiguration.empty);
    stream.addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
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
          center:
              Offset(size.width / 2, size.height / 2), // 캔버스의 중앙을 기준으로 중심점 설정
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
