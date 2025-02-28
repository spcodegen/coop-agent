import 'package:flutter/material.dart';

class CovernoteListScreen extends StatefulWidget {
  const CovernoteListScreen({super.key});

  @override
  State<CovernoteListScreen> createState() => _CovernoteListScreenState();
}

class _CovernoteListScreenState extends State<CovernoteListScreen> {
  final TextEditingController _covernoteController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Fields
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _covernoteController,
                    decoration: const InputDecoration(
                      labelText: 'Covernote No',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _nicController,
                    decoration: const InputDecoration(
                      labelText: 'NIC No',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Implement search logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400], // Green button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10), // Button padding
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Responsive Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis
                    .horizontal, // Allows horizontal scrolling on small screens
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Allows vertical scrolling
                  child: DataTable(
                    border: TableBorder.all(color: Colors.grey),
                    columns: const [
                      DataColumn(label: Text('Covernote No')),
                      DataColumn(label: Text('Branch')),
                      DataColumn(label: Text('Full Name')),
                      DataColumn(label: Text('NIC')),
                      DataColumn(label: Text('Valid To')),
                      DataColumn(label: Text('Create Date')),
                      DataColumn(label: Text('Print')),
                    ],
                    rows: List.generate(
                      8, // Change this based on real data
                      (index) => DataRow(
                        cells: [
                          DataCell(Text('CN-00$index')),
                          DataCell(Text('Branch $index')),
                          DataCell(Text('John Doe $index')),
                          DataCell(Text('NIC-1234$index')),
                          DataCell(Text('2025-12-31')),
                          DataCell(Text('2025-01-01')),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.print, color: Colors.blue),
                              onPressed: () {
                                // Print action
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
