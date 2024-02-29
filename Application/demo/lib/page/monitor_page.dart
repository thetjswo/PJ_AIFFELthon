import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MonitorPage extends StatefulWidget {
  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  String server_url = dotenv.get('SERVER_URL');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(server_url),
    );
  }
}