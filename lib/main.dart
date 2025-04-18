import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'dashboard_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('savedAccounts');
  runApp(const BankingApp());
}

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.07;

    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1976D2), // Darker blue
              Color(0xFF2196F3), // Medium blue
              Color(0xFFBBDEFB), // Light blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) => CupertinoActionSheet(
                              title: const Text('Developers'),
                              message: const Text('This app was developed by:'),
                              actions: [
                                DeveloperTile(name: "Arpon Jolas"),
                                DeveloperTile(name: "Carreon Monica"),
                                DeveloperTile(name: "Gomez Dexter"),
                                DeveloperTile(name: "Gamboa Romel"),
                                DeveloperTile(name: "Larin Kayle"),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                child: const Text('Close'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                        child: const Icon(
                          CupertinoIcons.info,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Changed to rounded rectangle
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade900.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      CupertinoIcons.money_dollar, // Changed the icon to a dollar sign
                      size: 80,
                      color: Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Welcome Back",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Sign in to access your account",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Email Field
                  _buildInputField(
                    controller: _usernameController,
                    placeholder: "Email Address",
                    icon: CupertinoIcons.mail,
                  ),
                  const SizedBox(height: 25),

                  // Password Field
                  Stack(
                    children: [
                      _buildInputField(
                        controller: _passwordController,
                        placeholder: "PIN",
                        obscureText: _obscurePassword,
                        icon: CupertinoIcons.lock,
                      ),
                      Positioned(
                        right: 16,
                        top: 14,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? CupertinoIcons.eye
                                : CupertinoIcons.eye_slash,
                            color: const Color(0xFF1976D2),
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1565C0),
                          Color(0xFF1976D2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      borderRadius: BorderRadius.circular(12),
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                      onPressed: () async {
                        String username = _usernameController.text.trim();
                        String pin = _passwordController.text.trim();

                        if (username.isEmpty || pin.isEmpty) {
                          setState(() {
                            _errorMessage = "Please fill in all fields.";
                          });
                          return;
                        }

                        try {
                          var url = Uri.parse("https://quickcart.icu/app/login.php");
                          var response = await http.post(
                            url,
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode({"username": username, "pin": pin}),
                          );

                          print("Status Code: ${response.statusCode}");
                          print("Response Body: ${response.body}");

                          if (response.statusCode == 200) {
                            var jsonResponse = jsonDecode(response.body);

                            if (jsonResponse["status"] == "success") {
                              setState(() {
                                _successMessage = "Login Successful!";
                                _errorMessage = null;
                              });
                              User user = User.fromJson(jsonResponse["data"]);

                              Future.delayed(const Duration(seconds: 1), () {
                                Navigator.pushReplacement(
                                  context,
                                  CupertinoPageRoute(builder: (_) => DashboardScaffold(user: user)),
                                );
                              });
                            } else {
                              setState(() {
                                _errorMessage = jsonResponse["message"];
                                _successMessage = null;
                              });
                            }
                          } else {
                            setState(() {
                              _errorMessage = "Unexpected error occurred. Please try again.";
                              _successMessage = null;
                            });
                          }
                        } catch (e) {
                          print("Login Error: $e");
                          setState(() {
                            _errorMessage = "Could not connect to server. Please try again.";
                            _successMessage = null;
                          });
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Error & Success Messages
                  if (_errorMessage != null)
                    _buildMessageBox(_errorMessage!, Colors.red.shade100, Colors.red),
                  if (_successMessage != null)
                    _buildMessageBox(_successMessage!, Colors.green.shade100, Colors.green),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Enhanced Input Field
  Widget _buildInputField({
    required TextEditingController controller,
    required String placeholder,
    IconData? icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                icon,
                color: const Color(0xFF1976D2),
                size: 22,
              ),
            ),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              obscureText: obscureText,
              placeholder: placeholder,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              placeholderStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Message Box
  Widget _buildMessageBox(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            textColor == Colors.red ? CupertinoIcons.exclamationmark_circle : CupertinoIcons.check_mark_circled_solid,
            color: textColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperTile extends StatelessWidget {
  final String name;

  const DeveloperTile({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          color: CupertinoColors.activeBlue,
        ),
      ),
    );
  }
}