// 리스트 선택하고 난 후에 따라오는 Action Page
import 'dart:convert';
import 'dart:typed_data';

import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:cozy_house_client_dev/common/launch_sms.dart';
import 'package:cozy_house_client_dev/common/styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

class ActionPage extends StatefulWidget {
  final BuildContext context;

  const ActionPage({
    super.key,
    required this.context,
  });

  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  static String wsUrlCctv = dotenv.get('WS_URL_CCTV');

  // Initialize WebSocket instance
  final WebSocket _socket = WebSocket(wsUrlCctv);
  bool _isConnectd = false;

  @override
  void initState() {
    super.initState();
    _socket.connect(wsUrlCctv);
    setState(() {
      _isConnectd = true;
    });
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnectd = false;
    });
  }

  void _showAlert() {
    showDialog(
      context: widget.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("경보를 해제합니다."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Icon(
                Icons.check_circle_outline_outlined,
                color: Colors.green,
                size: 80,
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.lightGreen),
                ),
                // TODO : 경보 해제시 알림 꺼지는 기능 구현 필요
                child: Text("확인"),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          "Action Page",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFD0A9F5),
            height: 1.0,
          ),
        ),
      ),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 100,
          ),
          Container(
            child: Column(
              children: [
                Container(
                  height: 40,
                  width: 350,
                  padding: EdgeInsets.only(left: 10, top: 5),
                  color: Color(0xFFD0A9F5),
                  child: Text(
                    'Camera01',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                // real-time CCTV video streeaming
                _isConnectd
                    ? StreamBuilder(
                        stream: _socket.stream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return const Center(
                              child: Text("connection Closed!"),
                            );
                          }
                          return Image.memory(
                            Uint8List.fromList(
                              base64Decode(
                                (snapshot.data),
                              ),
                            ),
                            gaplessPlayback: true,
                            excludeFromSemantics: true,
                          );
                        },
                      )
                    // TODO: 카메라 연결이 끊어졌을때 회색박스에 안내문구 출력
                    : Container(
                        height: 197,
                        width: 350,
                        color: Colors.grey,
                        child: Text(
                          '카메라가 꺼져있습니다',
                          style: Styles.textStyle,
                        ),
                      ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('2분 전 카메라 화면'),
                      Text(
                        '움직임 감지',
                        style: TextStyle(color: Colors.blue),
                      )
                    ],
                  ),
                ),
                SizedBox(
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
                                // const LaunchSMS(
                                //   phoneNumber: '112',
                                //   message: '우리집에 나쁜 놈이 들어오려고 해요! 빨리 좀 와주세요!!',
                                // );
                                _launchSMS();
                              },
                              icon: Icon(
                                Icons.emergency_outlined,
                                color: Colors.red,
                              ),
                              iconSize: 60,
                            ),
                            Text('신고하기')
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: _showAlert,
                              icon: Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.green,
                              ),
                              iconSize: 60,
                            ),
                            Text('경보 해제')
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              // TODO: 공유하기 페이지 작업
                              onPressed: () {},
                              icon: Icon(
                                Icons.share_outlined,
                                color: Colors.yellow,
                              ),
                              iconSize: 60,
                            ),
                            Text('공유하기')
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
      )),
    );
  }
}

//TODO: common 항목으로 이동시킨 후, import하여 사용
void _launchSMS() async {
  final String phone = '112';
  final String message = '우리집에 나쁜 놈이 들어오려고 해요! 빨리 좀 와주세요!!';

  final Uri url = Uri.parse('sms:$phone?body=$message');

  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
