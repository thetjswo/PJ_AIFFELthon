import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cozy_house_client_dev/page/login_page.dart';
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


  const CustomNavigator(
      {super.key,
        required this.titleText,
        required this.selectedIndex,
        required this.pages,
        required this.onChanged});


  @override
  _CustomNavigatorState createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator> {
  int _selectedIndex = 0;
  late String user_name;
  late String user_email;


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

  Future<void> loadProfileData() async {
    // 앱 메모리에서 데이터 가져오기
    String? userInfoString = Provider.of<SharedPreferencesProvider>(context).getData('user_info');

    // 가져온 데이터 사용하기
    if (userInfoString!.isNotEmpty) {
      Map<String, dynamic> userInfo = json.decode(userInfoString);
      user_name = userInfo['user_name'] ?? '';
      user_email = userInfo['user_id'] ?? '';
    } else {
      // 데이터가 존재하지 않을 경우 처리
      print('저장된 데이터가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadProfileData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터가 로드되기 전에 로딩 표시를 보여줍니다.
            return CircularProgressIndicator();
          } else {
            // 데이터가 로드된 후에는 화면을 그립니다.
            return Scaffold(
              //앱 바
              appBar: AppBar(
                backgroundColor: const Color(0xFFFFFFFF),
                title: Text(
                  // 메인 화면에서 매개변수로 넘어오는 제목 데이터
                  widget.titleText,
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
                    color: const Color(0xFFA1DEFF),
                    height: 1.0,
                  ),
                ),
              ),
              // 좌측 drawer 메뉴바
              drawer: Drawer(
                child: ListView(
                  children: [
                    UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: Color(0xFFA1DEFF),
                      ),
                      accountName: Text(
                        user_name ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      accountEmail: Text(
                        user_email ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                      currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('계정 설정'),
                      onTap: () {
                        _openAccountSettings(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.app_settings_alt_outlined),
                      title: const Text('장치 관리'),
                      onTap: () {
                        _openDeviceManagement(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('서비스 정보'),
                      onTap: () {
                        _openServiceInfo(context);
                      },
                    ),
                    //TODO: 스마트폰 별 화면 비율을 고려해서 적당한 비율로 공백 추가 필요
                    const SizedBox(
                      height: 300,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout_outlined),
                      title: const Text('로그아웃'),
                      onTap: () async {
                        // 앱 메모리에 저장된 사용자 정보 삭제
                        _logout(context);
                      },
                    )
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
        },
    );
  }
}