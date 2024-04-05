import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const List<String> list = <String>['5초', '10초', '15초', '20초'];

class DetectTimes extends StatefulWidget {
  const DetectTimes({super.key});

  // DropdownButton의 상태를 생성하는 메서드
  @override
  State<DetectTimes> createState() => _DropdownMenuExampleState();
}

// DropdownButton의 상태를 관리하는 클래스
class _DropdownMenuExampleState extends State<DetectTimes> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      // underline: Container(
      //   height: 2,
      //   color: Colors.deepPurpleAccent,
      // ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}



// TODO : 장치 관리 기능 구현 필요
class DeviceManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '장치 관리',
          style: TextStyle(
              color: Color(0xFFA1DEFF),
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
            color: Color(0xFFA1DEFF),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Camera01',  // TODO: 기기 이름 불러오기
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '감지 시간 설정',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
                DetectTimes(),
              ],
            ),
            Text(
              '외부인이 몇 초 이상 머물렀을 때 푸쉬 알림을 받을지 시간을 선택하세요.',
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey
              ),
            ),
          ],
        ),
      )
    );
  }
}

