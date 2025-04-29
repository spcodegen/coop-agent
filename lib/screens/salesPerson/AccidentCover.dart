import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // for date formatting

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
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _billNoController = TextEditingController();
  final TextEditingController _billAmountController = TextEditingController();
  final TextEditingController _premiumController = TextEditingController();
  final TextEditingController _coverValueController = TextEditingController();
  final TextEditingController _billDateController = TextEditingController();
  final TextEditingController _validFromController = TextEditingController();
  final TextEditingController _validToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _billAmountController.addListener(_updatePremiumAndCover);
    _setValidDates();
  }

  @override
  void dispose() {
    _billAmountController.removeListener(_updatePremiumAndCover);
    super.dispose();
  }

  void _setValidDates() {
    final DateTime today = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    _validFromController.text = formatter.format(today);
    _validToController.text =
        formatter.format(today.add(const Duration(days: 30)));
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectDateOfBirth() async {
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

  void _updatePremiumAndCover() {
    double billAmount = double.tryParse(_billAmountController.text) ?? 0;

    int premium = 0;
    int cover = 0;

    if (billAmount >= 5000 && billAmount < 7500) {
      premium = 50;
      cover = 500000;
    } else if (billAmount >= 7500 && billAmount < 10000) {
      premium = 75;
      cover = 750000;
    } else if (billAmount >= 10000) {
      premium = 100;
      cover = 1000000;
    }

    _premiumController.text = premium.toString();
    _coverValueController.text = cover.toString();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String? _getDobFromNIC(String nic) {
    int year = 0;
    int dayOfYear = 0;

    try {
      if (nic.length == 10 && (nic.endsWith('V') || nic.endsWith('v'))) {
        year = int.parse(nic.substring(0, 2));
        dayOfYear = int.parse(nic.substring(2, 5));
        year += (year <= 24) ? 2000 : 1900;
      } else if (nic.length == 12) {
        year = int.parse(nic.substring(0, 4));
        dayOfYear = int.parse(nic.substring(4, 7));
      } else {
        return null;
      }

      if (dayOfYear > 500) dayOfYear -= 500;

      final dob = DateTime(year).add(Duration(days: dayOfYear - 1));
      return _formatDate(dob);
    } catch (_) {
      return null;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form saved successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Name with Initials', _initialsController),
              _buildTextField(
                'NIC',
                _nicController,
                onChanged: (value) {
                  final dob = _getDobFromNIC(value);
                  if (dob != null) {
                    _dobController.text = dob;
                  }
                },
              ),
              _buildTextField('Date of Birth', _dobController,
                  readOnly: true, onTap: _selectDateOfBirth),
              _buildTextField('Mobile No', _mobileNoController, isNumber: true),
              _buildTextField('Bill No', _billNoController),
              _buildTextField('Bill Date', _billDateController,
                  readOnly: true,
                  onTap: () => _selectDate(_billDateController)),
              _buildTextField('Bill Amount', _billAmountController,
                  isNumber: true),
              _buildTextField('Premium Value', _premiumController,
                  isNumber: true, readOnly: true),
              _buildTextField('Cover Value', _coverValueController,
                  isNumber: true, readOnly: true),
              _buildTextField('Valid From', _validFromController,
                  readOnly: true),
              _buildTextField('Valid To', _validToController, readOnly: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 173, 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool readOnly = false,
    bool enabled = true,
    VoidCallback? onTap,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        onChanged: onChanged,
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
