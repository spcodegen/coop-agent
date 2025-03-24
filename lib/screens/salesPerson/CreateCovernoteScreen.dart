import 'dart:convert';

import 'package:coop_agent/services/config.dart';
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
  String? _selectedPaymentMethod = "Credit";

  String? _selectedRegistrationDocument;
  File? _selectedRegistrationFile;

  // Date Pickers
  DateTime? _validFrom;
  DateTime? _validTo;
  File? _idDocImage;
  File? _crImage;

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
    const String apiUrl = "${AppConfig.baseURL}/insurance_product/getAllActive";

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
    final String apiUrl = '${AppConfig.baseURL}/customer/getByNicNo/$nicNo';

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
    DateTime initialDate = isFrom
        ? (_validFrom ?? DateTime.now()) // If no date is selected, use today
        : (_validTo ?? (_validFrom?.add(Duration(days: 14)) ?? DateTime.now()));

    DateTime firstDate = isFrom
        ? DateTime.now() // Valid from cannot be in the past
        : (_validFrom != null
            ? _validFrom!.add(Duration(days: 14))
            : DateTime.now());

    DateTime lastDate = DateTime(2100);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _validFrom = picked;
          _validTo =
              _validFrom!.add(const Duration(days: 14)); // Auto-set validTo
        }
      });
    }
  }

  // Function to pick a file
  Future<void> _pickFile(bool isIdDoc) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIdDoc) {
          _idDocImage = File(pickedFile.path);
        } else {
          _crImage = File(pickedFile.path);
        }
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
    const String apiUrl = '${AppConfig.baseURL}/vehicle_make/getAllActive';

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
        '${AppConfig.baseURL}/vehicle_model/getByVehicleMakeId/$vehicleMakeId';

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
        '${AppConfig.baseURL}/vehicle_details/getByVehicleNo/$vehicleNo';

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

  // Future<void> _submitForm() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   var url = Uri.parse("http://172.21.112.154:8080/cover_note_details/save");
  //   var request = http.MultipartRequest('POST', url);

  //   Map<String, dynamic> coverNoteDetails = {
  //     "branchName": "GAMPAHA",
  //     "coverNoteReason": "",
  //     "customer": {
  //       "address": _addressController.text,
  //       "customerType": "Individual",
  //       "fullName": _fullNameController.text,
  //       "mobileNo": _mobileController.text,
  //       "nicNo": _nicController.text,
  //       "passportNo": _passportController.text,
  //       "bizRegNo":"",
  //       "idDocImage": true,
  //       "telephoneNo": _telephoneController.text,
  //       "title": "Mr",
  //       "isCreditAllowed": true,
  //       "creditLimit": 50000
  //     },
  //     "insuranceProductId": 2,
  //     "issuedDateTime": DateTime.now().toIso8601String(),
  //     "noOfValidDays": 14,
  //     "paymentMethod": "Credit",
  //     "renewCount": 0,
  //     "sumInsured": 0,
  //     "totalPremium": double.tryParse(_totalPremiumController.text) ?? 0,
  //     "validFrom": _validFrom?.toIso8601String(),
  //     "validTo": _validTo?.toIso8601String(),
  //     "vehicleDetails": {
  //       "chassisNo": _chassisNoController.text,
  //       "crImage": true,
  //       "engineNo": _engineNoController.text,
  //       "vehicleMakeId": 1,
  //       "vehicleModelId": 3,
  //       "vehicleNo": _vehicleNoController.text
  //     }
  //   };

  //   request.fields['coverNoteDetailsRequest'] = jsonEncode(coverNoteDetails);

  //   if (_idDocImage != null) {
  //     request.files.add(await http.MultipartFile.fromPath(
  //         'idDocImageRequest', _idDocImage!.path));
  //   }
  //   if (_crImage != null) {
  //     request.files.add(
  //         await http.MultipartFile.fromPath('crImageRequest', _crImage!.path));
  //   }

  //   var response = await request.send();
  //   if (response.statusCode == 200) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Cover note saved successfully!')));
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Failed to save cover note.')));
  //   }
  // }

  // Retrieve token from SharedPreferences

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key according to your storage
  }

  // Future<void> _saveCovernote() async {
  //   String? token = await _getToken();

  //   if (token == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Token not found, please login again.")),
  //     );
  //     return;
  //   }

  //   Map<String, dynamic> coverNoteDetailsRequest = {
  //     "branchName": "GAMPAHA",
  //     "coverNoteReason": "",
  //     "customer": {
  //       "address": _addressController.text,
  //       "customerType": _selectedCustomerType,
  //       "fullName": _fullNameController.text,
  //       "mobileNo": _mobileController.text,
  //       "nicNo": _nicController.text,
  //       "passportNo": _passportController.text,
  //       "bizRegNo": "",
  //       "idDocImage": false,
  //       "vatRegNo": "",
  //       "telephoneNo": _telephoneController.text,
  //       "title": _selectedTitle,
  //       "isCreditAllowed": true,
  //       "creditLimit": 50000
  //     },
  //     "insuranceProductId": 2,
  //     "issuedDateTime": DateTime.now().toIso8601String(),
  //     "noOfValidDays": int.parse(_validDaysController.text),
  //     "paymentMethod": _selectedPaymentMethod,
  //     "renewCount": 0,
  //     "sumInsured": 0,
  //     "totalPremium": double.parse(_totalPremiumController.text),
  //     "validFrom": DateTime.now().toIso8601String(),
  //     "validTo": DateTime.now().add(Duration(days: 14)).toIso8601String(),
  //     "vehicleDetails": {
  //       "chassisNo": _chassisNoController.text,
  //       "crImage": false,
  //       "engineNo": _engineNoController.text,
  //       "vehicleMakeId": 1,
  //       "vehicleModelId": 3,
  //       "vehicleNo": _vehicleNoController.text
  //     }
  //   };

  //   String jsonString = jsonEncode(coverNoteDetailsRequest);
  //   print("Request JSON: $jsonString"); // Debugging

  //   try {
  //     var response = await http.post(
  //       Uri.parse("http://172.21.112.154:8080/cover_note_details/save"),
  //       headers: {
  //         "Content-Type": "application/json",
  //         "Authorization": "Bearer $token",
  //       },
  //       body: jsonString,
  //     );

  //     print("Response Status Code: ${response.statusCode}");
  //     print("Response Body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Covernote Saved Successfully!")),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to Save Covernote: ${response.body}")),
  //       );
  //     }
  //   } catch (error) {
  //     print("Error: $error");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: $error")),
  //     );
  //   }
  // }

  Future<void> _saveCovernote(BuildContext context) async {
    String? token = await _getToken();

    if (token == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Token not found, please login again.")),
        );
      }
      return;
    }

    // Constructing the JSON object (Ensuring correct types)
    Map<String, dynamic> coverNoteDetailsRequest = {
      "branchName": "GAMPAHA",
      "coverNoteReason": "",
      "customer": {
        "address": _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : "N/A",
        "customerType": _selectedCustomerType,
        "fullName": _fullNameController.text.trim().isNotEmpty
            ? _fullNameController.text.trim()
            : "N/A",
        "mobileNo": _mobileController.text.trim().isNotEmpty
            ? _mobileController.text.trim()
            : "0000000000",
        "nicNo": _nicController.text.trim().isNotEmpty
            ? _nicController.text.trim()
            : "N/A",
        "passportNo": _passportController.text.trim().isNotEmpty
            ? _passportController.text.trim()
            : "N/A",
        "bizRegNo": "",
        "idDocImage": false, // Boolean value remains boolean
        "vatRegNo": "",
        "telephoneNo": _telephoneController.text.trim().isNotEmpty
            ? _telephoneController.text.trim()
            : "N/A",
        "title": _selectedTitle,
        "isCreditAllowed": true, // Boolean value remains boolean
        "creditLimit": 50000 // Integer value remains integer
      },
      "insuranceProductId": 2, // Integer value remains integer
      "issuedDateTime": DateTime.now().toIso8601String(),
      "noOfValidDays": int.tryParse(_validDaysController.text.trim()) ?? 14,
      "paymentMethod": _selectedPaymentMethod,
      "renewCount": 0, // Integer value remains integer
      "sumInsured": 0.0, // Double value remains double
      "totalPremium":
          double.tryParse(_totalPremiumController.text.trim()) ?? 0.0,
      "validFrom": DateTime.now().toIso8601String(),
      "validTo": DateTime.now().add(Duration(days: 14)).toIso8601String(),
      "vehicleDetails": {
        "chassisNo": _chassisNoController.text.trim().isNotEmpty
            ? _chassisNoController.text.trim()
            : "N/A",
        "crImage": false, // Boolean value remains boolean
        "engineNo": _engineNoController.text.trim().isNotEmpty
            ? _engineNoController.text.trim()
            : "N/A",
        "vehicleMakeId": 1, // Integer value remains integer
        "vehicleModelId": 3, // Integer value remains integer
        "vehicleNo": _vehicleNoController.text.trim().isNotEmpty
            ? _vehicleNoController.text.trim()
            : "N/A"
      }
    };

    // Convert to JSON String
    String jsonString = jsonEncode(coverNoteDetailsRequest);
    print("Request JSON: $jsonString"); // Debugging

    try {
      var response = await http.post(
        Uri.parse("http://172.21.112.154:8080/cover_note_details/save"),
        headers: {
          "Content-Type":
              "application/x-www-form-urlencoded", // Change content type
          "Authorization": "Bearer $token",
        },
        body: jsonString, // Sending JSON as a String
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Covernote Saved Successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Failed to Save Covernote: ${response.body}")),
          );
        }
      }
    } catch (error) {
      print("Error: $error");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error")),
        );
      }
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
                  // ElevatedButton(
                  //   onPressed: _pickFile,
                  //   child: const Text('Attach NIC or Passport'),
                  // ),
                  ElevatedButton(
                      onPressed: () => _pickFile(true),
                      child: Text('Attach ID Doc')),
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
                  // ElevatedButton(
                  //   onPressed: _pickFile,
                  //   child: const Text('Attach BR'),
                  // ),
                  ElevatedButton(
                      onPressed: () => _pickFile(false),
                      child: Text('Attach CR Doc')),
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
                null, // Disable manual selection
                isDisabled: true, // Make it non-editable
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
                    _saveCovernote(context);
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
  Widget datePickerField(String label, DateTime? date, VoidCallback? onTap,
      {bool isDisabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
            text: date != null ? '${date.toLocal()}'.split(' ')[0] : ''),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: isDisabled ? null : Icon(Icons.calendar_today),
        ),
        onTap: isDisabled ? null : onTap,
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
