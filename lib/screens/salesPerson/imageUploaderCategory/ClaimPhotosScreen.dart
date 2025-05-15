import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ClaimPhotoScreen extends StatefulWidget {
  const ClaimPhotoScreen({super.key});

  @override
  State<ClaimPhotoScreen> createState() => _ClaimPhotoScreenState();
}

class _ClaimPhotoScreenState extends State<ClaimPhotoScreen> {
  final TextEditingController _claimNoController = TextEditingController();
  final TextEditingController _vehicleNoController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {"icon": Icons.camera_alt, "label": "Claim Photos"},
    {"icon": Icons.directions_car, "label": "Motor UW Photos"},
    {"icon": Icons.photo, "label": "Non-Motor Claim Photos"},
    {"icon": Icons.motorcycle, "label": "Non-Motor UW Photos"},
    {"icon": Icons.settings_backup_restore, "label": "Salvage Photos"},
  ];

  Map<String, List<File>> uploadedImages = {
    "Claim Photos": [],
    "Motor UW Photos": [],
    "Non-Motor Claim Photos": [],
    "Non-Motor UW Photos": [],
    "Salvage Photos": [],
  };

  Future<void> _pickImages(String category) async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final XFile? photo =
                    await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  setState(() {
                    uploadedImages[category]!.add(File(photo.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final List<XFile>? pickedFiles = await picker.pickMultiImage();
                if (pickedFiles != null && pickedFiles.isNotEmpty) {
                  setState(() {
                    uploadedImages[category]!
                        .addAll(pickedFiles.map((xfile) => File(xfile.path)));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(String category) {
    final images = uploadedImages[category]!;
    if (images.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((file) {
            return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Claim Photos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _claimNoController,
              decoration: const InputDecoration(
                labelText: "Claim No",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _vehicleNoController,
              decoration: const InputDecoration(
                labelText: "Vehicle Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Upload Images by Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._categories.map((cat) {
              return Card(
                child: ListTile(
                  leading: Icon(cat['icon']),
                  title: Text(cat['label']),
                  trailing: ElevatedButton(
                    onPressed: () => _pickImages(cat['label']),
                    child: const Text("Upload"),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            const Text("Uploaded Images",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...uploadedImages.keys.map((cat) => _buildImageList(cat)).toList(),
          ],
        ),
      ),
    );
  }
}
