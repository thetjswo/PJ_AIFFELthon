import 'package:cozy_house_client_dev/page/login_page.dart';
import 'package:cozy_house_client_dev/page/main_page.dart';
import 'package:cozy_house_client_dev/utils/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'common/fcm_setting.dart';
import 'firebase_options.dart';

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

  fcmSetting();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SharedPreferencesProvider()),
  ], child: Application()));
}

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'announcement') {
      print('Received an announcement message');
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
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
        // splash 종료 후,
        FlutterNativeSplash.remove();
        Navigator.pushReplacement(
          context,
          // 로그인 화면으로 이동
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    });
  }

  Future<void> account_inspection() async {
    // TODO: server health check
    // TODO: JWT 인증 토큰 검증 필요
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) =>
            SharedPreferencesProvider(), // SharedPreferencesProvider를 제공
        child: Scaffold(
          body: Center(
            child: Text('스플래시 화면'),
          ),
        ));
  }
}
