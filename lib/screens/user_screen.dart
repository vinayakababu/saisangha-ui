import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';
import 'package:sai_sangha_app/screens/dashboard_screen.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({Key? key}) : super(key: key);

  @override
  _CreateUserScreenState createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController roleController = TextEditingController();
  final TextEditingController chitAmountController = TextEditingController();

  // Loan entry controllers
  final TextEditingController loanAmountController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController roiController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();

  bool isLoading = false;
  String? selectedRole;
  final List<String> roles = ["ADMIN", "USER"]; 
  
  Future<void> _createUser() async {
    setState(() => isLoading = true);

    final loanEntry = {
      "loanAmount": int.tryParse(loanAmountController.text) ?? 0,
      "interest": double.tryParse(interestController.text) ?? 0.0,
      "roi": double.tryParse(roiController.text) ?? 0.0,
      "dueDate": dueDateController.text,
      "includePrincipal": true
    };

    final userData = {
      "name": nameController.text,
      "phone": phoneController.text,
      "role": selectedRole,
      "chitAmount": int.tryParse(chitAmountController.text) ?? 0,
      "loanEntries": [loanEntry]
    };
    print("Creating user with data: $userData");

    final success = await AuthService.createUser(userData);

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User created successfully")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create user")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 4,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("User Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Phone", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Role", border: OutlineInputBorder()),
                  value: selectedRole,
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                  },
                  validator: (value) => value == null ? "Please select a role" : null,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: chitAmountController,
                  decoration: const InputDecoration(labelText: "Chit Amount", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                const Text("Loan Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 10),
                TextField(
                  controller: loanAmountController,
                  decoration: const InputDecoration(labelText: "Loan Amount", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: interestController,
                  decoration: const InputDecoration(labelText: "Interest", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roiController,
                  decoration: const InputDecoration(labelText: "ROI", border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)", border: OutlineInputBorder()),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        dueDateController.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _createUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Create User", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
