import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool _defaultState = true; // DB에 데이터 없는 상태(앱 첫 실행 상태)
  bool _firstToggle = false; // 첫 번째 토글 여부를 추적

  late String _uid;
  List<String> imagePaths = [
    'assets/images/icon/security_img_green.png', // 초록 이미지
    'assets/images/icon/security_img_red.png', // 빨강 이미지
  ];

  List<ui.Image> rawImages = [];

  _SecurityPageState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      List<ui.Image> newImages = [];

      newImages.add(await _loadImage(imagePaths[0]));
      newImages.add(await _loadImage(imagePaths[1]));

      setState(() {
        rawImages = newImages;
      });
    });
  }

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
    final Map<String, dynamic> data = {
      'uid': _uid,
      'message': 'on',
    };

    final String jsonData = jsonEncode(data);

    _socket.send(jsonData);
    print('Security Policy on');
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    final Map<String, dynamic> data = {
      'uid': _uid,
      'message': 'off',
    };

    final String jsonData = jsonEncode(data);
    _socket.send(jsonData);
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
        // _defaultState = false; // 토글 누르면 무조건 false
        _firstToggle = result; // 토글 ON
        Provider.of<SharedPreferencesProvider>(context, listen: false)
            .setData('detection_yn', _firstToggle.toString());
        connect(context);
      } else {
        _controller.reverse(from: 1.0);
        // _defaultState = false; // 토글 누르면 무조건 false
        _firstToggle = result; // 토글 OFF
        Provider.of<SharedPreferencesProvider>(context, listen: false)
            .setData('detection_yn', _firstToggle.toString());
        disconnect();
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
                      SizedBox(height: 10), // 2번과 3번 사이의 줄간 간격
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
                          animationValue: _animation.value,
                          circleSize: 170,
                          firstToggle: _firstToggle,
                          defaultState: _defaultState,
                          rawImages: rawImages,
                        ), // 크기 조절
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 3, // 비율에 따른 section 배정
                child: Center(
                  child: SizedBox(
                    width: 1080,
                    height: 434,
                    child: Image.asset(
                      'assets/images/icon/camera_img2.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<ui.Image> _loadImage(String imagePath) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Uint8List uint8List = data.buffer.asUint8List();
    final ui.Codec codec = await ui.instantiateImageCodec(uint8List);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

// 토글 위젯
class MyPainter extends CustomPainter {
  final double animationValue;
  final double circleSize; // 원의 크기를 나타내는 변수 추가
  final bool firstToggle;
  final bool defaultState;
  final List<ui.Image> rawImages;

  MyPainter({
    required this.animationValue,
    required this.circleSize,
    required this.firstToggle,
    required this.defaultState,
    required this.rawImages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill
      ..color = firstToggle
          ? Color(0xFFC8E6C9).withOpacity(0.3)
          : Color(0xFFFFCDD2).withOpacity(0.3);

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35, // Adjust the circle size as needed
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

    // 토글 색상별 집 이미지 추가
    if (rawImages.isNotEmpty) {
      if (firstToggle) {
        _drawImage(canvas, size, rawImages[0]);
      } else {
        _drawImage(canvas, size, rawImages[1]);
      }
    }
  }

  void _drawImage(Canvas canvas, Size size, ui.Image image) {
    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();
    final double desiredWidth = size.width * 0.5;
    final double desiredHeight = (desiredWidth * imageHeight) / imageWidth;

    canvas.drawImageRect(
      image,
      Rect.fromLTRB(0, 0, imageWidth, imageHeight),
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: desiredWidth,
        height: desiredHeight,
      ),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
