import 'package:demo/common/navigator.dart';
import 'package:demo/page/history_page.dart';
import 'package:demo/page/security_page.dart';
import 'package:flutter/material.dart';

import 'monitor_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cozy House',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // 탭 라벨 인덱스 - 초깃값 0
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomNavigator(
      titleText: _getSelectedTitle(),
      // 초기는 security page가 노출되고,
      selectedIndex: _selectedIndex,
      // 탭 이벤트가 발생하면 해당 탭의 인덱스로 화면을 조회하여 노출시킨다.
      onChanged: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      pages: [
        SecurityPage(),
        MonitorPage(),    // video_stream 페이지 테스트 안하려면 이 부분 주석해제하고 VideoStream() 주석처리
        // const VideoStream(), // video_stream 페이지 테스트 하기 위해 추가
        HistoryPage(),
      ],
    );
  }

  String _getSelectedTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Security';
      case 1:
        return 'Monitor';
      case 2:
        return 'Record';
      default:
        return 'Default';
    }
  }
}
