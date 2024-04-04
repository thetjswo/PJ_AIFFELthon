import 'dart:convert';
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
import 'package:url_launcher/url_launcher.dart';

import '../common/launch_sms.dart';

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  static String wsUrlCctv = dotenv.get('WS_URL_CCTV');

  ScreenshotController screenshotController = ScreenshotController();
  late Uint8List _image;

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
                Screenshot(
                  controller: screenshotController,
                  child: _isConnectd
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
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //TODO: 카메라 연결상태 아닐때 문구 변경?
                      Text('실시간 카메라 화면'),
                      //TODO: 기능 체크
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
                                // 사용자 정보를 받아오기 위한 객체 생성
                                LaunchSMS launchSMS = LaunchSMS(context);
                                // 신고 폼을 가지고 sms 앱 호출
                                launchSMS.launchSmsWithForm();
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
                              onPressed: () {
                                ModalPopUp.showCheckVideoDialog(context);
                              },
                              icon: Icon(
                                Icons.check_circle_outline_outlined,
                                color: Colors.green,
                              ),
                              iconSize: 60,
                            ),
                            Text('경보해제')
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
      ),
    );
  }
}
