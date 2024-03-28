import 'package:cozy_house_client_dev/page/action_page.dart';
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
                          MaterialPageRoute(builder: (context) => ActionPage(context: context)),
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
    subtitle: Text(
        "감지된 시간: ${record.time}, Camera: ${record.camera}"), // 시간과 카메라 정보 표시
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
