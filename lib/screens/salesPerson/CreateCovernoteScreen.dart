import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController _validDaysController =
      TextEditingController(text: '14'); // Default value set to 14

  // Dropdown selections
  String? _selectedTitle;
  String? _selectedCustomerType;
  String? _selectedVehicleMake;
  String? _selectedVehicleModel;
  String? _selectedInsuranceProduct;
  String _selectedDocument = 'NIC';
  File? _selectedFile;

  String? _selectedRegistrationDocument;
  File? _selectedRegistrationFile;

  // Date Pickers
  DateTime? _validFrom;
  DateTime? _validTo;

  // Dropdown options
  final List<String> _title = ['Mr', 'Mrs', 'Miss'];
  final List<String> _customerTypes = ['Individual', 'Corporate'];
// Store vehicle makes as a list of maps to hold name and ID
  List<Map<String, dynamic>> _vehicleMakes = [];
  List<String> _vehicleModels = []; // Updated to be empty initially
  List<String> _insuranceProducts = []; // Empty initially
  List<Map<String, dynamic>> _insuranceProductsList = [];

  @override
  void initState() {
    super.initState();
    _fetchInsuranceProducts(); // Fetch data when screen loads
    _fetchVehicleMakes(); // Load vehicle makes from API
  }

  // Function to fetch active insurance products with token authentication
  Future<void> _fetchInsuranceProducts() async {
    const String apiUrl =
        'http://172.21.112.154:8080/insurance_product/getAllActive';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Error: No token found');
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          _insuranceProductsList = jsonResponse.cast<Map<String, dynamic>>();
          _insuranceProducts = _insuranceProductsList
              .map((product) => product['productName'].toString())
              .toList();
        });
      } else {
        throw Exception('Failed to load insurance products');
      }
    } catch (e) {
      print('Error fetching insurance products: $e');
    }
  }

  // Fetch Customer Details by NIC
  Future<void> _fetchCustomerDetails(String nicNo) async {
    final String apiUrl =
        'http://172.21.112.154:8080/customer/getByNicNo/$nicNo';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) return;

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _passportController.text = data['passportNo'] ?? '';
          _fullNameController.text = data['fullName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _telephoneController.text = data['telephoneNo'] ?? '';
          _mobileController.text = data['mobileNo'] ?? '';
          _selectedTitle = data['title'] ?? null;
        });
      }
    } catch (e) {
      print('Error fetching customer details: $e');
    }
  }

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

  // Function to pick a file
  Future<void> _pickFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

// New
  Future<void> _pickRegistrationFile() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedRegistrationFile = File(pickedFile.path);
      });
    }
  }

// Function to fetch vehicle makes
  Future<void> _fetchVehicleMakes() async {
    const String apiUrl =
        'http://172.21.112.154:8080/vehicle_make/getAllActive';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Error: No token found');
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          _vehicleMakes = jsonResponse.map((vehicle) {
            return {
              'id': vehicle['id'],
              'name': vehicle['name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load vehicle makes');
      }
    } catch (e) {
      print('Error fetching vehicle makes: $e');
    }
  }

// Function to fetch vehicle models based on selected make ID
  Future<void> _fetchVehicleModels(int vehicleMakeId) async {
    String apiUrl =
        'http://172.21.112.154:8080/vehicle_model/getByVehicleMakeId/$vehicleMakeId';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Error: No token found');
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        setState(() {
          _vehicleModels =
              jsonResponse.map((model) => model['name'].toString()).toList();
          _selectedVehicleModel = null; // Reset model selection
        });
      } else {
        throw Exception('Failed to load vehicle models');
      }
    } catch (e) {
      print('Error fetching vehicle models: $e');
    }
  }

  // Fetch Vehicle Details by Vehicle Number
  Future<void> _fetchVehicleDetails(String vehicleNo) async {
    final String apiUrl =
        'http://172.21.112.154:8080/vehicle_details/getByVehicleNo/$vehicleNo';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        print('Error: No token found');
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _vehicleNoController.text = data['vehicleNo'] ?? '';
          _chassisNoController.text = data['chassisNo'] ?? '';
          _engineNoController.text = data['engineNo'] ?? '';

          // Get vehicle make name
          _selectedVehicleMake = data['vehicleMake']['name'];

          // Get vehicle make ID and fetch models
          int vehicleMakeId = data['vehicleMake']['id'];
          _fetchVehicleModels(vehicleMakeId).then((_) {
            setState(() {
              // Set the selected model once models are loaded
              _selectedVehicleModel = data['vehicleModel']['name'];
            });
          });
        });
      } else {
        print('Failed to load vehicle details');
      }
    } catch (e) {
      print('Error fetching vehicle details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader('Customer Information'),
              dropdownField(
                'Customer Type',
                _selectedCustomerType,
                _customerTypes,
                (value) => setState(() => _selectedCustomerType = value),
              ),
              if (_selectedCustomerType == 'Individual') ...[
                textFieldService(
                  'NIC No',
                  _nicController,
                  onChanged: (value) {
                    if (value.length > 5) {
                      _fetchCustomerDetails(value);
                    }
                  },
                ),
                textField('Passport No', _passportController),
                dropdownField(
                  'Title',
                  _selectedTitle,
                  _title,
                  (value) => setState(() => _selectedTitle = value),
                ),
                textField('Full Name', _fullNameController),
              ] else if (_selectedCustomerType == 'Corporate') ...[
                textField('Business Register No', TextEditingController()),
                textField('VAT Register', TextEditingController()),
                textField('Company Name', TextEditingController()),
              ],
              textField('Address', _addressController),
              textField('Telephone No', _telephoneController),
              textField('Mobile No', _mobileController),
              if (_selectedCustomerType == 'Individual') ...[
                const Text(
                  'NIC/Passport Documents',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Row(
                  children: [
                    radioButtonNew('Available', 'Available'),
                    radioButtonNew('Not Available', 'Not Available'),
                  ],
                ),
                if (_selectedDocument == 'Available') ...[
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Attach NIC or Passport'),
                  ),
                  if (_selectedFile != null)
                    Text(
                        'File Selected: ${_selectedFile!.path.split('/').last}'),
                ],
              ] else if (_selectedCustomerType == 'Corporate') ...[
                const Text(
                  'Business Registration Documents',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Row(
                  children: [
                    radioButtonNew('Available', 'Available'),
                    radioButtonNew('Not Available', 'Not Available'),
                  ],
                ),
                if (_selectedDocument == 'Available') ...[
                  ElevatedButton(
                    onPressed: _pickFile,
                    child: const Text('Attach BR'),
                  ),
                  if (_selectedFile != null)
                    Text(
                        'File Selected: ${_selectedFile!.path.split('/').last}'),
                ],
              ],
              sectionHeader('Vehicle Information'),
              textFieldService(
                'Vehicle No',
                _vehicleNoController,
                onChanged: (value) {
                  if (value.length > 5) {
                    // Adjust condition as needed
                    _fetchVehicleDetails(value);
                  }
                },
              ),
              textField('Chassis No', _chassisNoController),
              dropdownField(
                'Vehicle Make',
                _selectedVehicleMake,
                _vehicleMakes.map((make) => make['name'] as String).toList(),
                (value) {
                  setState(() {
                    _selectedVehicleMake = value;
                    int selectedMakeId = _vehicleMakes.firstWhere(
                        (make) => make['name'] == value)['id']; // Get ID
                    _fetchVehicleModels(selectedMakeId); // Fetch models
                  });
                },
              ),
              dropdownField(
                'Vehicle Model',
                _selectedVehicleModel,
                _vehicleModels,
                (value) => setState(() => _selectedVehicleModel = value),
              ),
              textField('Engine No', _engineNoController),
              // Certificate of Registration Documents Section
              const Text(
                'Certificate of Registration Documents',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                children: [
                  radioButtonRegistration('Available', 'Available'),
                  radioButtonRegistration('Not Available', 'Not Available'),
                ],
              ),
              // Show attachment widget only if "Available" is selected
              if (_selectedRegistrationDocument == 'Available') ...[
                ElevatedButton(
                  onPressed: _pickRegistrationFile,
                  child: const Text('Attach Document'),
                ),
                if (_selectedRegistrationFile != null)
                  Text(
                      'File Selected: ${_selectedRegistrationFile!.path.split('/').last}'),
              ],
              sectionHeader('Insurance Details'),
              dropdownField(
                'Insurance Product',
                _selectedInsuranceProduct,
                _insuranceProducts,
                (value) {
                  setState(() {
                    _selectedInsuranceProduct = value;

                    // Find the selected product details
                    Map<String, dynamic>? selectedProduct =
                        _insuranceProductsList.firstWhere(
                      (product) => product['productName'] == value,
                      orElse: () => {},
                    );

                    // Update total premium with basicPremium value
                    if (selectedProduct.isNotEmpty) {
                      _totalPremiumController.text =
                          selectedProduct['basicPremium'].toString();
                    }
                  });
                },
              ),
              textField(
                'Total Premium',
                _totalPremiumController,
                isNumber: true,
                isDisabled: true,
              ),
              // No of Valid Days (Disabled & Default Value: 14)
              textField('No of Valid Days', _validDaysController,
                  isDisabled: true),
              datePickerField(
                'Valid From',
                _validFrom,
                () => _selectDate(context, true),
              ),
              datePickerField(
                'Valid To',
                _validTo,
                () => _selectDate(context, false),
              ),
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                children: [
                  radioButton('Card'),
                  radioButton('Credit'),
                ],
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form Submitted')),
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget radioButton(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedDocument,
          onChanged: (val) => setState(() => _selectedDocument = val!),
        ),
        Text(value),
      ],
    );
  }

// RadioButton Widget
  Widget radioButtonNew(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedDocument,
          onChanged: (val) => setState(() => _selectedDocument = val!),
        ),
        Text(label),
      ],
    );
  }

  Widget radioButtonRegistration(String label, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedRegistrationDocument,
          onChanged: (val) =>
              setState(() => _selectedRegistrationDocument = val!),
        ),
        Text(label),
      ],
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
        isExpanded: true,
      ),
    );
  }

  // Text Field Widget
  Widget textField(String label, TextEditingController controller,
      {bool isNumber = false, bool isDisabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        enabled: !isDisabled, // Disable input if isDisabled is true
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

  Widget textFieldService(String label, TextEditingController controller,
      {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget dropdownFieldService(String label, String? value, List<String> items,
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
        isExpanded: true,
      ),
    );
  }
}
