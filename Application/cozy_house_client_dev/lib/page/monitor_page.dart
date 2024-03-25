// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// class MonitorPage extends StatefulWidget {
//   @override
//   _MonitorPageState createState() => _MonitorPageState();
// }
//
// class _MonitorPageState extends State<MonitorPage> {
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         children: [
//           SizedBox(height: 100,),
//           Container(
//             child: Column(
//               children: [
//                 Container(
//                   height: 40,
//                   width: 350,
//                   padding: EdgeInsets.only(left: 10, top: 5),
//                   color: Color(0xFFD0A9F5),
//                   child: Text(
//                     'Camera01',
//                     style: TextStyle(
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: 197,
//                   width: 350,
//                   color: Colors.grey,
//                 ),
//                 Container(
//                   margin: EdgeInsets.only(left: 10, right: 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       //TODO: 'n분 전' 동적으로 가져오는 기능 구현
//                       Text('2분 전 카메라 화면'),
//                       Text(
//                         '움직임 감지',
//                         style: TextStyle(
//                           color: Colors.blue
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 50,),
//                 Container(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Container(
//                         child: Column(
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 _launchSMS();
//                               },
//                               icon: Icon(Icons.emergency_outlined, color: Colors.red,),
//                               iconSize: 60,
//                             ),
//                             Text('신고하기')
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: Column(
//                           children: [
//                             IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.check_circle_outline_outlined, color: Colors.green,),
//                               iconSize: 60,
//                             ),
//                             Text('경보해제')
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: Column(
//                           children: [
//                             IconButton(
//                               onPressed: () {},
//                               icon: Icon(Icons.share_outlined, color: Colors.yellow,),
//                               iconSize: 60,
//                             ),
//                             Text('공유하기')
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       )
//     );
//   }
// }
//
// //TODO: common 항목으로 이동시킨 후, import하여 사용
// void _launchSMS() async {
//   final String phone = '112';
//   final String message = '우리집에 나쁜 놈이 들어오려고 해요! 빨리 좀 와주세요!!';
//
//   final Uri url = Uri.parse('sms:$phone?body=$message');
//
//   if (await canLaunchUrl(url)) {
//     await launchUrl(url);
//   }else {
//     throw 'Could not launch $url';
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  void _showAlert() {
    showDialog(
      context: context,
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
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.lightGreen),
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
    return Center(
        child: Column(
          children: [
            SizedBox(height: 100,),
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
                  Container(
                    height: 197,
                    width: 350,
                    color: Colors.grey,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //TODO: 'n분 전' 동적으로 가져오는 기능 구현
                        Text('2분 전 카메라 화면'),
                        Text(
                          '움직임 감지',
                          style: TextStyle(
                              color: Colors.blue
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 50,),
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
                                icon: Icon(Icons.emergency_outlined, color: Colors.red,),
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
                                icon: Icon(Icons.check_circle_outline_outlined, color: Colors.green,),
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
                                onPressed: () {},
                                icon: Icon(Icons.share_outlined, color: Colors.yellow,),
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
        )
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
  }else {
    throw 'Could not launch $url';
  }
}