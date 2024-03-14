import 'dart:async';

import 'package:cozy_house_client_test/model/websocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'config.env');
  runApp(const Model());
}

class Model extends StatelessWidget {
  const Model({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'WebSocket Model cozy_house_client_test',
      home: RealtimeDataScreen(),
    );
  }
}

class RealtimeDataScreen extends StatefulWidget {
  const RealtimeDataScreen({super.key});

  @override
  _RealtimeDataScreenState createState() => _RealtimeDataScreenState();
}

class _RealtimeDataScreenState extends State<RealtimeDataScreen> {
  final StreamController<Map> _controller = StreamController<Map>();

  @override
  void initState() {
    super.initState();
    RealtimeDataService().start(_controller);
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Model cozy_house_client_test'),
      ),
      body: StreamBuilder<Map>(
        stream: _controller.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 여기서 수신된 데이터를 사용하여 UI를 업데이트
            return Center(
              child: Text('Received data: ${snapshot.data}'),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
