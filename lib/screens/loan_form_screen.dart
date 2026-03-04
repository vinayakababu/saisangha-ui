import 'package:flutter/material.dart';
import 'package:sai_sangha_app/services/auth_service.dart';

class LoanFormScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic>? existingLoan; // null for Add, non-null for Edit

  const LoanFormScreen({super.key, required this.userId, this.existingLoan});

  @override
  State<LoanFormScreen> createState() => _LoanFormScreenState();
}

class _LoanFormScreenState extends State<LoanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _loanAmountController;
  late TextEditingController _interestController;
  late TextEditingController _roiController;
  late TextEditingController _dueDateController;
  bool _includePrincipal = true;

  @override
  void initState() {
    super.initState();
    _loanAmountController = TextEditingController(
        text: widget.existingLoan?['loanAmount']?.toString() ?? '');
    _interestController = TextEditingController(
        text: widget.existingLoan?['interest']?.toString() ?? '');
    _roiController = TextEditingController(
        text: widget.existingLoan?['roi']?.toString() ?? '');
    _dueDateController =
        TextEditingController(text: widget.existingLoan?['dueDate'] ?? '');
    _includePrincipal = widget.existingLoan?['includePrincipal'] ?? true;
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestController.dispose();
    _roiController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "loanAmount": double.tryParse(_loanAmountController.text) ?? 0,
        "interest": double.tryParse(_interestController.text) ?? 0,
        "roi": double.tryParse(_roiController.text) ?? 0,
        "dueDate": _dueDateController.text,
        "includePrincipal": _includePrincipal,
      };

      final result = widget.existingLoan == null
          ? await AuthService.addLoan(widget.userId, payload)
          : await AuthService.updateLoan(
              widget.userId, widget.existingLoan?['id'], payload);

      if (result['error'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(widget.existingLoan == null
                  ? "Loan added successfully"
                  : "Loan updated successfully")),
        );
        Navigator.pop(context, true); // return success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['error']}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingLoan != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Loan" : "Add Loan"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _loanAmountController,
                decoration: const InputDecoration(labelText: "Loan Amount"),
                keyboardType: TextInputType.number,
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter loan amount" : null,
              ),
              TextFormField(
                controller: _interestController,
                decoration: const InputDecoration(labelText: "Interest"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _roiController,
                decoration: const InputDecoration(labelText: "ROI (%)"),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(
                    labelText: "Due Date (YYYY-MM-DD)"),
              ),
              SwitchListTile(
                title: const Text("Include Principal"),
                value: _includePrincipal,
                onChanged: (val) => setState(() => _includePrincipal = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveLoan,
                child: Text(isEdit ? "Update Loan" : "Add Loan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
