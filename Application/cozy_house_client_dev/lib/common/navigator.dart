import 'dart:convert';

import 'package:cozy_house_client_dev/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:cozy_house_client_dev/page/login_page.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/account_setting_page.dart';
import '../page/device_management_page.dart';
import '../page/service_info_page.dart';
import '../utils/provider.dart';

class CustomNavigator extends StatefulWidget {
  // 탭 선택 시 타이틀 동적 변환을 위한 변수
  final String titleText;
  // 탭 선택 시 색 변화를 위한 변수
  final int selectedIndex;
  // 탭 별 화면 전환을 위한 페이지 리스트 변수
  final List<Widget> pages;
  // 탭 라벨 변화를 통해 화면 전환을 하기 위한 변수
  final ValueChanged<int> onChanged;

  final String user_name;
  final String user_email;

  const CustomNavigator({
    super.key,
    required this.titleText,
    required this.selectedIndex,
    required this.pages,
    required this.onChanged,
    required this.user_name,
    required this.user_email,
  });

  @override
  _CustomNavigatorState createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator> {
  int _selectedIndex = 0;

  // 드로어 -> 로그아웃 -> 로그인 창으로 이동
  void _logout(BuildContext context) {
    Provider.of<SharedPreferencesProvider>(context, listen: false).deleteData();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  // 드로어 -> 계정 설정 창으로 이동
  void _openAccountSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
    );
  }

  // 드로어 -> 장치 관리 창으로 이동
  void _openDeviceManagement(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DeviceManagementPage()),
    );
  }

  // 드로어 -> 서비스 정보 창으로 이동
  void _openServiceInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => ServiceInfoPage()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //앱 바
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        title: Text(
          // 메인 화면에서 매개변수로 넘어오는 제목 데이터
          widget.titleText,
          style: Styles.textStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 1,
        toolbarHeight: 80.0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFA1DEFF),
            height: 1.0,
          ),
        ),
      ),
      // 좌측 drawer 메뉴바
      drawer: Drawer(
        child: Stack(
          children: [
            ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.30, // 스크린 사이즈의 20% 설정
                  child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFFA1DEFF),
                    ),
                    accountName: Text(
                      widget.user_name,
                      style: Styles.textStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    accountEmail: Text(
                      widget.user_email,
                      style: Styles.textStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    // currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.person,
                    size: 30,
                  ),
                  title: Text(
                    '계정 설정',
                    style: Styles.textStyle(
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    _openAccountSettings(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.app_settings_alt_outlined,
                    size: 30,
                  ),
                  title: Text(
                    '장치 관리',
                    style: Styles.textStyle(
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    _openDeviceManagement(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    size: 30,
                  ),
                  title: Text(
                    '서비스 정보',
                    style: Styles.textStyle(
                      fontSize: 17,
                    ),
                  ),
                  onTap: () {
                    _openServiceInfo(context);
                  },
                ),
                // 위 ListTile 3개와 아래 '로그아웃' 사이에 공백 생성
                Expanded(child: SizedBox.shrink()),
              ],
            ),
            // '로그아웃' 바닥에 고정
            Positioned(
              bottom: 20.0,
              left: 0,
              right: 0,
              child: ListTile(
                leading: const Icon(Icons.logout_outlined),
                title: Text(
                  '로그아웃',
                  style: Styles.textStyle(
                    fontSize: 17,
                  ),
                ),
                onTap: () async {
                  _logout(context);
                },
              ),
            ),
          ],
        ),
      ),
      // 메인 화면에서 매개변수로 넘어오는 화면 정보(security, video, history)를 body에 노출시킨다.
      body: widget.pages[widget.selectedIndex],
      // 하단 탭뷰
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            widget.onChanged(index);
          });
        },
        // 각 항목은 평소엔 회색, 탭 이벤트 발생 시 파란색으로 표시된다.
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.security,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Security',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
