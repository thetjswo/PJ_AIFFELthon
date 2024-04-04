// 리스트 선택하고 난 후에 따라오는 Action Page
import 'dart:convert';
import 'dart:typed_data';

import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:cozy_house_client_dev/common/launch_sms.dart';
import 'package:cozy_house_client_dev/common/styles.dart';

import 'package:flutter/material.dart';        // flutter 패키지 임포트: Flutter UI 프레임워크
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:share_plus/share_plus.dart';     // share_plus : 파일 공유 기능을 제공하는 패키지 임포트
import 'package:path_provider/path_provider.dart';   // path_provider : 폴더 경로 가져오는 패키지 임포트

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
  //TODO: DB에 저장된 영상으로 변경
  static String wsUrlSavedVideo = dotenv.get('WS_URL_SAVED_VIDEO');

  // Initialize WebSocket instance
  final WebSocket _socket = WebSocket(wsUrlSavedVideo);
  bool _isConnectd = false;

  @override
  void initState() {
    super.initState();
    _socket.connect(wsUrlSavedVideo);
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

  void _showAlert() { // 경보해제 버튼 클릭 시 팝업
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

  // 공유하기 버튼 클릭 시 썸네일과 도움 요청 텍스트를 전송하는 함수
  void _shareFiles() {
    final List<XFile> files = [XFile('../../../Server/cozy_house_backend_dev_server/resources/invasion_sample.jpeg')];  // TODO: 이미지 경로 실제 영상 썸네일로 변경 필요
    Share.shareXFiles(files, text: "도와주세요! 위험 상황이 발생했습니다.");
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
                          // TODO: 저장된 영상 재생 +  일시정지, 재생, 다시재생 버튼 추가
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
                              // TODO: 공유하기 페이지 양희 함수 추가
                              onPressed: _shareFiles,
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
