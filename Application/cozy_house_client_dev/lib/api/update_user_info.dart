import 'dart:convert';
import 'package:cozy_house_client_dev/utils/formatter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../page/account_setting_page.dart';

class UpdateUserInfo {
  var formatter = JsonFormatter();

  Future<void> sendUpdateDataToServer(FormData data) async {
    String server_url = '${dotenv.get('SERVER_URL')}/auth/update/userinfo';
    final Uri url = Uri.parse(server_url);

    try {
      // JSON 데이터로 변환
      final jsonData = jsonEncode(data.toJson());

      // HTTP POST 요청
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonData,
      );

      // 응답을 확인합니다.
      if (response.statusCode == 200) {
        var decoded_json = formatter.response_formatter(response.bodyBytes);
        print('서버로 데이터 전송 성공: ${decoded_json}');
      } else {
        print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('서버 요청 중 오류 발생: $error');
    }
  }
}