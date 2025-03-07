import 'package:flutter/material.dart';

class InsuranceClassScreen extends StatefulWidget {
  const InsuranceClassScreen({super.key});

  @override
  State<InsuranceClassScreen> createState() => _InsuranceClassScreenState();
}

class _InsuranceClassScreenState extends State<InsuranceClassScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Insurance Class"),
      ),
    );
  }
}
