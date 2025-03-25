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
  //attachment document
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
  // Define Cover Limit options
  final List<int> _coverLimitOptions = [0, 100000, 300000, 500000, 1000000];
  int _selectedCoverLimit = 0; // Default selected value

  @override
  void initState() {
    super.initState();
    _fetchInsuranceProducts(); // Fetch data when screen loads
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

  Future<void> fetchInsuranceProductAndCalculatePremium() async {
    String? token = await _getToken();

    if (token == null) {
      print("Token not found, please login again.");
      return;
    }

    try {
      // Step 1: Fetch Insurance Product Details
      var productResponse = await http.get(
        Uri.parse("http://172.21.112.149:9011/insurance_product/getById/5"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (productResponse.statusCode == 200) {
        var productData = jsonDecode(productResponse.body);
        int insuranceProductId = productData['id'];
        double basicPremium = productData['basicPremium'];
        double policyFee = productData['policyFee'];

        // Property Damage Cover Limit (Get from Dropdown)
        double propertyDamageCoverLimit =
            double.parse(_selectedCoverLimit as String) ?? 0;

        // Step 2: Calculate Premium
        var premiumResponse = await http.get(
          Uri.parse(
            "http://172.21.112.149:9011/insurance_product/generatePremium/"
            "$basicPremium/$policyFee/$propertyDamageCoverLimit",
          ),
          headers: {
            "Authorization": "Bearer $token",
          },
        );

        print(premiumResponse);

        if (premiumResponse.statusCode == 200) {
          var premiumData = jsonDecode(premiumResponse.body);
          double totalPremium = premiumData['totalPremium'];

          // Step 3: Update UI
          setState(() {
            _totalPremiumController.text = totalPremium.toString();
          });

          print("Total Premium Updated: $totalPremium");
        } else {
          print("Failed to fetch premium: ${premiumResponse.body}");
        }
      } else {
        print("Failed to fetch insurance product: ${productResponse.body}");
      }
    } catch (error) {
      print("Error: $error");
    }
  }

  // Retrieve token from SharedPreferences
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // Adjust key according to your storage
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
              // sectionHeader('Customer Information'),
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
                  onChanged: (value) {},
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
                if (_selectedDocument == 'Available') ...[
                  if (_selectedFile != null)
                    Text(
                        'File Selected: ${_selectedFile!.path.split('/').last}'),
                ],
              ] else if (_selectedCustomerType == 'Corporate') ...[
                const Text(
                  'Business Registration Documents',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_selectedDocument == 'Available') ...[
                  if (_selectedFile != null)
                    Text(
                        'File Selected: ${_selectedFile!.path.split('/').last}'),
                ],
              ],
              // sectionHeader('Vehicle Information'),
              textFieldService(
                'Vehicle No',
                _vehicleNoController,
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
              if (_selectedRegistrationDocument == 'Available') ...[
                if (_selectedRegistrationFile != null)
                  Text(
                      'File Selected: ${_selectedRegistrationFile!.path.split('/').last}'),
              ],
              // sectionHeader('Insurance Details'),
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
              // Inside your widget tree
              dropdownField(
                'Cover Limit',
                _selectedCoverLimit
                    .toString(), // Convert int to string for dropdown
                _coverLimitOptions
                    .map((limit) => limit.toString())
                    .toList(), // Convert list to string
                (value) {
                  setState(() {
                    fetchInsuranceProductAndCalculatePremium();
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
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
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
