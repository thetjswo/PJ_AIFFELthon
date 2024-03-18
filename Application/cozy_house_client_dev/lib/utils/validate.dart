import 'package:flutter/material.dart';

String? _oldValue;

class CheckValidate{

  String? validateName(FocusNode focusNode, String value){
    if(value.isEmpty){
      return '이름을 입력하세요.';
    }else {
      String pattern = r'^[^0-9]*$';
      RegExp regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        return '이름에 숫자를 사용할 수 없습니다.';
      }else{
        return null;
      }
    }
  }

  String? validatePhone(FocusNode focusNode, String value){
    if(value.isEmpty){
      return '휴대폰 번호를 입력하세요.';
    }else {
      if(value.length < 13){
        return '전체 전화번호를 입력하세요.';
      }else{
        return null;
      }
    }
  }

  String? validateEmail(FocusNode focusNode, String value){
    if(value.isEmpty){
      return '이메일을 입력하세요.';
    }else {
      String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        return '잘못된 이메일 형식입니다.';
      }else{
        return null;
      }
    }
  }

  String? validatePassword(FocusNode focusNode, String value){
    if(value.isEmpty){
      return '비밀번호를 입력하세요.';
    }else {
      String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
      RegExp regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        return '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      } else{
        _oldValue = value;
        return null;
      }
    }
  }

  String? checkPassword(FocusNode focusNode, String value){
    if(value.isEmpty){
      return '비밀번호를 입력하세요.';
    } else if(_oldValue != value) {
      return '비밀번호가 일치하지 않습니다.';
    } else {
      String pattern = r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{8,15}$';
      RegExp regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        return '특수문자, 대소문자, 숫자 포함 8자 이상 15자 이내로 입력하세요.';
      } else{
        return null;
      }
    }
  }
}
