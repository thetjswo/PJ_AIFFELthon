import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseAuthentication {
  static create_account(email, pw) {
    // var acs = ActionCodeSettings(
    //   //FIXME: 아마 url이 문제일 듯 싶음
    //     url: dotenv.get('FIREBASE_REDIRECT_URL'),
    //     // This must be true
    //     handleCodeInApp: true,
    //     iOSBundleId: dotenv.get('IOS_BUNDLE_ID'),
    //     androidPackageName: dotenv.get('AOS_PACKAGE_NAME'),
    //     // installIfNotAvailable
    //     androidInstallApp: true,
    //     // minimumVersion
    //     androidMinimumVersion: '12');

    // 계정 생성
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: pw,
    );

    // 인증 메일 발송
    // FirebaseAuth.instance.sendSignInLinkToEmail(
    //     email: email, actionCodeSettings: acs)
    //     .catchError((onError) => print('Error sending email verification $onError'))
    //     .then((value) => print('Successfully sent email verification'));
  }

  static get_push_token(key) {
    final fcmToken = FirebaseMessaging.instance.getToken(vapidKey: key);

    return fcmToken;
  }
}