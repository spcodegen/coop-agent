import 'package:coop_agent/screens/HomeScreen.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/loginback.png", // Replace with your image path
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          //Login Screen Content
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 40,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 75,
                    ),
                    Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.cover,
                      width: 100,
                    ),
                    const Text(
                      "LOGIN",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _userNameController,
                              labelText: 'User Name',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter User Name';
                                }
                                return null;
                              },
                              isNumeric: true,
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            _buildTextField(
                              controller: _passwordController,
                              obscureText: true,
                              labelText: 'Password',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Password';
                                }
                                return null;
                              },
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
                                onPressed: () {
                                  // Navigate to Home Page and allow back navigation
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Homescreen()),
                                  );
                                },
                                child: const Text(
                                  'Login Now',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    //fontFamily: 'Georgia',
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
    bool isNumeric = false,
    bool obscureText = false,
  }) {
    return SizedBox(
      width: 400,
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
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
