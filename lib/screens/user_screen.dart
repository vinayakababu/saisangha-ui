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
      appBar: AppBar(title: const Text("Create User"),
        backgroundColor: Colors.blue,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: "Phone")),
            DropdownButtonFormField<String>( decoration: const InputDecoration(labelText: "Role"),
             value: selectedRole, 
             items: roles.map((role) { 
              return DropdownMenuItem( 
                value: role,
                 child: Text(role), ); }).toList(),
                  onChanged: (value) { 
                    setState(() { 
                      selectedRole = value;
                       });
                     }, 
                    validator: (value) => value == null ? "Please select a role" : null,
                     ),
            TextField(controller: chitAmountController, decoration: const InputDecoration(labelText: "Chit Amount"), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            const Text("Loan Details", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: loanAmountController, decoration: const InputDecoration(labelText: "Loan Amount"), keyboardType: TextInputType.number),
            TextField(controller: interestController, decoration: const InputDecoration(labelText: "Interest"), keyboardType: TextInputType.number),
            TextField(controller: roiController, decoration: const InputDecoration(labelText: "ROI"), keyboardType: TextInputType.number),
            TextField(controller: dueDateController, decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)"),
            onTap: () async {
               DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
      firstDate: DateTime(2000), // earliest selectable date
      lastDate: DateTime(2100),  // latest selectable date
    );

    if (pickedDate != null) {
      setState(() {
        // Format as YYYY-MM-DD
        dueDateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  },),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _createUser, child: const Text("Create User")),
          ],
        ),
      ),
    );
  }
}
