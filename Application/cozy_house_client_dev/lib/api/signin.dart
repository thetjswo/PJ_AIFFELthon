import 'dart:convert';
import 'dart:io';
import 'package:cozy_house_client_dev/utils/formatter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info/package_info.dart';

import '../common/firebase_authentication.dart';
import 'package:http/http.dart' as http;

import '../utils/generator.dart';


String SERVER_URL = dotenv.get('SERVER_URL');

class SignIn {
  var formatter = JsonFormatter();

  Future<void> sendDeviceInfoToServer(UserCredential credential) async {
    String server_url = '${SERVER_URL}/auth/deviceinfo';
    final Uri url = Uri.parse(server_url);
    final jsonData = {};

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo;
    IosDeviceInfo iosInfo;

    final uid = credential.user?.uid ?? "";
    final PackageInfo info = await PackageInfo.fromPlatform();
    final fcm_token = await FirebaseAuthentication.get_push_token(dotenv.get('FIREBASE_API_KEY'));
    final uuid = GeneratorModule().generateUuid();

    jsonData['user_uid'] = uid;
    jsonData['push_id'] = fcm_token;
    jsonData['app_version'] = info.version;

    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;

      jsonData['manufacturer'] = androidInfo.board;
      jsonData['device_name'] = androidInfo.device;
      jsonData['device_model'] = androidInfo.model;
      jsonData['os_version'] = androidInfo.version.release;
      jsonData['uuid'] = uuid;
    } else if (Platform.isIOS) {
      iosInfo = await deviceInfo.iosInfo;

      jsonData['manufacturer'] = iosInfo.systemName;
      jsonData['device_name'] = iosInfo.localizedModel;
      jsonData['device_model'] = iosInfo.model;
      jsonData['os_version'] = iosInfo.systemVersion;
      jsonData['uuid'] = iosInfo.identifierForVendor;
    }

    try {
      // HTTP POST 요청
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      // 응답을 확인합니다.
      if (response.statusCode == 200) {
        var decoded_body = formatter.response_formatter(response.bodyBytes);
        print('서버로 데이터 전송 성공: ${decoded_body}');
      } else {
        print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('서버 요청 중 오류 발생: $error');
    }
  }

  Future<Map<String, dynamic>> sendSignInDataToServer(UserCredential credential) async {
    String server_url = '${SERVER_URL}/auth/signin';
    final Uri url = Uri.parse(server_url);

    final uid = credential.user?.uid ?? "";
    final jsonData = {
      'uid': uid
    };

    Map<String, dynamic> user_info = {};

    try {
      // HTTP POST 요청
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(jsonData),
      );

      // 응답을 확인합니다.
      if (response.statusCode == 200) {
        var decoded_json = formatter.response_formatter(response.bodyBytes);
        user_info['uid'] = uid;
        user_info['user_name'] = decoded_json["user_name"];
        user_info['user_id'] = decoded_json["user_id"];
        user_info['user_pw'] = decoded_json["user_pw"];
        user_info['phone_num'] = decoded_json["phone_num"];
        user_info['address'] = decoded_json["address"];
        user_info['device_uuid'] = decoded_json["device_uuid"];

        print('서버로 데이터 전송 성공: ${user_info}');
      } else {
        print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('서버 요청 중 오류 발생: $error');
    }

    return user_info;
  }
}