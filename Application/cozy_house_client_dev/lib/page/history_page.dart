import 'dart:convert';

import 'package:cozy_house_client_dev/page/action_page.dart';
import 'package:cozy_house_client_dev/utils/generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api/history.dart';
import '../utils/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  late String uid;
  DateTime _selectedDate = DateTime.now(); // 선택된 날짜를 저장할 변수

  List<Record> _records = []; // 임의로 적은 가상의 기록 데이터

  @override
  void initState() {
    super.initState();

    String? userInfoString =
        Provider.of<SharedPreferencesProvider>(context, listen: false)
            .getData('user_info');

    var generator = GeneratorModule();

    // 가져온 데이터 사용하기
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = json.decode(userInfoString);
      uid = userInfo['uid'] ?? '';
    } else {
      // 데이터가 존재하지 않을 경우 처리
      print('저장된 데이터가 없습니다.');
    }

    getCurrentHistory(generator);
  }

  getCurrentHistory(generator) async {
    final responseVideoList = DetectionHistory()
        .requestVideoList(uid, generator.generateCurrentTime());
    final eventInfo = await responseVideoList;

    if (eventInfo != null && eventInfo.isNotEmpty) {
      setState(() {
        eventInfo.forEach((cameraName, logs) {
          for (var log in logs) {
            var record = Record(log['message'],
                DateTime.parse(log['created_at']), cameraName, log['type']);
            _records.add(record);
          }
        });
      });
    } else {
      // 오늘 날짜에 데이터가 없는 경우
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('해당 날짜에 저장된 영상이 없습니다.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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
                          MaterialPageRoute(
                              builder: (context) =>
                                  ActionPage(context: context)),
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

  // _selectDate : 사용자가 날짜를 선택하도록 하는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      final responseVideoList =
          DetectionHistory().requestVideoList(uid, picked);
      final eventInfo = await responseVideoList;

      // 선택한 날짜에 데이터가 있는 경우
      if (eventInfo != null && eventInfo.isNotEmpty) {
        // 리스트 초기화
        _records = [];

        setState(() {
          _selectedDate = picked;

          eventInfo.forEach((cameraName, logs) {
            for (var log in logs) {
              var record = Record(log['message'],
                  DateTime.parse(log['created_at']), cameraName, log['type']);
              _records.add(record);
            }
          });
        });
      } else {
        // 선택한 날짜에 데이터가 없는 경우
        setState(() {
          _selectedDate = picked;
          _records = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('선택한 날짜에 저장된 영상이 없습니다.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

// TODO : 임의로 썸네일 이미지를 넣어둔 상태기 때문에 후에 수정 필요
Widget _buildRecordItem(Record record) {
  return ListTile(
    title: Text(record.event), // 이벤트 정보 표시
    subtitle: Text(
        "감지된 시간: ${record.time}, 장치 이름: ${record.camera}"), // 시간과 카메라 정보 표시
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
              color: getIconColor(record.type), // 적절한 색상으로 변경 가능
              size: 16, // 적절한 크기로 변경 가능
            ),
          ),
        ],
      ),
    ),
  );
}

// 경보 등급에 따라 아이콘 색상 지정
Color getIconColor(String type) {
  switch (type) {
    case 'Dangerous':
      return Colors.red;
    case 'Caution':
      return Colors.yellow;
    case 'Normal':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

class Record {
  final String event;
  final DateTime time;
  final String camera;
  final String type;

  Record(this.event, this.time, this.camera, this.type);
}
