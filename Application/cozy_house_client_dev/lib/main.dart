import 'package:cozy_house_client_dev/page/login_page.dart';
import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

late bool is_member;

void main() async {
  // .env 환경 변수 관리 파일 load
  await dotenv.load(fileName: '.env');
  // splash 화면이 노출되는 동안 계정, 네트워크 유효성 검증 등의 백그라운드 처리를 위한 작업
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BeforeAppStart(),
    );
  }
}

class BeforeAppStart extends StatefulWidget {
  const BeforeAppStart({super.key});

  @override
  _BeforeAppStartState createState() => _BeforeAppStartState();
}

class _BeforeAppStartState extends State<BeforeAppStart> {
  @override
  void initState() {
    super.initState();

    // initState 메서드에서 비동기 작업 수행
    loadData().then((_) {
      // 데이터 로드 완료 후 Splash 화면이 3초 간 표시된 후 화면 이동
      Future.delayed(Duration(seconds: 3), () {
        // 서버가 계정 정보를 가지고 있다면
        if(is_member == true) {
          // splash 종료 후,
          FlutterNativeSplash.remove();
          Navigator.pushReplacement(
            context,
            // 메인 화면으로 이동
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
        // 서버가 계정 정보를 가지고 있지 않다면
        else {
          // splash 종료 후,
          FlutterNativeSplash.remove();
          Navigator.pushReplacement(
            context,
            // 로그인 화면으로 이동
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      });
    });
  }

  Future<void> loadData() async {
    is_member = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('스플래시 화면'),
      ),
    );
  }
}