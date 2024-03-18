import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/styles.dart';
import '../utils/formatter.dart';
import '../utils/validate.dart';


final formKey = GlobalKey<FormState>();


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  bool _isChecked = false; // 개인정보 동의 체크 여부
  final FocusNode _nameFocus = FocusNode(); // 전화번호 포커스 여부
  final FocusNode _phoneFocus = FocusNode(); // 전화번호 포커스 여부
  final FocusNode _emailFocus = FocusNode(); // 이메일 포커스 여부
  final FocusNode _passwordFocus = FocusNode(); // 비밀번호 포커스 여부
  final FocusNode _checkPasswordFocus = FocusNode(); // 비밀번호 확인 포커스 여부
  late String? _inputPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SIGN UP',
          style: TextStyle(
              color: Color(0xFFA1DEFF),
              fontSize: 25,
              fontWeight: FontWeight.bold
          ),
        ),
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
      body: Form( // 제출 양식 폼
        key: formKey,
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.only(right: 30, left: 30, top: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container( // 이름 입력 폼
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: false,
                      keyboardType: TextInputType.name, // 이름 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      decoration: InputDecoration(
                        labelText: '이름',
                        hintText: '이름을 입력해주세요.',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFA1DEFF),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) => CheckValidate().validateName(_nameFocus, value!), // 이름에 특수문자 입력 여부 검증
                      autovalidateMode: AutovalidateMode.onUserInteraction, // 사용자 입력이 있을 때 자동으로 인식
                    ),
                  ),
                  Container( // 전화번호 입력 폼
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: false,
                      keyboardType: TextInputType.phone, // 숫자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly, // 숫자만 인식
                        LengthLimitingTextInputFormatter(11), // 11자리 제한
                        PhoneNumberFormatter(), // 전화번호 형식 포맷 함수 호출
                      ],
                      decoration: InputDecoration(
                        labelText: '휴대전화',
                        hintText: '휴대전화 번호를 입력해주세요.(- 제외)',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFFA1DEFF),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) => CheckValidate().validatePhone(_phoneFocus, value!), // 전화번호 입력 개수 검증
                      autovalidateMode: AutovalidateMode.onUserInteraction, // 사용자 입력이 있을 때 자동으로 인식
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress, // 이메일 주소 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      decoration: InputDecoration(
                        labelText: '이메일',
                        hintText: 'example@example.com',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFFA1DEFF),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) => CheckValidate().validateEmail(_emailFocus, value!), // 이메일 형식 검증
                      autovalidateMode: AutovalidateMode.onUserInteraction, // 사용자 입력이 있을 때 자동으로 인식
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: true, // 비밀번호 * 처리
                      keyboardType: TextInputType.text, // 비밀번호 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      decoration: InputDecoration(
                        labelText: '비밀번호',
                        hintText: '비밀번호를 입력해주세요.',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.password_outlined,
                          color: Color(0xFFA1DEFF),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) {
                        String? res = CheckValidate().validatePassword(_passwordFocus, value!);
                        if (res == null) _inputPassword = value;
                        return null;
                      }, // 대소문자, 숫자, 특수문자 포함 8~15자 검증
                      autovalidateMode: AutovalidateMode.onUserInteraction, // 사용자 입력이 있을 때 자동으로 인식
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: true, // 비밀번호 * 처리
                      keyboardType: TextInputType.text, // 비밀번호 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.done, // 입력이 끝나면 키패드 내리기
                      decoration: InputDecoration(
                        labelText: '비밀번호 확인',
                        hintText: '비밀번호를 확인해주세요.',
                        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                        prefixIcon: const Icon(
                          Icons.password_outlined,
                          color: Color(0xFFF98B8B),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      validator: (value) => CheckValidate().reValidatePassword(_checkPasswordFocus, _inputPassword!, value!),
                      autovalidateMode: AutovalidateMode.onUserInteraction, // 사용자 입력이 있을 때 자동으로 인식
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() {
                                  _isChecked = value!;
                                });
                              },
                            ),
                            const Text('개인정보 수집 및 동의'),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {

                                return Center(
                                  child: Container(
                                    margin: const EdgeInsets.all(10),
                                    child: const Text(
                                      '개인정보 수집 및 동의',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            '자세히',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {

                      },
                      style: Styles.buttonStyle_bg,
                      child: const Text(
                        '가입하기',
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                  )
                ],
              )
          ),
          )
        ),
    );
  }
}