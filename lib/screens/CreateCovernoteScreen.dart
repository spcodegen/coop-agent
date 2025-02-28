import 'package:flutter/material.dart';

class CreateCovernoteScreen extends StatefulWidget {
  const CreateCovernoteScreen({super.key});

  @override
  State<CreateCovernoteScreen> createState() => _nameState();
}

class _nameState extends State<CreateCovernoteScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Create Covernote Screen',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
