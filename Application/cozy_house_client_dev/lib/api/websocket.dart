import 'dart:async'; // 비동기 프로그래밍을 위한 라이브러리
import 'package:web_socket_channel/status.dart'
    as status; // 웹소켓 연결 상태를 위한 라이브러리
import 'package:web_socket_channel/web_socket_channel.dart'; // 웹소켓 채널을 위한 라이브러리

class WebSocket {
  // ------------------------- 변수 선언 ------------------------- //
  late String url;

  WebSocketChannel? _channel;

  // ---------------------- Getter Setters --------------------- //
  // URL 반환하는 getter 함수
  String get getUrl {
    return url;
  }

  // URL 설정하는 setter 함수
  set setUrl(String url) {
    this.url = url;
  }

  // 웹소켓 stream을 반환하는 getter 함수
  Stream<dynamic> get stream {
    // 채널이 null이 아니면 채널의 stream 반환
    if (_channel != null) {
      return _channel!.stream;
    } else {
      // 채널이 null 이면 연결이 설정되지 않았다는 예외 발생
      throw WebSocketChannelException("The connection was not established !");
    }
  }

  // --------------------- Constructor ---------------------- //
  WebSocket(this.url);

  // ---------------------- Functions ----------------------- //

  // 웹소켓에 현재 애플리케이션을 연결하는 함수
  void connect(url) async {
    _channel = WebSocketChannel.connect(Uri.parse(url));
  }

  //웹소켓에서 현재 애플리케이션을 연결 해제하는 함수
  void disconnect() {
    // 채널이 null이 아니면
    if (_channel != null) {
      _channel!.sink.close(status.goingAway); // 채널을 닫음
    }
  }
}
