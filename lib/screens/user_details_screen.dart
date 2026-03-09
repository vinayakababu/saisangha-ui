import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sai_sangha_app/screens/user_screen.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/loan_form_screen.dart';


class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final String loggedInUserRole;

  const UserDetailsScreen({super.key, required this.userId, required this.loggedInUserRole});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserDetails();
  }

  Future<Map<String, dynamic>> _fetchUserDetails() async {
    final result = await AuthService.getUserDetails(widget.userId);
    if (result['error'] == null && result['body'] != null) {
      return jsonDecode(result['body']);
    } else {
      throw Exception(result['error'] ?? "Unknown error");
    }
  }

  void _refresh() {
    setState(() {
      _userFuture = _fetchUserDetails();
    });
  }

  Future<void> _deleteLoan(String loanId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this loan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final result = await AuthService.deleteLoan(widget.userId, loanId);
      print("Delete loan result: $result");
      if (result['error'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Loan deleted successfully")),
        );
        _refresh();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['error']}")),
        );
      }
    }
  }

  String formatRupees(num amount) {
    return NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No details found"));
          }

          final user = snapshot.data!;
          final String role = user['role'] ?? "USER";
          final num amount = (user['amountToBePaid'] ?? 0);

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            radius: 28,
                            child: Text(
                              (user['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text("Phone: ${user['phone'] ?? 'N/A'}", style: const TextStyle(color: Colors.black54)),
                                Text("Username: ${user['username'] ?? 'N/A'}", style: const TextStyle(color: Colors.black54)),
                                Text("Role: ${user['role'] ?? 'N/A'}", style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _infoItem("Chit Amount", formatRupees(user['chitAmount'] ?? 0))),
                          const SizedBox(width: 8),
                          Expanded(child: _infoItem("To Be Paid", formatRupees(amount))),
                        ],
                      ),
                       if(widget.loggedInUserRole == "ROLE_ADMIN")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateUserScreen(
                                          userId: user['phone'],
                                          existingUser: user,
                                        ),
                                      ),
                                    );
                                    if (updated == true) _refresh();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    if (user['id'] != null) {
                                      await _deleteLoan(user['id']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Loan ID missing")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Loan Entries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 8),
              ...(user['loanEntries'] as List<dynamic>? ?? []).map((loan) => Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _infoItem("Loan Amount", formatRupees(loan['loanAmount'] ?? 0))),
                              const SizedBox(width: 8),
                              Expanded(child: _infoItem("ROI", "${loan['roi'] ?? 0}%")),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(child: _infoItem("Monthly Interest", (loan['monthlyInterest'] ?? 0).toString())),
                              const SizedBox(width: 8),
                              Expanded(child: _infoItem("Include Principal", (loan['includePrincipal'] ?? false).toString())),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(child: _infoItem("Due Date", loan['dueDate'] ?? 'N/A')),
                              const SizedBox(width: 8),
                              Expanded(child: _infoItem("Status", loan['status'] ?? 'N/A')),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(child: _infoItem("Created", loan['createdDate'] ?? 'N/A')),
                              const SizedBox(width: 8),
                              Expanded(child: _infoItem("Updated", loan['updatedDate'] ?? 'N/A')),
                            ],
                          ),
                          if(widget.loggedInUserRole == "ROLE_ADMIN")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    final updated = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LoanFormScreen(
                                          userId: user['phone'],
                                          existingLoan: loan,
                                        ),
                                      ),
                                    );
                                    if (updated == true) _refresh();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    if (loan['id'] != null) {
                                      await _deleteLoan(loan['id']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Loan ID missing")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 24),
              if (widget.loggedInUserRole == "ROLE_ADMIN")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Loan", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      final added = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoanFormScreen(userId: user['phone']),
                        ),
                      );
                      if (added == true) _refresh();
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black)),
      ],
    );
  }
  }

