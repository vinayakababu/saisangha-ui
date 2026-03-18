import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';

class TriggerNotificationScreen extends StatefulWidget {
  @override
  _TriggerNotificationScreenState createState() => _TriggerNotificationScreenState();
}

class _TriggerNotificationScreenState extends State<TriggerNotificationScreen> {
  String statusMessage = "";

  Future<void> sendNotificationToAll() async {
    const message = "Payment due reminder for this month";
    bool success = await AuthService.sendNotificationToAll(message);

    setState(() {
      if (success) {
        statusMessage = "✅ Successfully sent notifications to users";
      } else {
        statusMessage = "❌ Failed to send notification";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trigger Notification", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "If the notification has not been received on the 10th of this month, "
              "click the button below to send a reminder notification to all users "
              "about the payment due for this month.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.notifications_active),
              label: Text("Send Payment Due Notification"),
              onPressed: sendNotificationToAll,
            ),
            SizedBox(height: 24),
            if (statusMessage.isNotEmpty)
              Text(
                statusMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: statusMessage.contains("Successfully") ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
