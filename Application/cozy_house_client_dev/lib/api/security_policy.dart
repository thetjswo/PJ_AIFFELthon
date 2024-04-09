import 'dart:convert';
import 'package:cozy_house_client_dev/utils/formatter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

String SERVER_URL = dotenv.get('SERVER_URL');
class SecurityPolicy {
  var formatter = JsonFormatter();

  Future<bool> changeSecurityPolicyFlag(user_uid) async {
    String server_url = '${SERVER_URL}/policy/change_flag';
    final Uri url = Uri.parse(server_url);

    final jsonData = {
      'uid': user_uid
    };
    bool result = false;

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

        result = decoded_json['detection_yn'];
        print('서버로 데이터 요청/응답 성공: ${decoded_json['detection_yn']}');
      } else {
        print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('서버 요청 중 오류 발생: $error');
    }

    return result;
  }


  // Future<bool> getSecurityPolicyFlag(user_uid) async {
  //   String server_url = '${SERVER_URL}/policy/get_flag';
  //   final Uri url = Uri.parse(server_url);
  //
  //   final jsonData = {
  //     'uid': user_uid
  //   };
  //   bool result = false;
  //
  //   try {
  //     // HTTP POST 요청
  //     final response = await http.post(
  //       url,
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(jsonData),
  //     );
  //
  //     // 응답을 확인합니다.
  //     if (response.statusCode == 200) {
  //       var decoded_json = formatter.response_formatter(response.bodyBytes);
  //
  //       result = decoded_json['detection_yn'];
  //       print('서버로 데이터 요청/응답 성공: ${decoded_json['detection_yn']}');
  //     } else {
  //       print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('서버 요청 중 오류 발생: $error');
  //   }
  //
  //   return result;
  // }
}