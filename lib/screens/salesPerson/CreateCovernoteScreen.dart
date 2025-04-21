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
  String? _selectedInsuranceProduct;
  String? _selectedDocument;
  String? _selectedPaymentMethod;
  String? _selectedRegistrationDocument;
  String? _selectedVehicleType;

  // Date Pickers
  DateTime? _validFrom;
  DateTime? _validTo;

  //attachment document
  File? _idDocImage;
  File? _crImage;
  File? _selectedRegistrationFile;

  // Dropdown options
  final List<String> _title = ['MR', 'MRS', 'MISS'];
  final List<String> _customerTypes = ['Individual', 'Corporate'];
  final List<String> _vehicleTypes = [
    'CAR',
    'VAN',
    'MOTOR CYCLE',
    'THREE WHEELER',
    'BUS',
    'OTHER'
  ];
  // Store vehicle makes as a list of maps to hold name and ID
  List<Map<String, dynamic>> _vehicleMakes = [];
  List<String> _insuranceProducts = []; // Empty initially
  List<Map<String, dynamic>> _insuranceProductsList = [];
  int _selectedCoverLimit = 0; // Default selected value
  // Insurance Product Data
  double _basicPremium = 0;
  double _policyFee = 0;
  //Global veriable
  int? _selectedVehicleMakeId; // Store selected Make ID
  int? _selectedVehicleModelId; // Store selected Model ID
  int? _insuranceProductId;
  List<Map<String, dynamic>> _vehicleModelsList = []; // Store full model list
  List<String> _vehicleModels = []; // Store only names for dropdown
  String? _selectedVehicleModel; // Store selected model name
  //multi files list
  final List<File> _idDocImages = [];
  final List<File> _crImages = [];
  final List<File> _selectedRegistrationFiles = [];
  //boolean
  bool _isCoverLimitDisabled = false;

  @override
  void initState() {
    super.initState();
    //_fetchInsuranceProducts(); // Fetch data when screen loads
    _fetchVehicleMakes(); // Load vehicle makes from API
  }

  // Function to pick a file
  Future<void> _pickFiles(bool isIdDoc) async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        if (isIdDoc) {
          _idDocImages.addAll(pickedFiles.map((file) => File(file.path)));
        } else {
          _crImages.addAll(pickedFiles.map((file) => File(file.path)));
        }
      });
    }
  }

  void _removeFile(bool isIdDoc, int index) {
    setState(() {
      if (isIdDoc) {
        _idDocImages.removeAt(index);
      } else {
        _crImages.removeAt(index);
      }
    });
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

  // Pick Registration file
  Future<void> _pickRegistrationFiles() async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _selectedRegistrationFiles
            .addAll(pickedFiles.map((file) => File(file.path)));
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
          _vehicleModelsList = jsonResponse
              .cast<Map<String, dynamic>>(); // Store full response list
          _vehicleModels = _vehicleModelsList
              .map((model) => model['name'].toString())
              .toList(); // Store only names
          _selectedVehicleModel = null; // Reset selection
          _selectedVehicleModelId = null; // Reset stored model ID
        });
      } else {
        throw Exception('Failed to load vehicle models');
      }
    } catch (e) {
      print('Error fetching vehicle models: $e');
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

  // Retrieve token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key according to your storage
  }

  // Fetch Insurance Products
  Future<void> _fetchInsuranceProducts() async {
    if (_selectedVehicleType == null || _selectedVehicleType!.isEmpty) return;

    String apiUrl =
        "http://172.21.112.133:9011/insurance_product/getByVehicleType/$_selectedVehicleType";
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) return;

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
          _insuranceProductsList =
              jsonResponse.cast<Map<String, dynamic>>(); // Store full list
          _insuranceProducts = _insuranceProductsList
              .map((product) => product['productName'].toString())
              .toList(); // Store only names for dropdown
          _insuranceProductId = null; // Reset selected product ID
          _selectedInsuranceProduct = null; // Clear selection if any
        });
      }
    } catch (e) {
      print('Error fetching insurance products: $e');
    }
  }

  // Fetch Insurance Product Details
  Future<void> _fetchInsuranceProductDetails(String productName) async {
    String? token = await _getToken();
    if (token == null) return;
    try {
      var selectedProduct = _insuranceProductsList.firstWhere(
          (product) => product['productName'] == productName,
          orElse: () => {});
      if (selectedProduct.isEmpty) return;
      int productId = selectedProduct['id'];
      _insuranceProductId = productId; // Store globally
      var response = await http.get(
        Uri.parse("${AppConfig.baseURL}/insurance_product/getById/$productId"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (response.statusCode == 200) {
        var productData = jsonDecode(response.body);
        setState(() {
          _basicPremium = productData['basicPremium'] ?? 0;
          _policyFee = productData['policyFee'] ?? 0;
        });
        _calculatePremium();
      }
    } catch (e) {
      print("Error fetching product details: $e");
    }
  }

  // Calculate Premium
  Future<void> _calculatePremium() async {
    String? token = await _getToken();
    if (token == null) return;

    // Construct the URL with dynamic values
    String apiUrl = "${AppConfig.baseURL}/insurance_product/generatePremium/"
        "$_basicPremium/$_policyFee/$_selectedCoverLimit";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var premiumData =
            jsonDecode(response.body); // Assuming API returns a double
        setState(() {
          _totalPremiumController.text = premiumData.toString();
        });
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error calculating premium: $e");
    }
  }

  //Save covernote
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

    // Get branchName from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String branchName =
        prefs.getString('slcBranchDescription') ?? "Default Branch";

    // Construct the JSON object
    Map<String, dynamic> coverNoteDetailsRequest = {
      "branchName": branchName,
      "coverNoteReason": "",
      "customer": {
        "address": _addressController.text.isNotEmpty
            ? _addressController.text
            : "N/A",
        "customerType": _selectedCustomerType,
        "fullName": _fullNameController.text.isNotEmpty
            ? _fullNameController.text
            : "N/A",
        "mobileNo": _mobileController.text.isNotEmpty
            ? _mobileController.text
            : "0000000000",
        "nicNo": _nicController.text.isNotEmpty ? _nicController.text : "N/A",
        "passportNo": _passportController.text.isNotEmpty
            ? _passportController.text
            : "N/A",
        "bizRegNo": "",
        "idDocImage": false,
        "vatRegNo": "",
        "telephoneNo": _telephoneController.text.isNotEmpty
            ? _telephoneController.text
            : "N/A",
        "title": _selectedTitle,
        "isCreditAllowed": true,
        "creditLimit": 50000.00
      },
      "insuranceProductId": _insuranceProductId,
      "issuedDateTime": formatDateTime(DateTime.now()),
      "noOfValidDays": _validDaysController.text.isNotEmpty
          ? int.parse(_validDaysController.text)
          : 14,
      "paymentMethod": _selectedPaymentMethod,
      "renewCount": 0,
      "sumInsured": 0,
      "propertyDamageCoverLimit": _selectedCoverLimit,
      "totalPremium": _totalPremiumController.text.isNotEmpty
          ? double.parse(_totalPremiumController.text)
          : 0,
      "liabilityAmount": 50000.00,
      "validFrom": formatDateTime(_validFrom ?? DateTime.now()),
      "validTo":
          formatDateTime(_validTo ?? DateTime.now().add(Duration(days: 14))),
      "vehicleDetails": {
        "chassisNo": _chassisNoController.text.isNotEmpty
            ? _chassisNoController.text
            : "N/A",
        "crImage": false,
        "engineNo": _engineNoController.text.isNotEmpty
            ? _engineNoController.text
            : "N/A",
        "vehicleMakeId": _selectedVehicleMakeId,
        "vehicleModelId": _selectedVehicleModelId,
        "vehicleNo": _vehicleNoController.text.isNotEmpty
            ? _vehicleNoController.text
            : "N/A"
      }
    };

    try {
      // Convert the JSON object to a string
      String jsonString = jsonEncode(coverNoteDetailsRequest);

      //print("jsonString : " + jsonString);

      // Create Multipart Request
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${AppConfig.baseURL}/cover_note_details/save"),
      );

      // Add headers
      request.headers.addAll({
        "Authorization": "Bearer $token",
      });

      // Add JSON data as a form field
      request.fields["coverNoteDetailsRequest"] = jsonString;

      // Attach files if available
      if (_idDocImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'idDocImageRequest', // Key name for API
          _idDocImage!.path,
        ));
      }

      if (_crImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'idDocImageRequest', // Key name for API
          _crImage!.path,
        ));
      }

      if (_selectedRegistrationFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'crImageRequest', // Key name for API
          _selectedRegistrationFile!.path,
        ));
      }

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      //print("Response Status Code: ${response.statusCode}");
      //print("Response Body: $responseBody");

      if (context.mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Covernote Saved Successfully!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to Save Covernote: $responseBody")),
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
                (value) => setState(
                  () => _selectedCustomerType = value,
                ),
                isDisabled: false,
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
                  (value) => setState(
                    () => _selectedTitle = value,
                  ),
                  isDisabled: false,
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
                    onPressed: () => _pickFiles(true),
                    child: Text('Attach ID Docs'),
                  ),
                  if (_idDocImages.isNotEmpty)
                    buildFileList(_idDocImages, true),
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
                      onPressed: () => _pickFiles(false),
                      child: Text('Attach CR Doc')),
                  if (_crImages.isNotEmpty) buildFileList(_crImages, false),
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
                    _selectedVehicleMakeId = _vehicleMakes.firstWhere(
                      (make) => make['name'] == value,
                    )['id']; // Store Make ID
                    _fetchVehicleModels(
                        _selectedVehicleMakeId!); // Fetch vehicle models
                  });
                },
                isDisabled: false,
              ),
              dropdownField(
                'Vehicle Model',
                _selectedVehicleModel,
                _vehicleModels,
                (value) {
                  setState(() {
                    _selectedVehicleModel = value;
                    _selectedVehicleModelId = _vehicleModelsList.firstWhere(
                      (model) => model['name'] == value,
                    )['id']; // Store Model ID
                  });
                },
                isDisabled: false,
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
                  onPressed: _pickRegistrationFiles,
                  child: const Text('Attach Documents'),
                ),
                if (_selectedRegistrationFiles.isNotEmpty)
                  Column(
                    children: _selectedRegistrationFiles.map((file) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'File: ${file.path.split('/').last}',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 30, 0, 201),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Color.fromARGB(255, 202, 13, 0)),
                              onPressed: () {
                                setState(() {
                                  _selectedRegistrationFiles.remove(file);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
              sectionHeader('Insurance Details'),
              dropdownField(
                'Vehicle Type',
                _selectedVehicleType,
                _vehicleTypes,
                (value) {
                  setState(() {
                    _selectedVehicleType = value;
                    _fetchInsuranceProducts(); // Load insurance products based on vehicle type
                  });
                },
                isDisabled: false,
              ),
              dropdownField(
                'Insurance Product',
                _selectedInsuranceProduct,
                _insuranceProducts,
                (value) {
                  setState(() {
                    _selectedInsuranceProduct = value;

                    // Disable cover limit for specific products
                    if (value == "THIRD PARTY PRIVATE CAR" ||
                        value == "THIRD PARTY PRIVATE CAR (SPECIAL)") {
                      _isCoverLimitDisabled = true;
                      _selectedCoverLimit = 0;
                    } else {
                      _isCoverLimitDisabled = false;
                    }

                    _fetchInsuranceProductDetails(value!);
                    _insuranceProductId = _insuranceProductsList.firstWhere(
                      (product) => product['productName'] == value,
                    )['id']; // Get and store product ID
                  });
                },
                isDisabled: false,
              ),
              dropdownField(
                'Cover Limit',
                _selectedCoverLimit.toString(),
                ["0", "100000", "300000", "500000", "1000000", "2000000"],
                (value) {
                  setState(() {
                    _selectedCoverLimit =
                        int.parse(value!); // Update Cover Limit
                  });

                  _calculatePremium();
                },
                isDisabled: _isCoverLimitDisabled,
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
                  radioButton('CARD'),
                  radioButton('CASH'),
                ],
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveCovernote(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 129, 4)),
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

  //File widget
  Widget buildFileList(List<File> files, bool isIdDoc) {
    return Column(
      children: files.asMap().entries.map((entry) {
        int index = entry.key;
        File file = entry.value;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'File: ${file.path.split('/').last}',
                  style: TextStyle(
                    color: Color.fromARGB(255, 30, 0, 201),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon:
                    Icon(Icons.delete, color: Color.fromARGB(255, 202, 13, 0)),
                onPressed: () => _removeFile(isIdDoc, index),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Date Widget
  String formatDateTime(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  // SectionHeader Widget
  Widget sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  // RadioButton Widget
  Widget radioButton(String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _selectedPaymentMethod,
          onChanged: (String? newValue) {
            setState(() {
              _selectedPaymentMethod = newValue!;
            });
          },
        ),
        Text(value),
      ],
    );
  }

  // RadioButton New Widget
  Widget radioButtonNew(String label, String value) {
    return Row(
      children: [
        Radio(
          value: value,
          groupValue: _selectedDocument,
          onChanged: (String? newValue) {
            setState(() {
              _selectedDocument = newValue!;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  //Radio button widget
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
      Function(String?) onChanged,
      {required bool isDisabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: isDisabled ? null : onChanged, // Disable if needed
        validator: (value) => value == null ? 'Please select $label' : null,
        isExpanded: true,
      ),
    );
  }

  // Text Field Widget nomle
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

  //Service call textField widget
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
}
