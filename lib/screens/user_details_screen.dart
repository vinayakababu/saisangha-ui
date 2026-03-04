import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(title: const Text("User Details"),
        backgroundColor: Colors.blue,
        ),
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
          final String role = user['role'] ?? "USER"; // default to USER
          final num amount = (user['amountToBePaid'] ?? 0);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text("Name: ${user['name'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Phone: ${user['phone'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.normal)),
              Text("Username: ${user['username'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.normal)),
              Text("Role: ${user['role'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.normal)),
              Text("Chit Amount: ${formatRupees(user['chitAmount'] ?? 0)}", style: const TextStyle(fontWeight: FontWeight.normal)),
              Text("Amount To Be Paid: ${formatRupees(amount)}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              const Text("Loan Entries:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...(user['loanEntries'] as List<dynamic>? ?? []).map((loan) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Loan Amount: ${formatRupees(loan['loanAmount'] ?? 0)}"),
                          Text("Interest: ${(loan['interest'] ?? 0).toString()}"),
                          Text("ROI: ${(loan['roi'] ?? 0).toString()}%"),
                          Text("Include Principal: ${(loan['includePrincipal'] ?? false).toString()}"),
                          Text("Due Date: ${loan['dueDate'] ?? 'N/A'}"),
                          Text("Status: ${loan['status'] ?? 'N/A'}"),
                          Text("Created Date: ${loan['createdDate'] ?? 'N/A'}"),
                          Text("Updated Date: ${loan['updatedDate'] ?? 'N/A'}"),
                          const SizedBox(height: 8),
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
                                          userId: user['phone'], // Pass user ID or phone to identify the user in the loan form
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
                                      await _deleteLoan(loan['phone']);
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
              const SizedBox(height: 20),

              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Loan"),
                onPressed: () async {
                  final added = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoanFormScreen(userId: user['phone']), // Pass user ID or phone to identify the user in the loan form
                    ),
                  );
                  if (added == true) _refresh();
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
