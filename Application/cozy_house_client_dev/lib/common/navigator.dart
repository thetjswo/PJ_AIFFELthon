import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cozy_house_client_dev/page/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../page/account_setting_page.dart';
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
  // TODO: firebase logout 기능 추가
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


// TODO : 장치 관리 기능 구현 필요
class DeviceManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장치 관리'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          '장치 관리 페이지 내용',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}


// TODO :서비스 이용약관 , 개인정보 처리방침 내용 추가 및 보완 필요
class ServiceInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('서비스 정보'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('서비스 이용약관'),
            const SizedBox(height: 10),
            _buildTextBlock(
                '''
              \n제 1장 총칙\n\n제 1조 (목적)\n본 약관은 CCTV 실시간 감시 앱 서비스(이하 \'서비스\')를 제공하는 주식회사 포근한 집(이하 \'회사\')과 회사와 이용자 간의 권리와 의무, 책임사항 및 기타 필요한 사항을 규정함을 목적으로 합니다.\n\n제 2조 (약관의 효력 및 변경)\n1. 본 약관은 서비스를 신청한 이용자에게 제공되며, 이용자는 서비스를 사용함으로써 본 약관에 동의한 것으로 간주됩니다.\n2. 회사는 본 약관을 필요에 따라 변경할 수 있으며, 변경된 약관은 서비스 내 공지사항에 게시함으로써 효력을 발생합니다. 변경된 약관에 대한 이용자의 이의제기가 없는 경우에는 약관의 변경에 대한 동의가 있는 것으로 간주됩니다.
              '''
            ),
            const SizedBox(height: 50),
            _buildSectionTitle('개인정보 처리방침'),
            const SizedBox(height: 10),
            _buildTextBlock(
                '''
               \n개인 정보 처리 방침은 서비스 이용자의 개인 정보를 보호하기 위해 회사가 어떻게 정보를 수집, 사용, 보관 및 공유하는지에 대한 내용을 담은 문서입니다. 아래는 개인 정보 처리 방침의 예시입니다:\n\n1. 수집하는 개인 정보의 항목\n- 회원 가입 시: 이름, 이메일 주소, 전화번호 등\n- 서비스 이용 시: 로그 데이터, 기기 정보, 이용 기록 등\n\n2. 개인 정보의 이용 목적\n- 서비스 제공, 운영, 유지 및 개선\n- 고객 지원 및 응대\n- 법적 의무 이행 및 분쟁 해결\n- 새로운 서비스 및 프로모션 알림 전달\n...
              '''
            ),
            const SizedBox(height: 40),
            _buildSectionTitle('어플 버전정보'),
            const SizedBox(height: 10),
            _buildTextBlock('1.0.1'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextBlock(String text) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
