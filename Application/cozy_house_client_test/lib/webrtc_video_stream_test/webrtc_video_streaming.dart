import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoStreamPage extends StatefulWidget {
  const VideoStreamPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  // Create an instance of RTCVideoRenderer for local video rendering
  final _localRenderer = RTCVideoRenderer();
  // Declare a variable to hold the local media stream
  late MediaStream _localStream;

  @override
  dispose() {
    // Dispose of the local media stream when the widget is disposed
    _localStream.dispose();
    _localRenderer.dispose(); // Dispose of the local video renderer
    super.dispose();
  }

  @override
  void initState() {
    initRenderers(); // Initialize video renderers when the widget is initializeds
    _getUserMedia(); // Request access to user media (camera and microphone)
    super.initState();
  }

  initRenderers() async {
    await _localRenderer.initialize(); // Initialize the local video renderer
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': false, // Disable audio for the media stream
      'video': {
        'mandatory': {
          'minWidth': '1280', // Minimum video width required
          'minHeight': '720', // Minimum video height required
          'minFrameRate': '30', // Minimum frame rate required
        },
        'facingMode': 'user', // front camera, 'environment': back camera
        'optional': [],
      },
    };

    // Get the user media stream based on the constraints
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    // Set the source object of the local video renderer to the local media stream
    _localRenderer.srcObject = _localStream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Set the app bar title based on the widget's title property
        title: Text(widget.title),
      ),
      // body: OrientationBuilder(
      //   builder: (context, orientation) {
      //     return Center(
      //       child: Container(
      //         margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      //         width: MediaQuery.of(context).size.width,
      //         height: MediaQuery.of(context).size.height,
      //         // Set the container's background color to black
      //         decoration: const BoxDecoration(color: Colors.black),
      //         // Display the local video stream using RTCVideoView
      //         child: RTCVideoView(_localRenderer, mirror: true),
      //       ),
      //     );
      //   },
      // ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: Container(child: RTCVideoView(_localRenderer)),
            ),
          ],
        ),
      ),
    );
  }
}
