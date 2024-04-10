// 리스트 선택하고 난 후에 따라오는 Action Page
import 'dart:convert';
import 'dart:io';

import 'package:cozy_house_client_dev/api/websocket.dart';
import 'package:cozy_house_client_dev/common/launch_sms.dart';
import 'package:cozy_house_client_dev/common/styles.dart';

import 'package:flutter/material.dart'; // flutter 패키지 임포트: Flutter UI 프레임워크
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:share_plus/share_plus.dart'; // share_plus : 파일 공유 기능을 제공하는 패키지 임포트
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../api/video.dart';
import '../utils/formatter.dart'; // path_provider : 폴더 경로 가져오는 패키지 임포트

class ActionPage extends StatefulWidget {
  final BuildContext context;
  final int video_id;

  const ActionPage({
    super.key,
    required this.context,
    required this.video_id,
  });

  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
  var time_formatter = TimeFormatter();

  //TODO: DB에 저장된 영상으로 변경
  static String WS_URL = dotenv.get('WS_URL');
  static String wsUrlSavedVideo = '$WS_URL/action/saved_video';
  // late VideoPlayerController _controller;
  // late String _videoFilePath;

  int video_id = 0;

  // Initialize WebSocket instance
  final WebSocket _socket = WebSocket(wsUrlSavedVideo);
  bool _isConnectd = false;

  // TODO: DB 섬네일 url로 변경
  String imageUrl =
      'https://attach.choroc.com/web/goods/1/img1/016262_20230314115443.jpg';

  List<VideoInfo> _video_info = [];


  @override
  void initState() {
    super.initState();

    video_id = widget.video_id;
    getVideoInfo(video_id);

    _socket.connect(wsUrlSavedVideo);
    setState(() {
      _isConnectd = true;
    });
  }

  getVideoInfo(video_id) async {
    final response = LoadVideo().getSavedVideo(video_id);
    final response_data = await response;
    print(response_data);

    if (response_data != null && response_data.isNotEmpty) {
      setState(() {
        var time_ago = time_formatter.difference_formatter(DateTime.parse(response_data['created_at']));
        var video_info = VideoInfo(response_data['camera_name'],/*response_data['video'],*/ response_data['thumbnail'], time_ago);
        _video_info.add(video_info);
        // _initializeVideo();
      });
    }
  }

  // Future<void> _initializeVideo() async {
  //   // 비디오 데이터를 파일로 저장
  //   final file = File('${(await getTemporaryDirectory()).path}/video.mp4');
  //   await file.writeAsBytes(Uint8List.fromList(base64Decode(_video_info[0].video)));
  //
  //   // 비디오 파일 경로를 이용하여 VideoPlayerController 초기화
  //   _videoFilePath = file.path;
  //   _controller = VideoPlayerController.file(File(_videoFilePath));
  //   await _controller.initialize();
  //   setState(() {});
  // }

  void disconnect() {
    _socket.disconnect();
    setState(() {
      _isConnectd = false;
    });
  }

  // void _showAlert() {
  //   // 경보해제 버튼 클릭 시 팝업
  //   showDialog(
  //     context: widget.context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("경보를 해제합니다."),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             SizedBox(height: 20),
  //             Icon(
  //               Icons.check_circle_outline_outlined,
  //               color: Colors.green,
  //               size: 80,
  //             ),
  //             SizedBox(height: 20),
  //           ],
  //         ),
  //         actions: [
  //           Center(
  //             child: TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(); // 다이얼로그 닫기
  //               },
  //               style: ButtonStyle(
  //                 foregroundColor:
  //                     MaterialStateProperty.all<Color>(Colors.black),
  //                 backgroundColor:
  //                     MaterialStateProperty.all<Color>(Colors.lightGreen),
  //               ),
  //               // TODO : 경보 해제시 알림 꺼지는 기능 구현 필요
  //               child: Text("확인"),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }


  // 공유하기 버튼 클릭 시 썸네일과 도움 요청 텍스트를 전송하는 함수
  void _shareFiles() async {
    // // url 이미지 공유
    // final http.Response responseData = await http.get(Uri.parse(imageUrl));
    // var uint8list = responseData.bodyBytes;
    // var buffer = uint8list.buffer;
    // ByteData byteData = ByteData.view(buffer);
    // final directory = (await getApplicationDocumentsDirectory()).path;
    // File file = await File('$directory/thumbnail.jpg').writeAsBytes(
    //     buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    //
    // // 핸드폰 share ui로 공유하기
    // await Share.shareXFiles(
    //   [XFile(file.path)],
    //   text: "도와주세요! 위험 상황이 발생했습니다.",
    // );
    //
    // // 공유한 후에 캡처한 스크린샷 삭제
    // await file.delete();
    // 이미지를 저장할 디렉토리 경로 설정
    final directory = (await getApplicationDocumentsDirectory()).path;

// 이미지를 파일로 저장
    File file = await File('$directory/thumbnail.jpg').writeAsBytes(Uint8List.fromList(base64Decode(_video_info[0].thumbnail)));

// 핸드폰 share ui로 이미지 공유
    await Share.shareXFiles(
      [XFile(file.path)],
      text: "도와주세요! 위험 상황이 발생했습니다.",
    );

// 이미지 공유 후에 저장된 이미지 삭제
    await file.delete();
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
                      width: MediaQuery.of(context).size.width, // screen 너비에 맞춤
                      padding: EdgeInsets.only(left: 10, top: 5),
                      color: Color(0xFFD0A9F5),
                      child: Text(
                        _video_info.isNotEmpty ? _video_info[0].camera : 'Unspecified',
                        style: Styles.textStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    // Center(
                    //   child: _controller.value.isInitialized
                    //       ? AspectRatio(
                    //     aspectRatio: _controller.value.aspectRatio,
                    //     child: VideoPlayer(_controller),
                    //   )
                    //       : CircularProgressIndicator(),
                    // ),
                    _isConnectd
                        ? StreamBuilder(
                      stream: _socket.stream,
                      builder: (context, snapshot) {
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
                              style: Styles.textStyle(),
                            ),
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
                    // TODO: 로직체크 : 현재 - 저장된 영상을 불러오지 못할때 회색박스에 안내문구 출력
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
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //TODO: DB상의 시간 값 가져오기
                          Text(
                            _video_info.isNotEmpty ? _video_info[0].time_ago : '',
                            style: Styles.textStyle(fontSize: 15),
                          ),
                          Text(
                            '움직임 감지',
                            style: Styles.textStyle(
                              fontSize: 15,
                              color: Colors.red[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                                  onPressed: () async {
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
                                ),
                              ],
                            ),
                          ),
                          Container(
                            child: Column(
                              children: [
                                IconButton(
                                  onPressed: _shareFiles,
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
                                ),
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
          )
        ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     print('!!!!!!!!!!!!');
      //     setState(() {
      //       _controller.value.isPlaying
      //           ? _controller.pause()
      //           : _controller.play();
      //     });
      //   },
      //   child: Icon(
      //     _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
      //   ),
      // ),
    );
  }
}

class VideoInfo {
  final String camera;
  // final String video;
  final String thumbnail;
  final String time_ago;

  VideoInfo(this.camera/*, this.video*/, this.thumbnail, this.time_ago);
}
