import 'package:flutter/material.dart';

// TODO : 장치 관리 기능 구현 필요
class DeviceManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '장치 관리',
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
      body: const Center(
        child: Text(
          '장치 관리 페이지 내용',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}