import 'package:flutter/material.dart';

class NonMotorClaimScreen extends StatefulWidget {
  const NonMotorClaimScreen({super.key});

  @override
  State<NonMotorClaimScreen> createState() => _NonMotorClaimScreenState();
}

class _NonMotorClaimScreenState extends State<NonMotorClaimScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Non-Motor Claim Photos')),
      body: const Center(child: Text('Non-Motor Claim Upload Page')),
    );
  }
}
