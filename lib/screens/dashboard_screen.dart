import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sai_sangha_app/screens/about_page.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/login_screen.dart';
import 'package:sai_sangha_app/screens/user_screen.dart';
import 'package:sai_sangha_app/screens/user_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:sai_sangha_app/screens/notification_screen.dart';
import 'package:sai_sangha_app/screens/send_notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> dashboardItems = [];
  Map<String, dynamic>? dashboardSummary;
  bool isLoading = true;
  String? userRoles;
  int unreadCount = 0;
  Timer? _timer;
  int _selectedIndex = 0;
  String loggedInUserId = "";

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _loadUnreadCount();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    final dashboardResult = await AuthService.getDashboard();
    final summaryResult = await AuthService.getDashboardSummary();
    if (dashboardResult["error"] == null && summaryResult["error"] == null) {
      final decoded = jsonDecode(dashboardResult['body']);
      final summaryDecoded = jsonDecode(summaryResult['body']);
      if (decoded is List && summaryDecoded is Map<String, dynamic>) {
        setState(() {
          dashboardItems = decoded;
          dashboardSummary = summaryDecoded;
          userRoles = dashboardResult['role'];
          loggedInUserId = dashboardResult['loggedInUserId'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    final result = await AuthService.getUserNotifications();
    if (result['error'] == null && result['body'] != null) {
      final notifications = jsonDecode(result['body']);
      final count = (notifications as List<dynamic>)
          .where((n) => n['status'] == 'UNREAD')
          .toList();
      setState(() => unreadCount = count.length);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onItemTapped(int index,) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailsScreen(userId: loggedInUserId, loggedInUserRole: userRoles ?? "USER")),
        ).then((_) => _loadDashboard());
        break;
    }
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
      ],
    );
  }

  Color _getCardColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red.shade100;
      case 'member':
        return Colors.green.shade200;
      case 'operator':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  String formatRupees(num amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sai Sangha Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.blue),
                onPressed: () async {
                  final result = await AuthService.getUserNotifications();
                  if (result['error'] == null && result['body'] != null) {
                    final notifications =
                        jsonDecode(result['body']) as List<dynamic>;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            NotificationsScreen(notifications: notifications),
                      ),
                    ).then((_) => _loadUnreadCount());
                  }
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFFECECEF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.spa_rounded, size: 48, color: Colors.white),
                 /* CircleAvatar(
                        radius: 38,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage('saibaba.png'),
                      ), */
                  SizedBox(height: 8),
                  Text("Menu",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: Colors.blue),
              title: const Text("Dashboard"),
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Profile"),
              onTap: () => _onItemTapped(1),
            ),
            if (userRoles == "ROLE_ADMIN")
              ListTile(
                leading: const Icon(Icons.notifications_active, color: Colors.orange),
                title: const Text("Send Notification"),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TriggerNotificationScreen()),
                  );

                },
              ),
            if (userRoles == "ROLE_ADMIN")
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blue),
                title: const Text("Create User"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateUserScreen(userId: "")),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
              title: const Text("About"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardItems.isEmpty
              ? const Center(
                  child: Text("No dashboard data available",
                      style: TextStyle(fontSize: 18)))
              : ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    if (dashboardSummary != null)
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 18),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Dashboard Summary",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
 fontSize: 20, color: Colors.blue)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryItem("Total Members", dashboardSummary!["totalMembers"].toString()),
                                  _summaryItem("Active Loans", dashboardSummary!["activeLoans"].toString()),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryItem("Outstanding", formatRupees(dashboardSummary!["totalOutstandingLoan"] ?? 0)),
                                  _summaryItem("Interest (Month)", formatRupees(dashboardSummary!["interestEarnedThisMonth"] ?? 0)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryItem("ChitFund Amount", formatRupees(dashboardSummary!["chitFundAmount"] ?? 0)),
                                  _summaryItem("Loan Given (Month)", formatRupees(dashboardSummary!["loanGivenThisMonth"] ?? 0)),
                                 // _summaryItem("Principal Collected", formatRupees(dashboardSummary!["principalCollectedThisMonth"] ?? 0)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _summaryItem("Total Expected Collection (Month)", formatRupees(dashboardSummary!["totalExpectedCollectionForThisMonth"] ?? 0)),
                                  //  _summaryItem("Loan Given (Month)", formatRupees(dashboardSummary!["loanGivenThisMonth"] ?? 0)),
                                  
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Members", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                    ),
                    ...dashboardItems.map((user) {
                      final num amount = (user['amountToBePaidOnCurrentMonth'] ?? 0);
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailsScreen(userId: user['phone'], loggedInUserRole: userRoles ?? "USER"),
                            ),
                          );
                          _loadDashboard();
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          color: Colors.white,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getCardColor(user['role']),
                                  child: Text(user['name'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text("Phone: ${user['phone']}", style: const TextStyle(color: Colors.black54)),
                                      Text("Role: ${user['role']}", style: const TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text("To Pay", style: TextStyle(fontSize: 12, color: Colors.black54)),
                                    Text(formatRupees(amount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
                bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1:
        // Notifications (admin only)
          AuthService.getUserNotifications().then((result) {
            if (result['error'] == null && result['body'] != null) {
              final notifications = jsonDecode(result['body']) as List<dynamic>;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsScreen(notifications: notifications),
                ),
              ).then((_) => _loadUnreadCount());
            }
          });
        
        break;
      case 2:
        // About
       Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => UserDetailsScreen(userId: loggedInUserId, loggedInUserRole: userRoles ?? "USER")),
        ).then((_) => _loadDashboard());
        break;
    }
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: 'Notifications',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person, color: Colors.green),
      label: 'Profile',
    ),
  ],
),

 
    );
}
}
