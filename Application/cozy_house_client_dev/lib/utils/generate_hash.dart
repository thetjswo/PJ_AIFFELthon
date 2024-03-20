import 'dart:convert';

import 'package:crypto/crypto.dart';

class GenerateHash {
  // sha256 해쉬변환 함수
  String generateSha256(String input) {
    // UTF-8로 인코딩된 문자열을 바이트 배열로 변환
    List<int> bytes = utf8.encode(input);

    // SHA-256 해시를 생성
    Digest sha256Digest = sha256.convert(bytes);

    // 해시를 16진수 문자열로 변환하여 반환
    return sha256Digest.toString();
  }
}