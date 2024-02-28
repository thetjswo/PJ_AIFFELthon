import 'package:demo/page/security_page.dart';
import 'package:demo/page/video_page.dart';
import 'package:flutter/material.dart';
import 'package:demo/page/history_page.dart';
import 'package:demo/common/navigator.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cozy House',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
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
        VideoPage(),
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