import 'package:flutter/material.dart';

class CovernoteListScreen extends StatefulWidget {
  const CovernoteListScreen({super.key});

  @override
  State<CovernoteListScreen> createState() => _nameState();
}

class _nameState extends State<CovernoteListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Covernote List Screen'),
      ),
      body: const Center(
        child: Text(
          'Covernote List Screen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
