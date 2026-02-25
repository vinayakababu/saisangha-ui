import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/login_screen.dart';
import 'package:sai_sangha_app/screens/user_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> dashboardItems = [];
  bool isLoading = true;
  String? userRoles;
  

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final result = await AuthService.getDashboard();
    if (kDebugMode) {
      print(  "Dashboard fetch result === : $result");
    }
    if (result["error"] == null) {
      final decoded = jsonDecode(result['body']);

      if (decoded is List) {
        setState(() {
          dashboardItems = decoded;
          userRoles = result['role'];
          if (kDebugMode) {
            print(  "User role from token: ${result['role']} ================== ");
          }
          if (kDebugMode) {
            print(  "Dashboard items loaded: $decoded");
          }
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
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
        title: const Text("Dashboard"),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
  child: ListView(
    children: [
      const DrawerHeader(
        decoration: BoxDecoration(color: Colors.blue),
        child: Text("Menu",
            style: TextStyle(color: Colors.white, fontSize: 20)),
      ),
      // Show Create User only if logged-in user is ADMIN
      if (userRoles != null && userRoles == "ROLE_ADMIN")
        ListTile(
          leading: const Icon(Icons.person_add),
          title: const Text("Create User"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateUserScreen()),
            );
          },
        ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text("Logout"),
        onTap: _logout,
      ),
    ],
  ),
),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardItems.isEmpty
              ? const Center(child: Text("No dashboard data available"))
              : ListView.builder(
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final user = dashboardItems[index];
                    return Card(
                      color: _getCardColor(user['role']),
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${user['name']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("Phone: ${user['phone']}"),
                            Text("Role: ${user['role']}"),
                            Text("Chit Amount: ${formatRupees(user['chitAmount'])}"),
                            Text("Amount To Be Paid: ${formatRupees(user['amountToBePaid'])}",
                              style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            if (user['loanEntries'] != null &&
                                user['loanEntries'].isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Loan Entries:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  ...user['loanEntries'].map<Widget>((loan) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                          "- Loan: ${formatRupees(loan['loanAmount'])} | Interest: ${formatRupees(loan['interest'])} | ROI: ${formatRupees(loan['roi'])} | Due: ${loan['dueDate']}"),
                                    );
                                  }).toList(),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
