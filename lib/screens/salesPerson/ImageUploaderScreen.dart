import 'package:coop_agent/screens/salesPerson/imageUploaderCategory/ClaimPhotosScreen.dart';
import 'package:coop_agent/screens/salesPerson/imageUploaderCategory/MotorUwScreen.dart';
import 'package:coop_agent/screens/salesPerson/imageUploaderCategory/NonMotorClaimScreen.dart';
import 'package:coop_agent/screens/salesPerson/imageUploaderCategory/NonMotorUwScreen.dart';
import 'package:coop_agent/screens/salesPerson/imageUploaderCategory/SalvagePhotosScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: Imageuploaderscreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Imageuploaderscreen extends StatefulWidget {
  const Imageuploaderscreen({super.key});

  @override
  State<Imageuploaderscreen> createState() => _ImageuploaderscreenState();
}

class _ImageuploaderscreenState extends State<Imageuploaderscreen> {
  final List<Map<String, dynamic>> _photoCategories = [
    {"icon": Icons.camera_alt, "label": "Claim Photos"},
    {"icon": Icons.directions_car, "label": "Motor UW Photos"},
    {"icon": Icons.photo, "label": "Non-Motor Claim Photos"},
    {"icon": Icons.motorcycle, "label": "Non-Motor UW Photos"},
    {"icon": Icons.settings_backup_restore, "label": "Salvage Photos"},
  ];

  void navigateToScreen(String label) {
    Widget screen;

    switch (label) {
      case 'Claim Photos':
        screen = const ClaimPhotoScreen();
        break;
      case 'Motor UW Photos':
        screen = const MotorUwPhotosScreen();
        break;
      case 'Non-Motor Claim Photos':
        screen = const NonMotorClaimScreen();
        break;
      case 'Non-Motor UW Photos':
        screen = const NonMotorUwScreen();
        break;
      case 'Salvage Photos':
        screen = const SalvagePhotosScreen();
        break;
      default:
        return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _photoCategories.map((item) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () => navigateToScreen(item['label']),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item['icon'], size: 48, color: Colors.blue),
                          const SizedBox(height: 10),
                          Text(
                            item['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
