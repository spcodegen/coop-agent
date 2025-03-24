import 'dart:convert';
import 'dart:io';
import 'package:coop_agent/services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchCovernoteData();
  }

  Future<void> _fetchCovernoteData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? branchName = prefs.getString('slcBranchDescription');

      if (token == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = "No token found. Please login again.";
        });
        return;
      }

      String baseUrl = '${AppConfig.baseURL}/cover_note_details';
      String url;

      if (_covernoteController.text.isNotEmpty) {
        url =
            '$baseUrl/filterCoverNoteDetails?coverNoteNo=${_covernoteController.text}&branchName=$branchName';
      } else if (_nicController.text.isNotEmpty) {
        url =
            '$baseUrl/filterCoverNoteDetails?branchName=$branchName&nicNo=${_nicController.text}';
      } else {
        url = '$baseUrl/getAllFrom30Days?branchName=$branchName';
      }

      final response = await http.get(
        Uri.parse(url),
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

  Future<void> _downloadAndOpenPDF(String coverNoteNo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = "No token found. Please login again.";
      });
      return;
    }

    String pdfUrl =
        "${AppConfig.baseURL}/cover_note_details/openCoverNotePDF/$coverNoteNo";

    try {
      final response = await http.get(
        Uri.parse(pdfUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$coverNoteNo.pdf');
        await file.writeAsBytes(bytes);

        // Open the downloaded PDF
        await OpenFile.open(file.path);
      } else {
        setState(() {
          _errorMessage = "Failed to open PDF.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error opening PDF: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginback.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                  if (_isLoading) const CircularProgressIndicator(),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
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
                                        _downloadAndOpenPDF(
                                            covernote['coverNoteNo']);
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
