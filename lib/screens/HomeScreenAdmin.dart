import 'package:coop_agent/screens/admin/BranchScreen.dart';
import 'package:coop_agent/screens/admin/CovernoteListScreenAdmin.dart';
import 'package:coop_agent/screens/admin/CreateCovernoteAdminScreen.dart';
import 'package:coop_agent/screens/admin/CreateUserScreen.dart';
import 'package:coop_agent/screens/admin/InsuranceClassScreen.dart';
import 'package:coop_agent/screens/admin/InsuranceProductScreen.dart';
import 'package:coop_agent/screens/admin/UserListScreen.dart';
import 'package:coop_agent/screens/admin/VehicleMakeScreen.dart';
import 'package:coop_agent/screens/admin/VehicleModelScreen.dart';
import 'package:coop_agent/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homescreenadmin extends StatefulWidget {
  const Homescreenadmin({super.key});

  @override
  State<Homescreenadmin> createState() => _HomescreenadminState();
}

class _HomescreenadminState extends State<Homescreenadmin> {
  Widget _selectedScreen = const CovernotelistAdminScreen();
  String _screenTitle = "Covernote List"; // ✅ Default title

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
              onTap: () => _setScreen(
                  const Createcovernoteadminscreen(), "Create Covernote"),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Covernote List'),
              onTap: () => _setScreen(
                  const CovernotelistAdminScreen(), "Covernote List"),
            ),
            ListTile(
              leading: const Icon(Icons.car_crash_rounded),
              title: const Text('Vehicle Make'),
              onTap: () =>
                  _setScreen(const VehicleMakeScreen(), "Vehicle Make"),
            ),
            ListTile(
              leading: const Icon(Icons.mode_edit_outline_outlined),
              title: const Text('Vehicle Model'),
              onTap: () =>
                  _setScreen(const VehicleModelScreen(), "Vehicle Model"),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined_sharp),
              title: const Text('Insurance Class'),
              onTap: () =>
                  _setScreen(const InsuranceClassScreen(), "Insurance Class"),
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart),
              title: const Text('Insurance Product'),
              onTap: () => _setScreen(
                  const InsuranceProductScreen(), "Insurance Product"),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('Branch'),
              onTap: () => _setScreen(const BranchScreen(), "Branch"),
            ),
            ListTile(
              leading: const Icon(Icons.verified_user_sharp),
              title: const Text('User List'),
              onTap: () => _setScreen(const UserListScreen(), "User List"),
            ),
            ListTile(
              leading: const Icon(Icons.supervised_user_circle),
              title: const Text('Create User'),
              onTap: () => _setScreen(const CreateUserScreen(), "Create User"),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _logout(context),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }
}
