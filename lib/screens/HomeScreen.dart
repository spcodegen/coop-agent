import 'package:coop_agent/screens/CovernoteListScreen.dart';
import 'package:coop_agent/screens/CreateCovernoteScreen.dart';
import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  // Default selected screen
  Widget _selectedScreen = const CovernoteListScreen();

  void _setScreen(Widget screen) {
    setState(() {
      _selectedScreen = screen;
    });
    Navigator.pop(context); // Close the drawer after selection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Create Covernote'),
              onTap: () => _setScreen(const CreateCovernoteScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Covernote List'),
              onTap: () => _setScreen(const CovernoteListScreen()),
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }
}
