import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaunchSMS extends StatelessWidget {
  final String phoneNumber;
  final String message;

  const LaunchSMS({
    super.key,
    required this.phoneNumber,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _launchSMS(context, phoneNumber, message),
      icon: const Icon(Icons.emergency_outlined, color: Colors.red),
      iconSize: 60,
    );
  }

  Future<void> _launchSMS(
      BuildContext context, String phoneNumber, String message) async {
    final Uri url = Uri.parse('sms:$phoneNumber?body=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch SMS app')),
      );
    }
  }
}
