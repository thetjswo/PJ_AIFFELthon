import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:cozy_house_client_dev/common/modal_popup.dart';
import 'package:cozy_house_client_dev/common/styles.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

import '../common/launch_sms.dart';


String WS_URL = dotenv.get('WS_URL');

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  // static String wsUrlCctv = dotenv.get('WS_URL');
  // static String server_url = '${WS_URL}/monitor/realtime_stream';
  static String server_url = '${WS_URL}/monitor/realtime_stream';

  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _image;

  // Initialize WebSocket instance
  final WebSocket _socket = WebSocket(server_url);
  bool _isConnectd = false;

  @override
  void initState() {
    super.initState();

    _socket.connect(server_url);
    setState(() {
      _isConnectd = true;
    });
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnectd = false;
    });
  }

  // 공유하기 ui 실행 위젯
  void captureAndShare() async {
    await screenshotController.capture().then((img) async {
      _image = img!; // image is of type of Uint8List
      final directory = (await getApplicationDocumentsDirectory()).path;
      final imagePath = await File('$directory/screenshot.png').create();
      await imagePath.writeAsBytes(_image);

      // 핸드폰 ui로 공유하기
      await Share.shareXFiles(
        [XFile(imagePath.path)],
        text: '<포근한집>에서 실시간 화면을 공유합니다.',
      );

      // 공유한 후에 캡처한 스크린샷 삭제
      await imagePath.delete();
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  width: MediaQuery.of(context).size.width, // screen 너비에 맞춤
                  padding: EdgeInsets.only(left: 10, top: 5),
                  color: Color(0xFFD0A9F5),
                  child: Text(
                    'Camera01',
                    style: Styles.textStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                // real-time CCTV video streeaming
                Screenshot(
                  controller: screenshotController,
                  child: _isConnectd
                      ? StreamBuilder(
                          stream: _socket.stream,
                          builder: (context, snapshot) {
                            print(snapshot);
                            if (!snapshot.hasData) {
                              return Padding(
                                padding: const EdgeInsets.all(100.0),
                                child: const CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return Container(
                                alignment: Alignment.center,
                                height: 197,
                                width: MediaQuery.of(context).size.width,
                                color: Colors.grey,
                                child: Text(
                                  '카메라와의 연결이 끊어졌습니다',
                                  style: Styles.textStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                          alignment: Alignment.center,
                          height: 197,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.grey,
                          child: Text(
                            '카메라가 꺼져있습니다',
                            style: Styles.textStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //TODO: 카메라 연결상태 아닐때 문구 변경?
                      Text(
                        '실시간 카메라 화면',
                        style: Styles.textStyle(fontSize: 15),
                      ),
                      //TODO: 기능 체크 - 실시간? 움직임이 감지되면 빨간색으로 변경?
                      Text(
                        '움직임 감지',
                        style: Styles.textStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
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
                                // 사용자 정보를 받아오기 위한 객체 생성
                                LaunchSMS launchSMS = LaunchSMS(context);
                                // 신고 폼을 가지고 sms 앱 호출
                                launchSMS.launchSmsWithForm();
                              },
                              icon: Icon(
                                Icons.emergency_outlined,
                                color: Colors.red,
                              ),
                              iconSize: 70,
                            ),
                            Text(
                              '신고하기',
                              style: Styles.textStyle(
                                fontSize: 20,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: captureAndShare, // 버튼 누르면 캡처하기 함수 실행
                              icon: Icon(
                                Icons.share_outlined,
                                color: Colors.amber,
                              ),
                              iconSize: 70,
                            ),
                            Text(
                              '공유하기',
                              style: Styles.textStyle(
                                fontSize: 20,
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
          )
        ],
      ),
    );
  }
}
