import 'package:flutter/material.dart';

class CreateCovernoteScreen extends StatefulWidget {
  const CreateCovernoteScreen({super.key});

  @override
  State<CreateCovernoteScreen> createState() => _CreateCovernoteScreenState();
}

class _CreateCovernoteScreenState extends State<CreateCovernoteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _passportController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();
  final TextEditingController _chassisNoController = TextEditingController();
  final TextEditingController _engineNoController = TextEditingController();
  final TextEditingController _totalPremiumController = TextEditingController();

  // Dropdown selections
  String? _selectedReason;
  String? _selectedTitle;
  String? _selectedVehicleMake;
  String? _selectedVehicleModel;
  String? _selectedInsuranceClass;
  String? _selectedInsuranceProduct;

  // Date Pickers
  DateTime? _validFrom;
  DateTime? _validTo;

  // Payment Method (Radio Button)
  String _selectedPaymentMethod = 'Cash';

  // Dropdown options
  final List<String> _title = ['Mr', 'Mrs', 'Miss'];
  final List<String> _reasons = ['New Registration', 'Renewal', 'Transfer'];
  final List<String> _vehicleMakes = ['Toyota', 'Honda', 'Nissan'];
  final List<String> _vehicleModels = ['Model A', 'Model B', 'Model C'];
  final List<String> _insuranceClasses = ['Private', 'Commercial'];
  final List<String> _insuranceProducts = ['Full Coverage', 'Third Party'];

  // Function to select date
  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginback.png', // Replace with your image
              fit: BoxFit.cover,
            ),
          ),
          // Form with Semi-Transparent Background
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), // Adjust transparency
                borderRadius: BorderRadius.circular(10),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dropdownField('Covernote Reason', _selectedReason, _reasons,
                        (value) => setState(() => _selectedReason = value)),
                    textField('NIC No', _nicController),
                    textField('Passport No', _passportController),
                    dropdownField(
                        'Title',
                        _selectedTitle,
                        _title,
                        (value) =>
                            setState(() => _selectedVehicleMake = value)),
                    textField('Full Name', _fullNameController),
                    textField('Address', _addressController),
                    textField('Telephone No', _telephoneController),
                    textField('Mobile No', _mobileController),
                    textField('Vehicle No', _vehicleNoController),
                    textField('Chassis No', _chassisNoController),
                    dropdownField(
                        'Vehicle Make',
                        _selectedVehicleMake,
                        _vehicleMakes,
                        (value) =>
                            setState(() => _selectedVehicleMake = value)),
                    dropdownField(
                        'Vehicle Model',
                        _selectedVehicleModel,
                        _vehicleModels,
                        (value) =>
                            setState(() => _selectedVehicleModel = value)),
                    textField('Engine No', _engineNoController),
                    dropdownField(
                        'Insurance Class',
                        _selectedInsuranceClass,
                        _insuranceClasses,
                        (value) =>
                            setState(() => _selectedInsuranceClass = value)),
                    dropdownField(
                        'Insurance Product',
                        _selectedInsuranceProduct,
                        _insuranceProducts,
                        (value) =>
                            setState(() => _selectedInsuranceProduct = value)),
                    textField('Total Premium', _totalPremiumController,
                        isNumber: true),
                    datePickerField('Valid From', _validFrom,
                        () => _selectDate(context, true)),
                    datePickerField('Valid To', _validTo,
                        () => _selectDate(context, false)),
                    const SizedBox(height: 10),
                    const Text('Payment Method',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        radioButton('Cash'),
                        radioButton('Card'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Form Submitted')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown Widget
  Widget dropdownField(String label, String? value, List<String> items,
      Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  // Text Field Widget
  Widget textField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  // Date Picker Widget
  Widget datePickerField(
      String label, DateTime? selectedDate, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration:
              InputDecoration(labelText: label, border: OutlineInputBorder()),
          child: Text(selectedDate != null
              ? selectedDate.toLocal().toString().split(' ')[0]
              : 'Select Date'),
        ),
      ),
    );
  }

  // Radio Button Widget
  Widget radioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedPaymentMethod,
          onChanged: (val) => setState(() => _selectedPaymentMethod = val!),
        ),
        Text(value),
      ],
    );
  }
}
