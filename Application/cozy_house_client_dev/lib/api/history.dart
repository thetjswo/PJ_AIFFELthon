// 이 파일을 실행하면 선택한 날짜를 기반으로 서버에 비디오 목록을 요청

import 'dart:convert';

import 'package:provider/provider.dart';

import '../main.dart';
import 'package:http/http.dart' as http;

import '../utils/formatter.dart';
import '../utils/provider.dart';

class DetectionHistory {
  var formatter = JsonFormatter();

  Future<Map<String, dynamic>?> requestVideoList(
      String uid, DateTime selectedDate) async {
    // 해당 IP의 URL로 서버에 요청을 보냄.
    String serverUrl = '$SERVER_URL/history/selected_date';
    String date = selectedDate.toString();
    // uid, date를 json형식으로 담아서 서버로 전송
    // json 데이터 생성
    Map<String, dynamic> jsonVideoInfo = {
      'uid': uid,
      'date': date,
    };

    // json 데이터를 문자열로 인코딩 : Map을 json String으로 바꾸기
    String requestBody = formatter.request_formatter(jsonVideoInfo);

    // HTTP POST 요청 보내기
    var response = await http.post(
      // http패키지의 post함수를 사용하여 POST요청을 보냄
      // http.post는 비동기 함수이므로 await 사용
      // 요청에 대한 응답은 response 변수에 저장됨
      Uri.parse(serverUrl), // serverUrl 변수에 저장된 문자열을 URI로 파싱 = 서버의 URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // HTTP요청의 헤더를 설정 : Content-Type 헤더를 설정하여 요청의 본문이 JSON 형식임을 서버에 알려줌
      },
      body: requestBody, // 요청의 본문
    );

    // 응답 확인
    if (response.statusCode == 200) {
      var decodedJson = formatter.response_formatter(response.bodyBytes);

      Map<String, dynamic> camWithEvent = decodedJson['response_data'];

      print('서버로 데이터 전송 성공: $camWithEvent');

      return camWithEvent;
    } else {
      // 해당 날짜에 데이터가 없는 경우
      if (response.statusCode == 404) {
        return null;
      } else {
        // 모든 경우가 아닌 경우 해당 에러메세지 출력 & return null
        String errorMessage =
            'Failed to load data. Status code: ${response.statusCode}, Body: ${response.body}';
        print(errorMessage);
        return null;
        // throw Exception('Failed to load data');
      }
    }
  }
}
