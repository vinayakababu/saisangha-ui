import 'package:flutter/material.dart';


class NotificationsScreen extends StatelessWidget {
  final List<dynamic> notifications;
  const NotificationsScreen({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: notifications.isEmpty
          ? const Center(child: Text("No notifications"))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(n['title'] ?? 'Notification'),
                  subtitle: Text(n['message'] ?? ''),
                );
              },
            ),
    );
  }
}
