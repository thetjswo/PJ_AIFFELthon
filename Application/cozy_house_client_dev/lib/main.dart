import 'package:cozy_house_client_dev/page/login_page.dart';
import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:http/http.dart' as http;

import 'firebase_options.dart';


late bool IS_MEMBER;
String SERVER_URL = dotenv.get('SERVER_URL');


void main() async {
  // .env 환경 변수 관리 파일 load
  await dotenv.load(fileName: '.env');

  // firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    account_inspection().then((_) {
      // 데이터 로드 완료 후 Splash 화면이 3초 간 표시된 후 화면 이동
      Future.delayed(Duration(seconds: 3), () {
        // 서버가 계정 정보를 가지고 있다면
        if(IS_MEMBER == true) {
          // splash 종료 후,
          FlutterNativeSplash.remove();
          Navigator.push(
            context,
            // 메인 화면으로 이동
            MaterialPageRoute(builder: (context) => const MainApp()),
          );
        }
        // 서버가 계정 정보를 가지고 있지 않다면
        else {
          // splash 종료 후,
          FlutterNativeSplash.remove();
          Navigator.push(
            context,
            // 로그인 화면으로 이동
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      });
    });
  }

  Future<void> account_inspection() async {
    final fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BECQwp1iAkXVexnSKuFEI4z0f6fgTh-_-F32ejG1bzCE1kA5-P6VF4ViYbCdPMZ8U1BgseLuR_FPaojH5Cz4uys");
    print('FCM TOKEN: $fcmToken');
    // TODO: 서버와 통신하여 계정 존재 여부를 확인하는 코드
    // var url = Uri.parse(SERVER_URL + "/get_account_info");
    // var response = await http.post(url, body: {'title': 'account inspection', 'body': 'bar'});
    // print(response.statusCode);
    // print(response);
    // if (response.statusCode == 201) {
    //   print('POST 요청 결과: ${response.body}');
    // } else {
    //   print('POST 요청 실패: ${response.statusCode}');
    // }
    // FIXME: 계정 생성 전, UI 테스트를 진행할 경우, IS_MEMBER 값을 true로 변경하면 바로 앱 메인 화면으로 이동
    IS_MEMBER = false;
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