import 'package:flutter/material.dart';

class CovernotelistAdminScreen extends StatefulWidget {
  const CovernotelistAdminScreen({super.key});

  @override
  State<CovernotelistAdminScreen> createState() =>
      _CovernotelistAdminScreenState();
}

class _CovernotelistAdminScreenState extends State<CovernotelistAdminScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Covernote List"),
      ),
    );
  }
}
