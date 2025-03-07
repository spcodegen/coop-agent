import 'package:flutter/material.dart';

class VehicleModelScreen extends StatefulWidget {
  const VehicleModelScreen({super.key});

  @override
  State<VehicleModelScreen> createState() => _VehicleModelScreenState();
}

class _VehicleModelScreenState extends State<VehicleModelScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Vehicle Model"),
      ),
    );
  }
}
