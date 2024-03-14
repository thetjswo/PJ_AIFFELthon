import 'package:flutter/material.dart';

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
      {Key? key,
      required this.titleText,
      required this.selectedIndex,
      required this.pages,
      required this.onChanged})
      : super(key: key);

  @override
  _CustomNavigatorState createState() => _CustomNavigatorState();
}

class _CustomNavigatorState extends State<CustomNavigator> {
  int _selectedIndex = 0;

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
      // 좌측 drawer 메뉴바
      drawer: Drawer(
        child: ListView(
          children: [
            //TODO: 사용자 계정 정보 연동
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFD0A9F5),
              ),
              accountName: Text(
                '이코지',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                'ecozy@gmail.com',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('계정 설정'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.app_settings_alt_outlined),
              title: const Text('장치 관리'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('서비스 정보'),
              onTap: () {},
            ),
            //TODO: 스마트폰 별 화면 비율을 고려해서 적당한 비율로 공백 추가 필요
            const SizedBox(
              height: 300,
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('로그아웃'),
              onTap: () {},
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
}
