import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

// TODO :서비스 이용약관 , 개인정보 처리방침 내용 추가 및 보완 필요
class ServiceInfoPage extends StatelessWidget {
  final Future<PackageInfo> info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '서비스 정보',
          style: TextStyle(
              color: Color(0xFFA1DEFF),
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFA1DEFF),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
            _buildSectionTitle('앱 버전 정보'),
            const SizedBox(height: 10),
            FutureBuilder<PackageInfo>(
              future: info,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildTextBlock(snapshot.data!.version);
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Color(0xFFA1DEFF), fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextBlock(String text) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.grey),
          //   borderRadius: BorderRadius.circular(10),
          // ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}