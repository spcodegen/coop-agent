import 'dart:convert';
import 'dart:io';
import 'package:coop_agent/services/config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:coop_agent/screens/login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bool isVersionValid = await _checkApkVersion();

  runApp(MyApp(isVersionValid: isVersionValid));
}

Future<bool> _checkApkVersion() async {
  try {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    String apkVersionNumber = "$version+$buildNumber";
    final url = "${AppConfig.baseURL}/user/checkApkVersion/$version";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bool result = jsonDecode(response.body);
      return result;
    } else {
      print("API error: ${response.statusCode}");
      return true; // Allow app to run if API fails
    }
  } catch (e) {
    print("Error checking version: $e");
    return true; // Allow app to run on error
  }
}

class MyApp extends StatelessWidget {
  final bool isVersionValid;

  const MyApp({super.key, required this.isVersionValid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isVersionValid ? const LoginScreen() : const UpdateScreen(),
    );
  }
}

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _isDownloading = false;
  double _progress = 0.0;

  final String apkUrl = "${AppConfig.baseURL}/user/downloadNewApk";

  Future<void> _downloadAndInstallApk() async {
    setState(() {
      _isDownloading = true;
    });

    const apkUrl =
        "${AppConfig.baseURL}/user/downloadNewApk"; // Replace with your actual APK URL

    try {
      // Step 1: Request permissions
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception("❌ Storage permission not granted");
        }
      }

      // Step 2: Get download directory
      final directory = Directory('/storage/emulated/0/Download');
      if (directory == null) throw Exception("❌ Cannot get download directory");

      final filePath = '${directory.path}/coop_agent.apk';
      final dio = Dio();

      // Step 3: Start download
      await dio.download(
        apkUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
            });
          }
        },
      );

      setState(() => _isDownloading = false);

      if (Theme.of(context).platform == TargetPlatform.android) {
        if (!await Permission.requestInstallPackages.isGranted) {
          await Permission.requestInstallPackages.request();
        }
      }

      await OpenFile.open(filePath);
    } catch (e) {
      setState(() => _isDownloading = false);
      debugPrint("❌ Download/install failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, size: 60, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  "Update Required",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "A newer version of this app is available. Please update to continue using all features.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                if (_isDownloading) ...[
                  const Text("Downloading..."),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _progress),
                ] else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      onPressed: _downloadAndInstallApk,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: const Text(
                        "Download & Install",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
