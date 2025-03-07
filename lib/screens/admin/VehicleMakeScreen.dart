import 'package:flutter/material.dart';

class VehicleMakeScreen extends StatefulWidget {
  const VehicleMakeScreen({super.key});

  @override
  State<VehicleMakeScreen> createState() => _VehicleMakeScreenState();
}

class _VehicleMakeScreenState extends State<VehicleMakeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Vehicle Make"),
      ),
    );
  }
}
