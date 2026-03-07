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
  late TextEditingController _roiController;
  late TextEditingController _dueDateController;
  bool _includePrincipal = true;

  @override
  void initState() {
    super.initState();
    _loanAmountController = TextEditingController(
        text: widget.existingLoan?['loanAmount']?.toString() ?? '');
    _roiController = TextEditingController(
        text: widget.existingLoan?['roi']?.toString() ?? '');
    _dueDateController =
        TextEditingController(text: widget.existingLoan?['dueDate'] ?? '');
    _includePrincipal = widget.existingLoan?['includePrincipal'] ?? true;
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _roiController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

    Future<void> _pickDueDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveLoan() async {
    if (_formKey.currentState!.validate()) {
      final payload = {
        "loanAmount": double.tryParse(_loanAmountController.text) ?? 0,
        "roi": double.tryParse(_roiController.text) ?? 0,
        "dueDate": _dueDateController.text,
        "includePrincipal": _includePrincipal,
      };

      final result = widget.existingLoan == null
          ? await AuthService.addLoan(widget.userId, payload)
          : await AuthService.updateLoan(
              widget.userId, widget.existingLoan?['id'], payload);
        print( "Loan save result: $result ================== ");

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
        title: Text(isEdit ? "Edit Loan" : "Add Loan", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.blue),
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEdit ? "Edit Loan Details" : "Add Loan Details", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _loanAmountController,
                        decoration: const InputDecoration(labelText: "Loan Amount", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        validator: (val) => val == null || val.isEmpty ? "Enter loan amount" : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _roiController,
                        decoration: const InputDecoration(labelText: "ROI (%)", border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _dueDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Due Date",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: _pickDueDate,
                        validator: (value) => value == null || value.isEmpty ? "Select due date" : null,
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text("Include Principal"),
                        value: _includePrincipal,
                        onChanged: (val) => setState(() => _includePrincipal = val),
                        contentPadding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveLoan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(isEdit ? "Update Loan" : "Add Loan", style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
