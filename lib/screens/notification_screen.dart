import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  final List<dynamic> notifications;
  const NotificationsScreen({super.key, required this.notifications});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.notifications
        .where((n) => (n['status']?.toString().toUpperCase() == 'UNREAD'))
        .toList();
    final read = widget.notifications
        .where((n) => (n['status']?.toString().toUpperCase() == 'READ'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Unread"),
            Tab(text: "Read"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(unread, true),
          _buildList(read, false),
        ],
      ),
    );
  }

  Widget _buildList(List<dynamic> items, bool unread) {
    if (items.isEmpty) {
      return Center(
        child: Text(unread
            ? "No unread notifications"
            : "No read notifications"),
      );
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final n = items[index];
        return ListTile(
          leading: Icon(
            unread ? Icons.markunread : Icons.drafts,
            color: unread ? Colors.red : Colors.grey,
          ),
          title: Text(
            n['title'] ?? 'Notification',
            style: TextStyle(
              fontWeight:
                  unread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(n['message'] ?? ''),
          onTap: unread
              ? () async {
                  if (n['id'] != null) {
                    final result =
                        await AuthService.markNotificationAsRead(n['id']);
                    if (result['error'] == null) {
                      if (mounted) {
                        setState(() {
                          n['status'] = 'READ'; // ✅ update status
                          n['readDate'] =
                              DateTime.now().toIso8601String();
                        });
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Marked as read")),
                      );
                    }
                  }
                }
              : null,
        );
      },
    );
  }
}
