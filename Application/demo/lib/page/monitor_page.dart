import 'package:flutter/material.dart';

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {

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
                              onPressed: () {},
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
                              onPressed: () {},
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