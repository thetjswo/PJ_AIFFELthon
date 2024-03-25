import 'package:cozy_house_client_test/video_stream_test/video_streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'config.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter cozy_house_client_test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const VideoStream(),
    );
  }
}
