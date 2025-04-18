import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';
import 'main.dart';

class SettingsPage extends StatelessWidget {
  final User user;
  const SettingsPage({super.key, required this.user, required void Function(int index) onFeatureTap});


  void logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFE8F0FB), // Lightest blue
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 65),
              Expanded(
                child: ListView(
                  children: [
                    _buildSectionTitle('Account Security'),
                    _buildSettingsItem(
                      title: 'Change PIN',
                      icon: CupertinoIcons.padlock_solid,
                      iconColor: const Color(0xFF303F9F), // Dark indigo
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(builder: (context) => ChangePinPage(user: user)),
                        );
                      },
                    ),


                    const Divider(color: Color(0xFFB0BEC5)), // Light blue
                    _buildSectionTitle('Others'),
                    _buildSettingsItem(
                      title: 'Log Out',
                      icon: CupertinoIcons.power,
                      iconColor: Colors.red.shade900, // Very dark red for emphasis
                      onTap: () {
                        logout(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color:  Color(0xFF1A237E), // Darker blue
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required String title,
    required IconData icon,
    Color? iconColor,
    required Function onTap,
  }) {
    return CupertinoListTile(
      leading: Icon(
        icon,
        color: iconColor ?? CupertinoColors.destructiveRed,
        size: 28,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          color: Color(0xFF424242), // Dark gray text
        ),
      ),
      trailing: const Icon(CupertinoIcons.chevron_forward, color: Color(0xFF757575)), // Gray chevron
      onTap: () => onTap(),
    );
  }}
class ChangePinPage extends StatefulWidget {
  final User user;
  const ChangePinPage({super.key, required this.user});

  @override
  _ChangePinPageState createState() => _ChangePinPageState();
}

class _ChangePinPageState extends State<ChangePinPage> {
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> initiatePinChange() async {
    final accountId = widget.user.id;

    print('Initiating PIN change for accountId: $accountId');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://quickcart.icu/app/send_otp.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'accountId': accountId}),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed response data: $data');

        if (data['success'] != null) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => VerifyOtpPage(accountId: accountId.toString()),
            ),
          );
        } else {
          _showMessage(data['error'] ?? 'Failed to send OTP.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _isLoading = false;
      });
      _showMessage('Something went wrong. Please check your connection.');
    }
  }
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Very light blue
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE8F0FB), // Lightest blue
        border: Border(bottom: BorderSide(color: Color(0xFFB0BEC5))), // Light blue border
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.back, color:  Color(0xFF1A237E)), // Darker blue back arrow
              SizedBox(width: 6),

            ],
          ),
        ),
        middle: const Text(
          'Change PIN',
          style: TextStyle(fontWeight: FontWeight.bold, color:  Color(0xFF1A237E)), // Darker blue title
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.2), // Lighter blue shadow
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_message != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isSuccess ?  Color(0xFFE0F7FA) :  Color(0xFFFDE0DC), // Light blue for success, light red for error
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isSuccess ?  Color(0xFF81D4FA) :  Color(0xFFFBCEDD), // Lighter blue/red border
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSuccess ? Icons.check_circle : Icons.error_outline,
                              color: _isSuccess ?  Color(0xFF0091EA) :  Color(0xFFE57373), // Medium blue/red icon
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _message!,
                                style: TextStyle(
                                    color: _isSuccess ?  Color(0xFF00869e) :  Color(0xFFd32f2f), // Darker blue/red text
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Text(
                      "To change your PIN, we'll send a One-Time Password (OTP) to your registered email address.",
                      style: TextStyle(
                        color:  Color(0xFF1A237E), // Darker blue text
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    CupertinoButton(
                      onPressed: initiatePinChange,
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFF448AFF), // Blue button
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                        'Send OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }

}


class VerifyOtpPage extends StatefulWidget {
  final String accountId;

  const VerifyOtpPage({super.key, required this.accountId});

  @override
  _VerifyOtpPageState createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;
  bool _obscurePin = true;


  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> verifyOtpAndChangePin() async {
    final otp = _otpController.text.trim();
    final newPin = _newPinController.text.trim();

    if (otp.isEmpty || newPin.isEmpty) {
      _showMessage('Please enter both OTP and new PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://quickcart.icu/app/change_pin.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'accountId': widget.accountId,
          'otp': otp,
          'newPin': newPin,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != null) {
          _showMessage('PIN changed successfully!', success: true);
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
            );
          });
        } else {
          _showMessage(data['error'] ?? 'Failed to change PIN.');
        }
      } else {
        _showMessage('Server error. Please try again later.');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Error occurred: $error');
      _showMessage('An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Very light blue
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFFE8F0FB), // Lightest blue navigation bar
        border: Border(bottom: BorderSide(color: Color(0xFFB0BEC5))), // Light blue border
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.left_chevron, color:  Color(0xFF1A237E)), // Darker blue back arrow
              SizedBox(width: 6),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 17,
                  color:  Color(0xFF1A237E), // Darker blue back text
                ),
              ),
            ],
          ),
        ),
        middle: const Text(
          'Secure Your PIN',
          style: TextStyle(fontWeight: FontWeight.bold, color:  Color(0xFF1A237E)), // Darker blue title
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200.withOpacity(0.3), // Lighter blue shadow
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enter OTP",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:  Color(0xFF1A237E), // Darker blue label
                      ),
                    ),
                    const SizedBox(height: 10),
                    CupertinoTextField(
                      controller: _otpController,
                      placeholder: '6-Digit OTP',
                      keyboardType: TextInputType.number,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F8FF), // Light blue background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color:  Color(0xFFB0BEC5).withOpacity(0.5)), // Light blue border
                      ),
                      style: const TextStyle(color: Color(0xFF424242)),
                      placeholderStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "New PIN",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color:  Color(0xFF1A237E), // Darker blue label
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        CupertinoTextField(
                          controller: _newPinController,
                          placeholder: 'Enter 4-Digit PIN',
                          keyboardType: TextInputType.number,
                          obscureText: _obscurePin,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F8FF), // Light blue background
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color:  Color(0xFFB0BEC5).withOpacity(0.5)), // Light blue border
                          ),
                          style: const TextStyle(color: Color(0xFF424242)),
                          placeholderStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                              });
                            },
                            child: Icon(
                              _obscurePin ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill,
                              color: const Color(0xFF757575),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    CupertinoButton(
                      onPressed: _isLoading ? null : verifyOtpAndChangePin,
                      borderRadius: BorderRadius.circular(25),
                      color: const Color(0xFF448AFF), // Blue button
                      child: _isLoading
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text(
                        'Change PIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isSuccess ?  Color(0xFFE0F7FA) :  Color(0xFFFDE0DC), // Light blue for success, light red for error
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isSuccess ?  Color(0xFF81D4FA) :  Color(0xFFFBCEDD), // Lighter blue/red border
                            ),
                          ),
                          child: Text(
                            _message!,
                            style: TextStyle(
                                color: _isSuccess ?  Color(0xFF00869e) :  Color(0xFFd32f2f), // Darker blue/red text
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

