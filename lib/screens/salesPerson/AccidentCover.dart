import 'package:flutter/material.dart';

class AccidentCover extends StatefulWidget {
  const AccidentCover({super.key});

  @override
  State<AccidentCover> createState() => _AccidentCoverState();
}

class _AccidentCoverState extends State<AccidentCover> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _initialsController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _premiumController = TextEditingController();
  final TextEditingController _coverValueController = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // You can handle your save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Accident Cover Form')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Name with Initials', _initialsController),
              _buildTextField('NIC', _nicController),
              _buildTextField('Date of Birth', _dobController,
                  readOnly: true, onTap: _selectDate),
              _buildTextField('Bill No', _billNoController),
              _buildTextField('Bill Amount', _billAmountController,
                  isNumber: true),
              _buildTextField('Premium Value', _premiumController,
                  isNumber: true),
              _buildTextField('Cover Value', _coverValueController,
                  isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 173, 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14)),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
