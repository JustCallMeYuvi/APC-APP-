import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class WarningsScreen extends StatefulWidget {
  const WarningsScreen({Key? key}) : super(key: key);

  @override
  _WarningsScreenState createState() => _WarningsScreenState();
}

class _WarningsScreenState extends State<WarningsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Warningfs Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed:(){
                FlutterBackgroundService().invoke('setAsForeground');
              } ,
              child: Text('Check Notifications'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: (){
                 FlutterBackgroundService().invoke('setAsBackground');
              },
              child: Text('Show Message'),
            ),
            // Add more buttons as needed
          ],
        ),
      ),
    );
  }

  void _checkNotifications() {
    // Add your notification checking logic here
    // For example, show a dialog or navigate to a notifications page
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: Text('Checking notifications...'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage() {
    // Add your logic to show a message here
    // For example, show a snack bar or a dialog with a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('This is a message!'),
      ),
    );
  }
}
