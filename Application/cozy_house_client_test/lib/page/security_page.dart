import 'package:flutter/material.dart';

class SecurityPage extends StatefulWidget {
  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _toggleState = false;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
          margin: EdgeInsets.only(top: 180),
          child: Column(
            children: [
              Image.asset(
                'assets/images/icon/ic_security.png',
                width: 200,
                height: 200,
              ),
              SizedBox(height: 20,),
              Switch(
                value: _toggleState,
                onChanged: (value) {
                  setState(() {
                    _toggleState = value;
                  });
                },
              )
            ],
          ),
        )
    );
  }
}
