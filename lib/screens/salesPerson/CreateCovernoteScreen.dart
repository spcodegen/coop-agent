import 'dart:convert';

import 'package:coop_agent/services/config.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  final TextEditingController _businessRegisterNoController =
      TextEditingController();
  final TextEditingController _vatRegisterNoController =
      TextEditingController();
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
  String? globalCoverNoteNo;

  // Date Pickers
  DateTime? _validFrom;
  DateTime? _validTo;

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
  //multiple attachment document
  final List<File> _idDocImages = [];
  final List<File> _brDocImages = [];
  final List<File> _crImages = [];

  //boolean for dropdown disable
  bool _isCoverLimitDisabled = false;

  @override
  void initState() {
    super.initState();
    _fetchVehicleMakes(); // Load vehicle makes from API
  }

  // Function to pick a file
  Future<void> _pickFiles(bool isIdDoc) async {
    final List<XFile>? pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      for (XFile file in pickedFiles) {
        final imageFile = File(file.path);
        final fileSize = imageFile.lengthSync(); // in bytes

        if (fileSize > 2 * 1024 * 1024) {
          // 2 MB = 2 * 1024 * 1024 bytes
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('This document exceeds maximum permitted size!'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Stop further processing if any file is too large
        }
      }

      setState(() {
        if (isIdDoc) {
          _idDocImages.addAll(pickedFiles.map((file) => File(file.path)));
        } else {
          _brDocImages.addAll(pickedFiles.map((file) => File(file.path)));
        }
      });
    }
  }

  void _removeFile(bool isIdDoc, int index) {
    setState(() {
      if (isIdDoc) {
        _idDocImages.removeAt(index);
      } else {
        _brDocImages.removeAt(index);
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
      for (XFile file in pickedFiles) {
        final imageFile = File(file.path);
        final fileSize = imageFile.lengthSync(); // Size in bytes

        if (fileSize > 2 * 1024 * 1024) {
          // 2 MB = 2 * 1024 * 1024 bytes
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This document exceeds maximum permitted size!'),
              backgroundColor: Colors.red,
            ),
          );
          return; // Stop processing if any file is too large
        }
      }

      setState(() {
        _crImages.addAll(pickedFiles.map((file) => File(file.path)));
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

  // Fetch Customer Details by Passport No
  Future<void> _fetchCustomerDetailsByPassport(String passportNo) async {
    final String apiUrl =
        '${AppConfig.baseURL}/customer/getByPassportNo/$passportNo';

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
        final data = json.decode(response.body);

        setState(() {
          _nicController.text = data['nicNo'] ?? '';
          _fullNameController.text = data['fullName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _telephoneController.text = data['telephoneNo'] ?? '';
          _mobileController.text = data['mobileNo'] ?? '';
          _selectedTitle = data['title'] ?? null;
        });
      } else {
        print('Failed to fetch: ${response.statusCode}');
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
        "${AppConfig.baseURL}/insurance_product/getByVehicleType/$_selectedVehicleType";
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
        "address":
            _addressController.text.isNotEmpty ? _addressController.text : "",
        "customerType": _selectedCustomerType,
        "fullName":
            _fullNameController.text.isNotEmpty ? _fullNameController.text : "",
        "mobileNo":
            _mobileController.text.isNotEmpty ? _mobileController.text : "",
        "nicNo": _nicController.text.isNotEmpty ? _nicController.text : "",
        "passportNo":
            _passportController.text.isNotEmpty ? _passportController.text : "",
        "bizRegNo": _businessRegisterNoController.text.isNotEmpty
            ? _businessRegisterNoController.text
            : "",
        "idDocImage": false,
        "vatRegNo": _vatRegisterNoController.text.isNotEmpty
            ? _vatRegisterNoController.text
            : "",
        "telephoneNo": _telephoneController.text.isNotEmpty
            ? _telephoneController.text
            : "",
        "title": _selectedTitle ?? "",
        "isCreditAllowed": true,
        "creditLimit": 50000.00
      },
      "insuranceProductId": _insuranceProductId,
      "issuedDateTime": formatDateTime(DateTime.now()),
      "noOfValidDays": _validDaysController.text.isNotEmpty
          ? int.parse(_validDaysController.text)
          : 14,
      "paymentMethod": _selectedPaymentMethod ?? "CASH",
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
            : "",
        "crImage": false,
        "engineNo":
            _engineNoController.text.isNotEmpty ? _engineNoController.text : "",
        "vehicleMakeId": _selectedVehicleMakeId,
        "vehicleModelId": _selectedVehicleModelId,
        "vehicleNo": _vehicleNoController.text.isNotEmpty
            ? _vehicleNoController.text
            : ""
      }
    };

    try {
      // Convert the JSON object to a string
      String jsonString = jsonEncode(coverNoteDetailsRequest);

      // print("jsonString : " + jsonString);

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

      // Attach multiple ID Doc Images
      for (int i = 0; i < _idDocImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'idDocImageRequest', // Keep key consistent or update if API expects array format
          _idDocImages[i].path,
          filename: 'id_doc_$i.jpg',
        ));
      }

      // Attach multiple CR Images
      for (int i = 0; i < _brDocImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'idDocImageRequest', // Use correct key based on backend
          _brDocImages[i].path,
          filename: 'br_image_$i.jpg',
        ));
      }

      // Attach multiple Registration Documents
      for (int i = 0; i < _crImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'crImageRequest', // Change this key if your backend expects a specific name
          _crImages[i].path,
          filename: 'cr_image_$i.jpg',
        ));
      }

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      //print("Response Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (context.mounted) {
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseJson = jsonDecode(responseBody);
          final String? coverNoteNo = responseJson['coverNoteNo'];

          if (coverNoteNo != null && coverNoteNo.isNotEmpty) {
            globalCoverNoteNo = coverNoteNo; // ✅ Store globally
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Covernote Saved Successfully!")),
          );
          _clearForm(); // <- clear the form here
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

  void _clearForm() {
    // Clear controllers
    _nicController.clear();
    _passportController.clear();
    _businessRegisterNoController.clear();
    _vatRegisterNoController.clear();
    _fullNameController.clear();
    _addressController.clear();
    _telephoneController.clear();
    _mobileController.clear();
    _vehicleNoController.clear();
    _chassisNoController.clear();
    _engineNoController.clear();
    _totalPremiumController.clear();
    _validDaysController.text = "14";

    // Reset dropdown selections
    _selectedCustomerType = null;
    _selectedTitle = null;
    _selectedVehicleMake = null;
    _selectedVehicleMakeId = null;
    _selectedVehicleModel = null;
    _selectedVehicleModelId = null;
    _selectedVehicleType = null;
    _selectedInsuranceProduct = null;
    _selectedCoverLimit = 0;
    _selectedPaymentMethod = 'CASH';
    _selectedDocument = null;
    _selectedRegistrationDocument = null;

    // Clear file lists
    _idDocImages.clear();
    _brDocImages.clear();
    _crImages.clear();

    // Clear product lists
    _insuranceProducts.clear();
    _insuranceProductsList.clear();

    // Reset cover limit state
    _isCoverLimitDisabled = false;

    // Reset dates
    _validFrom = null;
    _validTo = null;

    // Refresh UI
    setState(() {});
  }

  Future<void> downloadAndOpenCoverNotePDF(
      BuildContext context, String coverNoteNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token not found. Please log in again.')),
        );
        return;
      }

      final url = Uri.parse(
        '${AppConfig.baseURL}/cover_note_details/openCoverNotePDF/$coverNoteNo',
      );

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/cover_note_$coverNoteNo.pdf';

        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch PDF. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String? validateNIC(String? value) {
    if (value == null || value.isEmpty) return 'Enter NIC No';

    final oldNicPattern = RegExp(r'^\d{9}[VXvx]$'); // e.g., 911042754V
    final newNicPattern = RegExp(r'^\d{12}$'); // e.g., 197419202757

    if (!oldNicPattern.hasMatch(value) && !newNicPattern.hasMatch(value)) {
      return 'NIC No must be 9 digits + V/X or 12 digits';
    }

    return null;
  }

  String? validatePassport(String? value) {
    if (value == null || value.isEmpty) return 'Enter Passport No';

    final regex = RegExp(r'^[NDST]{1}\d{7}$');

    if (!regex.hasMatch(value)) {
      return 'Passport No must start with N, D, S, or T and have 7 digits (e.g., N1234567)';
    }

    return null;
  }

  String? validatePhone(String? value, String label) {
    if (value == null || value.isEmpty) return 'Enter $label';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) return '$label must be 10 digits';
    return null;
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
                  validator: validateNIC,
                ),
                textFieldService(
                  'Passport No',
                  _passportController,
                  onChanged: (value) {
                    if (value.length > 3) {
                      _fetchCustomerDetailsByPassport(value);
                    }
                  },
                  validator: validatePassport,
                ),
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
                textField(
                    'Business Register No', _businessRegisterNoController),
                textField('VAT Register No', _vatRegisterNoController),
                textField('Company Name', _fullNameController),
              ],
              textField('Address', _addressController),
              textField(
                'Telephone No',
                _telephoneController,
                isNumber: true,
                validator: (value) => validatePhone(value, 'Telephone No'),
              ),
              textField(
                'Mobile No',
                _mobileController,
                isNumber: true,
                validator: (value) => validatePhone(value, 'Mobile No'),
              ),
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
                      child: Text('Attach BR Docs')),
                  if (_brDocImages.isNotEmpty)
                    buildFileList(_brDocImages, false),
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
                  child: const Text('Attach CR'),
                ),
                if (_crImages.isNotEmpty)
                  Column(
                    children: _crImages.map((file) {
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
                                  _crImages.remove(file);
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
                  radioButton('CASH'),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Existing Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveCovernote(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF00712D),
                      padding: EdgeInsets.symmetric(
                        horizontal: 52,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(width: 20), // Spacing between buttons
                  // New View PDF Button
                  ElevatedButton(
                    onPressed: () {
                      if (globalCoverNoteNo != null &&
                          globalCoverNoteNo!.isNotEmpty) {
                        downloadAndOpenCoverNotePDF(
                            context, globalCoverNoteNo!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "No Covernote found. Please save one first.")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003092), // Blue color
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
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
  Widget dropdownField(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged, {
    required bool isDisabled,
  }) {
    // Ensure the value exists exactly once in the items list
    final uniqueItems = items.toSet().toList(); // Remove duplicates
    final safeValue = uniqueItems.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: uniqueItems
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: isDisabled ? null : onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
        isExpanded: true,
      ),
    );
  }

  // Text Field Widget nomle
  Widget textField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    bool isDisabled = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration:
            InputDecoration(labelText: label, border: OutlineInputBorder()),
        validator: validator ??
            (value) => value == null || value.isEmpty ? 'Enter $label' : null,
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
  Widget textFieldService(
    String label,
    TextEditingController controller, {
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}
