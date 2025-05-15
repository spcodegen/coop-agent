import 'package:flutter/material.dart';

class NonMotorUwScreen extends StatefulWidget {
  const NonMotorUwScreen({super.key});

  @override
  State<NonMotorUwScreen> createState() => _NonMotorUwScreenState();
}

class _NonMotorUwScreenState extends State<NonMotorUwScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Non-Motor UW Photos')),
      body: const Center(child: Text('Non-Motor UW Upload Page')),
    );
  }
}
