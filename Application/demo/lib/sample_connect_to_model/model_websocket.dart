import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  await dotenv.load(fileName: 'config.env');
  runApp(const Model());
}

class Model extends StatelessWidget {
  const Model({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Model Demo';
    return MaterialApp(
      title: title,
      home: ModelPage(
        title: title,
      ),
    );
  }
}

class ModelPage extends StatefulWidget {
  const ModelPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  late WebSocketChannel channel;
  String _message = '';

  @override
  void initState() {
    super.initState();
    String wsUrl = dotenv.get('WS_URL');
    channel = WebSocketChannel.connect(Uri.parse("$wsUrl/ws"));
    channel.stream.listen((message) {
      setState(() {
        _message = message;
      });
    });
  }

  @override
  void dispose() {
    channel.sink.close(); // 앱이 종료되면 웹소켓 연결 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Received Message: $_message'),
          ),
          StreamBuilder(
            stream: channel.stream,
            builder: (context, snapshot) {
              return Text(snapshot.hasData ? '${snapshot.data}' : '');
            },
          ),
        ],
      ),
    );
  }
}
