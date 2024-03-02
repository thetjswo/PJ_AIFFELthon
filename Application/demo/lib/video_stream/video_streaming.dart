/// monitor page 디자인에 video stream 기능 테스트

import 'dart:convert';
import 'dart:typed_data';

import 'package:demo/constants/constants.dart';
import 'package:demo/video_stream/styles.dart';
import 'package:demo/video_stream/websocket.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoStream extends StatefulWidget {
  const VideoStream({super.key});

  @override
  State<VideoStream> createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  final WebSocket _socket = WebSocket(Constants.videoWebsocketURL);
  bool _isConnected = false;
  void connect(BuildContext context) async {
    _socket.connect();
    setState(() {
      _isConnected = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Container(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      height: 40,
                      // width: 350,
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      color: const Color(0xFFD0A9F5),
                      child: const Text(
                        'Camera01',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => connect(context),
                      style: Styles.buttonStyle,
                      child: const Text("Connect"),
                    ),
                    ElevatedButton(
                      onPressed: disconnect,
                      style: Styles.buttonStyle,
                      child: const Text("Disconnect"),
                    ),
                  ],
                ),
                // Container(
                //   height: 197,
                //   width: 350,
                //   color: Colors.grey,
                // ),
                _isConnected
                    ? StreamBuilder(
                        stream: _socket.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const Center(
                              child: Text("Connection Closed !"),
                            );
                          }
                          // Working for single frames
                          return Image.memory(
                            Uint8List.fromList(
                              base64Decode(
                                (snapshot.data.toString()),
                              ),
                            ),
                            gaplessPlayback: true,
                            excludeFromSemantics: true,
                          );
                        },
                      )
                    : const Text("Initiate Connection"),
                Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //TODO: 'n분 전' 동적으로 가져오는 기능 구현
                      Text('2분 전 카메라 화면'),
                      Text(
                        '움직임 감지',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                _launchSMS();
                              },
                              icon: const Icon(
                                Icons.emergency_outlined,
                                color: Colors.red,
                              ),
                              iconSize: 60,
                            ),
                            const Text('신고하기')
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.green,
                              ),
                              iconSize: 60,
                            ),
                            const Text('경보해제')
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share_outlined,
                                color: Colors.yellow,
                              ),
                              iconSize: 60,
                            ),
                            const Text('공유하기')
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

//TODO: common 항목으로 이동시킨 후, import하여 사용
void _launchSMS() async {
  const String phone = '112';
  const String message = '우리집에 나쁜 놈이 들어오려고 해요! 빨리 좀 와주세요!!';

  final Uri url = Uri.parse('sms:$phone?body=$message');

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
