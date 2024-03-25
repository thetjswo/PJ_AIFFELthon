import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignIn {
  Future<void> inspect_device_info(UserCredential credential) async {
    String server_url = '${dotenv.get('SERVER_URL')}/auth/deviceinfo';
    final Uri url = Uri.parse(server_url);

    // try {
    //   // JSON 데이터로 변환
    //   final jsonData = jsonEncode(data.toJson());
    //
    //   // HTTP POST 요청
    //   final response = await http.post(
    //     url,
    //     headers: <String, String>{
    //       'Content-Type': 'application/json; charset=UTF-8',
    //     },
    //     body: jsonData,
    //   );
    //
    //   // 응답을 확인합니다.
    //   if (response.statusCode == 200) {
    //     print('서버로 데이터 전송 성공: ${response.body}');
    //   } else {
    //     print('서버로 데이터 전송 실패: ${response.reasonPhrase}');
    //   }
    // } catch (error) {
    //   print('서버 요청 중 오류 발생: $error');
    // }
  }
}