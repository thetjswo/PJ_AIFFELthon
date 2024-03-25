import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAuthentication {
  static create_account(email, pw) {
    // 계정 생성
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: pw,
    );
  }

  static get_push_token(key) {
    final fcmToken = FirebaseMessaging.instance.getToken(vapidKey: key);

    return fcmToken;
  }
}