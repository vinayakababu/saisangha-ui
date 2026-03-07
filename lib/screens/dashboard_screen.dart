import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/login_screen.dart';
import 'package:sai_sangha_app/screens/user_screen.dart'; // <-- ensure this has UserDetailsScreen
import 'package:sai_sangha_app/screens/user_details_screen.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final dashboardResult = await AuthService.getDashboard();
    final summaryResult = await AuthService.getDashboardSummary();
    if (kDebugMode) {
      print("Dashboard fetch result === : $dashboardResult");
      print("Dashboard summary result === : $summaryResult");
    }
    if (dashboardResult["error"] == null && summaryResult["error"] == null) {
      final decoded = jsonDecode(dashboardResult['body']);
      final summaryDecoded = jsonDecode(summaryResult['body']);
      if (decoded is List && summaryDecoded is Map<String, dynamic>) {
        setState(() {
          dashboardItems = decoded;
          dashboardSummary = summaryDecoded;
          userRoles = dashboardResult['role'];
          if (kDebugMode) {
            print("User role from token: ${dashboardResult['role']} ================== ");
            print("Dashboard items loaded: $decoded");
            print("Dashboard summary loaded: $summaryDecoded");
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

   Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
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
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
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
                  SizedBox(height: 8),
                  Text("Menu", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (userRoles != null && userRoles == "ROLE_ADMIN")
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.blue),
                title: const Text("Create User", style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateUserScreen()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.w500)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardItems.isEmpty
              ? const Center(child: Text("No dashboard data available", style: TextStyle(fontSize: 18)))
              : ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: [
                    if (dashboardSummary != null)
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 4,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 18),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Dashboard Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
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
                                  _summaryItem("Loan Given (Month)", formatRupees(dashboardSummary!["loanGivenThisMonth"] ?? 0)),
                                  _summaryItem("Principal Collected", formatRupees(dashboardSummary!["principalCollectedThisMonth"] ?? 0)),
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
 
    );
}
}
