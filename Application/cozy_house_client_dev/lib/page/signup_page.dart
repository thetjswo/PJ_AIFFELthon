import 'package:cozy_house_client_dev/api/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../common/firebase_authentication.dart';
import '../common/modal_popup.dart';
import '../common/styles.dart';
import '../utils/formatter.dart';
import '../utils/generate_hash.dart';
import '../utils/validate.dart';


class FormData {
  final String name;
  final String phone;
  final String email;
  final String password;
  final bool agree;
  final String fcmToken;

  FormData({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.agree,
    required this.fcmToken
  });

  // FormData를 JSON 형식으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'agree': agree,
      'fcmToken':fcmToken
    };
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpPage> {
  final formKey = GlobalKey<FormState>();

  final FocusNode _nameFocus = FocusNode(); // 이름 포커스 여부
  final FocusNode _phoneFocus = FocusNode(); // 전화번호 포커스 여부
  final FocusNode _emailFocus = FocusNode(); // 이메일 포커스 여부
  final FocusNode _passwordFocus = FocusNode(); // 비밀번호 포커스 여부
  final FocusNode _checkPasswordFocus = FocusNode(); // 비밀번호 확인 포커스 여부

  late String _userName; // 사용자 이름
  late String _userPhoneNumber; // 사용자 전화번호
  late String _userEmail; // 사용자 이메일
  late String _userPassword; // 사용자 패스워드
  late bool _consentPersonalInfo = false; // 개인정보 동의 체크 여부

  @override
  void initState() {
    super.initState();
    _userName = '';
    _userPhoneNumber = '';
    _userEmail = '';
    _userPassword = '';
    _consentPersonalInfo = false;
  }

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
                      onChanged: (value) {
                        setState(() {
                          _userName = value; // 입력 값을 상태 변수에 저장
                        });
                      },
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
                      onChanged: (value) {
                        setState(() {
                          _userPhoneNumber = value; // 입력 값을 상태 변수에 저장
                        });
                      },
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
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress, // 이메일 주소 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      onChanged: (value) {
                        setState(() {
                          _userEmail = value; // 입력 값을 상태 변수에 저장
                        });
                      },
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
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      obscureText: true, // 비밀번호 * 처리
                      keyboardType: TextInputType.text, // 비밀번호 입력을 위한 문자 키패드
                      textInputAction: TextInputAction.next, // 다음 폼으로 넘어가는 버튼
                      onChanged: (value) {
                        setState(() {
                          _userPassword = value; // 입력 값을 상태 변수에 저장
                        });
                      },
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
                      validator: (value) => CheckValidate().validatePassword(_passwordFocus, value!), // 대소문자, 숫자, 특수문자 포함 8~15자 검증
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
                      validator: (value) => CheckValidate().checkPassword(_checkPasswordFocus, value!),
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
                              value: _consentPersonalInfo,
                              onChanged: (value) {
                                setState(() {
                                  _consentPersonalInfo = value!;
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
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            // firebase 계정 생성
                            await FirebaseAuthentication.create_account(_userEmail, _userPassword);

                            String fcm_token = await FirebaseAuthentication.get_push_token(dotenv.get('FIREBASE_API_KEY'));

                            // 비밀번호 sha256 해쉬 처리
                            String hashedPassword = GenerateHash().generateSha256(_userPassword);

                            // 회원가입 계정 정보 서버로 전송
                            FormData formData = FormData(
                              name: _userName,
                              phone: _userPhoneNumber,
                              email: _userEmail,
                              password: hashedPassword,
                              agree: _consentPersonalInfo,
                              fcmToken:fcm_token
                            );

                            SignUp().sendSignUpDataToServer(formData);

                            // login 화면으로 전환
                            ModalPopUp.showSignUpSuccess(context);
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              ModalPopUp.showSignUpFailedWeakPassword(context);
                            } else if (e.code == 'email-already-in-use') {
                              ModalPopUp.showSignUpFailedExistAccount(context);
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
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