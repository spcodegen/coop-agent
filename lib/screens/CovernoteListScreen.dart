import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CovernoteListScreen extends StatefulWidget {
  const CovernoteListScreen({super.key});

  @override
  State<CovernoteListScreen> createState() => _CovernoteListScreenState();
}

class _CovernoteListScreenState extends State<CovernoteListScreen> {
  final TextEditingController _covernoteController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  List<Map<String, dynamic>> _covernoteList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _branchDescription; // Store slcBranchDescription

  @override
  void initState() {
    super.initState();
    _loadBranchDescription();
  }

  // ✅ Fetch `slcBranchDescription` from SharedPreferences
  Future<void> _loadBranchDescription() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _branchDescription =
          prefs.getString('SlCbranchdescription') ?? "HEAD OFFICE";
    });

    _fetchCovernoteData(); // Fetch data after retrieving branch description
  }

  // ✅ Fetch Cover Note Data
  Future<void> _fetchCovernoteData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No token found. Please login again.";
        });
        return;
      }

      final url = Uri.parse(
          'http://172.21.112.149:8080/cover_note_details/getAllFrom30Days?branchName=$_branchDescription');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          _covernoteList = data.map((item) {
            return {
              'coverNoteNo': item['coverNoteNo'],
              'branchName': item['branch']['branchName'],
              'fullName': item['customer']['fullName'],
              'nicNo': item['customer']['nicNo'],
              'validFrom': item['validFrom'].toString().split('T')[0],
              'validTo': item['validTo'].toString().split('T')[0],
              'createdDate': item['createdDateTime'].toString().split('T')[0],
            };
          }).toList();
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load data. Please try again.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching data: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📌 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginback.png",
              fit: BoxFit.cover,
            ),
          ),

          // 📌 Content with semi-transparent overlay
          Positioned.fill(
            child: Container(
              color:
                  Colors.black.withOpacity(0.6), // Dark overlay for readability
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // ✅ Display Branch Description
                  // Text(
                  //   "Branch: $_branchDescription",
                  //   style: const TextStyle(
                  //     fontSize: 18,
                  //     color: Colors.white,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),

                  const SizedBox(height: 10),

                  // Search Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _covernoteController,
                          decoration: InputDecoration(
                            labelText: 'Covernote No',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _nicController,
                          decoration: InputDecoration(
                            labelText: 'NIC No',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _fetchCovernoteData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Loading Indicator
                  if (_isLoading) const CircularProgressIndicator(),

                  // Error Message
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),

                  // Data Table
                  if (!_isLoading && _covernoteList.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: DataTable(
                              border: TableBorder.all(color: Colors.grey),
                              columns: const [
                                DataColumn(label: Text('Cover Note No')),
                                DataColumn(label: Text('Branch')),
                                DataColumn(label: Text('Customer Name')),
                                DataColumn(label: Text('NIC')),
                                DataColumn(label: Text('Valid From')),
                                DataColumn(label: Text('Valid To')),
                                DataColumn(label: Text('Created Date')),
                                DataColumn(label: Text('Print')),
                              ],
                              rows: _covernoteList.map((covernote) {
                                return DataRow(cells: [
                                  DataCell(Text(
                                      covernote['coverNoteNo'].toString())),
                                  DataCell(
                                      Text(covernote['branchName'].toString())),
                                  DataCell(
                                      Text(covernote['fullName'].toString())),
                                  DataCell(Text(covernote['nicNo'].toString())),
                                  DataCell(
                                      Text(covernote['validFrom'].toString())),
                                  DataCell(
                                      Text(covernote['validTo'].toString())),
                                  DataCell(Text(
                                      covernote['createdDate'].toString())),
                                  DataCell(
                                    IconButton(
                                      icon: const Icon(Icons.print,
                                          color: Colors.blue),
                                      onPressed: () {
                                        // Implement print functionality
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
