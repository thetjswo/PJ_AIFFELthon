import 'dart:async';
import 'dart:convert'; // JSON 변환을 위한 라이브러리

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart'; // WebSocket 통신을 위한 라이브러리

class RealtimeDataService {
  void start(StreamController<Map> controller) {
    late WebSocketChannel channel;

    // WebSocket 연결을 설정하고 지정된 URL로 연결
    String wsUrl = dotenv.get('WS_URL_ALL');
    channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    channel.stream.listen(
      (event) {
        // 디버깅 - 연결되었음 출력
        print('WebSocket connected successfully');
        // JSON 문자열을 Map 형식으로 변환합니다.
        Map<String, dynamic> data = jsonDecode(event);
        // 변환된 데이터를 controller를 통해 외부로 전달
        controller.add(data);
      },
      onError: (error) {
        print('WebSocket connection error: $error');
      },
      onDone: () {
        print('WebSocket connection closed');
      },
    );
  }
}
