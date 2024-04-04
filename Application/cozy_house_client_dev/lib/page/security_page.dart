import 'dart:math';
import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:cozy_house_client_dev/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  bool _firstToggle = true; // 첫 번째 토글 여부를 추적

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_controller);
  }

  void connect(BuildContext context) async {
    _socket.connect(wsUrlDetection);
    _socket.send('on');
    print('send data: on');
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.send('off');
    print('send data: off');
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  void _toggleImage() {
    setState(() {
      _toggleState = !_toggleState;
      if (_toggleState) {
        _controller.forward(from: 0.0);
        _firstToggle = true; // 토글 ON
        connect(context);
      } else {
        _controller.reverse(from: 1.0);
        _firstToggle = false; // 토글 OFF
        disconnect();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _toggleImage,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: Size(220, 220), // 원 크기를 조절
              painter: MyPainter(_animation.value, 220, _firstToggle), // 크기 조절
              child: Center(),
            );
          },
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
          ? Colors.green.withOpacity(0.5) // 토글 ON 시 초록색
          : Colors.red.withOpacity(0.5) // 토글 OFF 시 빨간색
      ..strokeWidth = 5.0
      ..style = PaintingStyle.fill; // 원 내부 채우기

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      circleSize / 2, // circleSize를 사용하여 원의 크기 조절
      paint,
    );

    // 테두리 그리기
    paint.color =
        firstToggle ? Colors.green : Colors.red; // 토글 ON 시 초록색, OFF 시 빨간색
    paint.style = PaintingStyle.stroke;
    paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 5); // 번짐 효과 추가

    final double sweepAngle = 2 * pi * animationValue;
    final double strokeWidth = 5.0; // 테두리의 두께
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
