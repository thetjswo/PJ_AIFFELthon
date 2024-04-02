import 'dart:convert';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/provider.dart';


class LaunchSMS {
  late String address;
  late String phone;
  late String name;

  // 기본 생성자
  LaunchSMS(context) {
    String? userInfoString = Provider.of<SharedPreferencesProvider>(context, listen: false).getData('user_info');

    if (userInfoString!.isNotEmpty) {
      Map<String, dynamic> userInfo = json.decode(userInfoString);
      name = userInfo['user_name'] ?? '';
      phone = userInfo['phone_num'] ?? '';
      address = userInfo['address'] ?? '';
    } else {
      // 데이터가 존재하지 않을 경우 처리
      print('저장된 데이터가 없습니다.');
    }
  }

  void launchSmsWithForm() async {
    late Uri url;

    final String police_num = '112';
    final String message = '안녕하세요.\n현관 CCTV에 수상한 사람이 주거침입을 시도하고 있는 영상이 확인되어 신고합니다.\n$address 주소 확인 부탁드립니다.\n관련 영상 확인은 아래의 연락처로 연락바랍니다.\n신고자 성명: $name\n신고자 연락처: $phone';

    // TODO: report_log에 컬럼 추가 기능 구현

    if (Platform.isIOS) url = Uri.parse('sms://$police_num?body=$message'); // IOS일 경우
    else url = Uri.parse('sms:$police_num?body=$message'); // IOS 이외의 플랫폼일 경우


    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}