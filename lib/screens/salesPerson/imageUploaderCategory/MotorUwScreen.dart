import 'package:flutter/material.dart';

class MotorUwPhotosScreen extends StatefulWidget {
  const MotorUwPhotosScreen({super.key});

  @override
  State<MotorUwPhotosScreen> createState() => _MotorUwPhotosScreenState();
}

class _MotorUwPhotosScreenState extends State<MotorUwPhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motor UW Photos')),
      body: const Center(child: Text('Motor UW Upload Page')),
    );
  }
}
