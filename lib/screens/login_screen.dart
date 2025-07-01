import 'package:coop_agent/models/user_model.dart';
import 'package:coop_agent/services/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:coop_agent/screens/HomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final url = Uri.parse('${AppConfig.baseURL}/user/authenticate');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": _userNameController.text,
          "password": _passwordController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String token = data['token'];
        UserModel user = UserModel.fromJson(data['user']);

        if (token.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('user', jsonEncode(user.toJson()));
          await prefs.setString('slcBranchDescription',
              user.salesPersonDetails.slcBranchDescription);
          await prefs.setString(
              'coopCityUser', user.coopCityUser); // ✅ Save coopCityUser
          await prefs.setString(
              'coopSociety', user.salesPersonDetails.coopSociety ?? '');
          await prefs.setString(
              'coopCity', user.salesPersonDetails.coopCity ?? '');
          await prefs.setString('username', user.username);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homescreen()),
          );
        } else {
          setState(() {
            _errorMessage = "Invalid response from server";
          });
        }
      } else {
        setState(() {
          _errorMessage = "Invalid username or password";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to connect to server";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginback.png",
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 75),
                    Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                      width: 100,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text("version: 1.0.1"),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _userNameController,
                              labelText: 'User Name',
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter User Name'
                                  : null,
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              obscureText: true,
                              labelText: 'Password',
                              validator: (value) => value!.isEmpty
                                  ? 'Please enter Password'
                                  : null,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if (_errorMessage != null)
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(
                              height: 25,
                            ),
                            SizedBox(
                              width: 280,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: Colors.white60,
                                  elevation: 10,
                                  shadowColor:
                                      const Color.fromARGB(255, 6, 6, 6),
                                ),
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black)
                                    : const Text(
                                        'Login Now',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String? Function(String?) validator,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: 400,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(15),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
        validator: validator,
        obscureText: obscureText,
      ),
    );
  }
}
