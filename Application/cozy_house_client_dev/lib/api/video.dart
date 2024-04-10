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

class LoadVideo {
  var formatter = JsonFormatter();

  Future<Map<String, dynamic>?> getSavedVideo(video_id) async {
    String server_url = '${SERVER_URL}/action/saved_video';
    final Uri url = Uri.parse(server_url);
    final jsonData = {};


    jsonData['video_id'] = video_id;

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

        return decoded_body;
      } else {
        print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('서버 요청 중 오류 발생: $error');
    }
  }
}