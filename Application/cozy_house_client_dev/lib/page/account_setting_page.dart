import 'dart:convert';

import 'package:cozy_house_client_dev/api/update_user_info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../common/modal_popup.dart';
import '../common/styles.dart';
import '../utils/formatter.dart';
import '../utils/generator.dart';
import '../utils/provider.dart';
import '../utils/validator.dart';

class FormData {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String address;

  FormData({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.address,
  });

  // FormData를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'address': address,
    };
  }
}

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettingsPage> {
  final formKey = GlobalKey<FormState>();

  final FocusNode _nameFocus = FocusNode(); // 이름 포커스 여부
  final FocusNode _phoneFocus = FocusNode(); // 전화번호 포커스 여부
  final FocusNode _emailFocus = FocusNode(); // 이메일 포커스 여부
  final FocusNode _passwordFocus = FocusNode(); // 비밀번호 포커스 여부
  final FocusNode _checkPasswordFocus = FocusNode();
  final FocusNode _addressFocus = FocusNode(); // 이메일 포커스 여부

  late String _userName; // 사용자 이름
  late String _userPhoneNumber; // 사용자 전화번호
  late String _userEmail; // 사용자 이메일
  late String _userPassword; // 사용자 패스워드
  late String _userAddress; // 사용자 주소

  late String verifyEmail;
  late String device_uuid;

  // 텍스트 편집을 위한 컨트롤러
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadUserInfoData() async {
    // 앱 메모리에서 데이터 가져오기
    String? userInfoString =
        Provider.of<SharedPreferencesProvider>(context).getData('user_info');

    // 가져온 데이터 사용하기
    if (userInfoString != null) {
      Map<String, dynamic> userInfo = json.decode(userInfoString);

      _userName = userInfo['user_name'] ?? '';
      _userPhoneNumber = userInfo['phone_num'] ?? '';
      _userEmail = userInfo['user_id'] ?? '';
      _userAddress = userInfo['address'] ?? '';

      verifyEmail = userInfo['user_id'] ?? '';
      device_uuid = userInfo['device_uuid'] ?? '';
    } else {
      // 데이터가 존재하지 않을 경우 처리
      print('저장된 데이터가 없습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadUserInfoData(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            _userNameController.text = _userName;
            _phoneNumberController.text = _userPhoneNumber;
            _emailController.text = _userEmail;
            _addressController.text = _userAddress;
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  '계정 설정',
                  style: Styles.textStyle(
                      color: Color(0xFFA1DEFF),
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
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
              body: Form(
                  // 제출 양식 폼
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Container(
                        margin:
                            const EdgeInsets.only(right: 30, left: 30, top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              // 이름 입력 폼
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: _userNameController,
                                obscureText: false,
                                keyboardType:
                                    TextInputType.name, // 이름 입력을 위한 문자 키패드
                                textInputAction:
                                    TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                                onChanged: (value) {
                                  _userName = value; // 입력 값을 상태 변수에 저장
                                },
                                decoration: InputDecoration(
                                  labelText: '이름',
                                  hintText: '이름을 입력해주세요.',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
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
                                validator: (value) => CheckValidate()
                                    .validateName(_nameFocus,
                                        value!), // 이름에 특수문자 입력 여부 검증
                              ),
                            ),
                            Container(
                              // 전화번호 입력 폼
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: _phoneNumberController,
                                obscureText: false,
                                keyboardType: TextInputType.phone, // 숫자 키패드
                                textInputAction:
                                    TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter
                                      .digitsOnly, // 숫자만 인식
                                  LengthLimitingTextInputFormatter(
                                      11), // 11자리 제한
                                  PhoneNumberFormatter(), // 전화번호 형식 포맷 함수 호출
                                ],
                                onChanged: (value) {
                                  _userPhoneNumber = value; // 입력 값을 상태 변수에 저장
                                },
                                decoration: InputDecoration(
                                  labelText: '휴대전화',
                                  hintText: '휴대전화 번호를 입력해주세요.(- 제외)',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
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
                                validator: (value) => CheckValidate()
                                    .validatePhone(
                                        _phoneFocus, value!), // 전화번호 입력 개수 검증
                              ),
                            ),
                            Container(
                              // 주소 입력 폼
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: _addressController,
                                obscureText: false,
                                keyboardType:
                                    TextInputType.text, // 주소 입력을 위한 문자 키패드
                                textInputAction:
                                    TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                                onChanged: (value) {
                                  _userAddress = value; // 입력 값을 상태 변수에 저장
                                },
                                decoration: InputDecoration(
                                  labelText: '주소',
                                  hintText: '주소를 입력해주세요.',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
                                  prefixIcon: const Icon(
                                    Icons.home,
                                    color: Color(0xFFA1DEFF),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                validator: (value) => CheckValidate()
                                    .validateAddess(_addressFocus,
                                        value!), // 주소에 특수문자 입력 여부 검증
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: _emailController,
                                obscureText: false,
                                keyboardType: TextInputType
                                    .emailAddress, // 이메일 주소 입력을 위한 문자 키패드
                                textInputAction:
                                    TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                                onChanged: (value) {
                                  _userEmail = value; // 입력 값을 상태 변수에 저장
                                },
                                decoration: InputDecoration(
                                  labelText: '이메일',
                                  hintText: 'example@example.com',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
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
                                validator: (value) => CheckValidate()
                                    .validateEmail(
                                        _emailFocus, value!), // 이메일 형식 검증
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                obscureText: true, // 비밀번호 * 처리
                                keyboardType:
                                    TextInputType.text, // 비밀번호 입력을 위한 문자 키패드
                                textInputAction:
                                    TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                                onChanged: (value) {
                                  _userPassword = value; // 입력 값을 상태 변수에 저장
                                },
                                decoration: InputDecoration(
                                  labelText: '비밀번호',
                                  hintText: '비밀번호를 입력해주세요.',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
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
                                validator: (value) => CheckValidate()
                                    .validatePassword(_passwordFocus,
                                        value!), // 대소문자, 숫자, 특수문자 포함 8~15자 검증
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                obscureText: true, // 비밀번호 * 처리
                                keyboardType:
                                    TextInputType.text, // 비밀번호 입력을 위한 문자 키패드
                                textInputAction:
                                    TextInputAction.done, // 입력이 끝나면 키패드 내리기
                                decoration: InputDecoration(
                                  labelText: '비밀번호 확인',
                                  hintText: '비밀번호를 확인해주세요.',
                                  hintStyle: Styles.textStyle(
                                      color: Colors.grey.withOpacity(0.5)),
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
                                validator: (value) => CheckValidate()
                                    .checkPassword(_checkPasswordFocus, value!),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    // firebase 계정 수정
                                    final credential =
                                        await FirebaseAuth.instance.currentUser;
                                    FirebaseAuth.instance
                                        .authStateChanges()
                                        .listen((User? user) {
                                      if (user == null) {
                                        print('User is currently signed out!');
                                      } else {
                                        print('User is signed in!');
                                      }
                                    });

                                    // 비밀번호 sha256 해쉬 처리
                                    String hashedPassword = GeneratorModule()
                                        .generateSha256(_userPassword);

                                    FormData formData = FormData(
                                      uid: credential!.uid,
                                      name: _userName,
                                      phone: _userPhoneNumber,
                                      email: _userEmail,
                                      password: hashedPassword,
                                      address: _userAddress,
                                    );

                                    // 회원가입 계정 정보 서버로 전송
                                    UpdateUserInfo()
                                        .sendUpdateDataToServer(formData);

                                    // firebase 계정 정보 update
                                    if (_userEmail == verifyEmail) {
                                      // email을 수정하지 않은 경우
                                      await credential
                                          .updatePassword(_userPassword);

                                      Map<String, dynamic> user_info = {
                                        'uid': credential!.uid,
                                        'user_name': _userName,
                                        'user_id': _userEmail,
                                        'user_pw': hashedPassword,
                                        'phone_num': _userPhoneNumber,
                                        'address': _userAddress,
                                        'device_uuid': device_uuid
                                      };

                                      ModalPopUp.showSuccessToUpdateUserInfo(
                                          context, user_info);
                                    } else {
                                      // email을 수정한 경우
                                      await credential
                                          .verifyBeforeUpdateEmail(_userEmail);
                                      await credential
                                          .updatePassword(_userPassword);

                                      ModalPopUp.showSuccessToUpdateEmail(
                                          context);
                                    }
                                  }
                                },
                                style: Styles.buttonStyle_bg,
                                child: Text(
                                  '수정하기',
                                  style: Styles.textStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        )),
                  )),
            );
          }
        });
  }
}
