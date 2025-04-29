import 'package:coop_agent/screens/salesPerson/AccidentCover.dart';
import 'package:coop_agent/screens/salesPerson/CovernoteListScreen.dart';
import 'package:coop_agent/screens/salesPerson/CreateCovernoteScreen.dart';
import 'package:coop_agent/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Widget _selectedScreen = const CovernoteListScreen();
  String _screenTitle = "Covernote List"; // ✅ Default title

  bool _isCoopCityUser = false; // 👈 New variable

  @override
  void initState() {
    super.initState();
    _checkCoopCityUser();
  }

  Future<void> _checkCoopCityUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? coopCityUser = prefs.getString('coopCityUser');
    setState(() {
      _isCoopCityUser = (coopCityUser == "YES");
    });
  }

  void _setScreen(Widget screen, String title) {
    setState(() {
      _selectedScreen = screen;
      _screenTitle = title;
    });
    Navigator.pop(context); // Close the drawer after selection
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ✅ Clears token and user data
    print("🚀 User Logged Out!");

    // Navigate to LoginScreen and remove all previous screens
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_screenTitle)), // ✅ Dynamic title
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
              onTap: () =>
                  _setScreen(const CreateCovernoteScreen(), "Create Covernote"),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_outlined),
              title: const Text('Covernote List'),
              onTap: () =>
                  _setScreen(const CovernoteListScreen(), "Covernote List"),
            ),
            if (_isCoopCityUser) // ✅ Only show if user is CoopCityUser
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Personal Accident Cover'),
                onTap: () => _setScreen(
                    const AccidentCover(), "Personal Accident Cover"),
              ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }
}
