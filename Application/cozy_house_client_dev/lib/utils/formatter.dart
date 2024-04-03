// 전화번호 입력 시, 한국 번호 형식인 010-xxxx-xxxx 형식으로 고정
import 'dart:convert';

import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  static const kPhoneNumberPrefix = '010-';


  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = _getFormattedPhoneNumber(newValue.text);

    // 업데이트된 선택과 함께 포맷된 텍스트를 반환
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  // 전화번호의 길이에 따라 형식을 지정하는 메서드
  String _getFormattedPhoneNumber(String value) {
    value = _cleanPhoneNumber(value);

    if (value.length == 1) {
      //값이 없을 때 010-최초값 포멧
      value = kPhoneNumberPrefix + value.substring(0, value.length);
    } else if (value.length < 4) {
      // 010- 을 지우지 못하도록 010- 유지
      value = kPhoneNumberPrefix;
    } else if (value.length >= 8 && value.length < 12) {
      // 010-xxxx-xxxx 포멧
      value = '$kPhoneNumberPrefix${value.substring(3, 7)}-${value.substring(7, value.length)}';
    } else {
      // 010-xxxx 포멧 (자릿수 제한은 inputformatters 로 구현)
      value = kPhoneNumberPrefix + value.substring(3, value.length);
    }

    return value;
  }

  // 입력에서 숫자가 아닌 문자를 제거하는 메서드
  String _cleanPhoneNumber(String value) {
    return value.replaceAll(RegExp(r'[-\s]'), '');
  }
}

class JsonFormatter {
  request_formatter(obj) {
    String requestBody = json.encode(obj);

    return requestBody;
  }

  response_formatter(obj) {
    var decoded_body = utf8.decode(obj);
    var decoded_json = json.decode(decoded_body);

    return decoded_json;
  }
}