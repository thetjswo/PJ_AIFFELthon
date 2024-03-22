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
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _toggleState
                  ? Image.asset(
                'assets/images/icon/shield_4_green.png',
                key: UniqueKey(),
                width: 200,
                height: 200,
              )
                  : Image.asset(
                'assets/images/icon/shield_4_red.png',
                key: UniqueKey(),
                width: 200,
                height: 200,
              ),
            ),
            SizedBox(height: 20),
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
      ),
    );
  }
}
