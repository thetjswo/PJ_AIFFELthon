import 'package:cozy_house_client_test/webrtc_video_stream_test/webrtc_video_streaming.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: 'config.env');
  runApp(const VideoStream());
}

class VideoStream extends StatelessWidget {
  const VideoStream({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebRTC Video Stream Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const VideoStreamPage(title: 'WebRTC Video Stream'),
    );
  }
}

// class VideoCallApp extends StatelessWidget {
//   VideoCallApp({super.key});

//   // signalling server url
//   static String wsModelUrl = dotenv.get('WS_URL_CCTV');
//   // generate callerID of local user
//   final String selfCallerID =
//       Random().nextInt(999999).toString().padLeft(6, '0');

//   @override
//   Widget build(BuildContext context) {
//     // init signalling service
//     SignallingService.instance.init(
//       websocketUrl: wsModelUrl,
//       selfCallerID: selfCallerID,
//     );

//     // return material app
//     return MaterialApp(
//       darkTheme: ThemeData.dark().copyWith(
//         colorScheme: const ColorScheme.dark(),
//       ),
//       themeMode: ThemeMode.dark,
//       home: const VideoChatPage(),
//     );
//   }
// }
