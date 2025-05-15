import 'package:flutter/material.dart';

class SalvagePhotosScreen extends StatefulWidget {
  const SalvagePhotosScreen({super.key});

  @override
  State<SalvagePhotosScreen> createState() => _SalvagePhotosScreenState();
}

class _SalvagePhotosScreenState extends State<SalvagePhotosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salvage Photos')),
      body: const Center(child: Text('Salvage Upload Page')),
    );
  }
}
