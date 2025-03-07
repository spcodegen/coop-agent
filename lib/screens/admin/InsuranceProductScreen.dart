import 'package:flutter/material.dart';

class InsuranceProductScreen extends StatefulWidget {
  const InsuranceProductScreen({super.key});

  @override
  State<InsuranceProductScreen> createState() => _InsuranceProductScreenState();
}

class _InsuranceProductScreenState extends State<InsuranceProductScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Insurance Product"),
      ),
    );
  }
}
