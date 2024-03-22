import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜를 저장할 변수
  // TODO : 기록 데이터 import하기, 선택된 날짜의 기록 가져오기
  List<Record> _records = [
    Record("외부인 감지", DateTime(2023, 2, 29, 9, 30, 15), "카메라 1"),
  ]; // 임의로 적은 가상의 기록 데이터

  // List<Record> _filteredRecords = []; // 선택된 날짜에 해당하는 기록을 저장할 리스트

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${_selectedDate.year}.${_selectedDate.month}.${_selectedDate.day}",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: _records.map((record) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ActionPage()),
                        );
                      },
                      child: _buildRecordItem(record),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
// TODO : 임의로 썸네일 이미지를 넣어둔 상태기 때문에 후에 수정 필요
Widget _buildRecordItem(Record record) {
  return ListTile(
    title: Text(record.event), // 이벤트 정보 표시
    subtitle: Text("감지된 시간: ${record.time}, Camera: ${record.camera}"), // 시간과 카메라 정보 표시
    trailing: SizedBox(
      width: 80, // 이미지 너비
      height: 48, // 이미지 높이
      child: Stack(
        children: [
          // 썸네일 이미지
          Positioned(
            right: 0,
            top: 0,
            child: Image.asset(
              "assets/images/example_images/gray_box.png", // 썸네일 이미지 경로
              width: 80, // 적절한 크기로 변경 가능
              height: 48, // 적절한 크기로 변경 가능
              fit: BoxFit.cover,
            ),
          ),
          // 쉴드 로고
          Positioned(
            right: 2,
            top: 3,
            child: Icon(
              Icons.security,
              color: Colors.blue, // 적절한 색상으로 변경 가능
              size: 16, // 적절한 크기로 변경 가능
            ),
          ),
        ],
      ),
    ),
  );
}

class Record {
  final String event;
  final DateTime time;
  final String camera;

  Record(this.event, this.time, this.camera);
}


// 리스트 선택하고 난 후에 따라오는 Action Page
class ActionPage extends StatefulWidget {
  @override
  _ActionPageState createState() => _ActionPageState();
}

class _ActionPageState extends State<ActionPage> {
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
                                Text('경보 해제')
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
      ),
    );
  }


  // _launchSMS 함수도 함께 추가
  void _launchSMS() async {
    final String phone = '112';
    final String message = '우리집에 나쁜 놈이 들어오려고 해요! 빨리 좀 와주세요!!';

    final Uri uri = Uri.parse('sms:$phone?body=$message');

    if (await canLaunch(uri.toString())) { // url_launcher의 canLaunch 메소드 사용
      await launch(uri.toString()); // url_launcher의 launch 메소드 사용
    } else {
      throw 'Could not launch $uri';
    }
  }
}