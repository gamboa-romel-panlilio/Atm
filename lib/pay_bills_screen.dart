import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import 'dashboard_screen.dart';

class BillsPaymentPage extends StatelessWidget {
  const BillsPaymentPage({super.key, required this.user, required void Function(int index) onFeatureTap});

  final User user;
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA), // Light Cyan
              Color(0xFFF0F4C3), // Light Yellow-Green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 65),
                const SizedBox(width: 50),
                const Text(
                  'Pay Bills',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E), // Dark Blue
                  ),
                ),
                const SizedBox(height: 20),

                // Billers List
                _buildBillerList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fixed method - now it's an instance method and can access `user`
  Widget _buildBillerList(BuildContext context) {
    final List<Map<String, dynamic>> billers = [
      {
        "name": "Electricity",
        "icon": CupertinoIcons.bolt_fill,
      },
      {
        "name": "Internet",
        "icon": CupertinoIcons.wifi,
      },
      {
        "name": "Water",
        "icon": CupertinoIcons.drop_fill,
        "tags": ["GCredit", "GGives"]
      },
      {
        "name": "Subscriptions",
        "icon": CupertinoIcons.phone,
      },
    ];

    return Column(
      children: billers.map((biller) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    BillPaymentFormPage(biller: biller['name'], user: user),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(biller['icon'], size: 28, color: const Color(0xFF304FFE)), // Indigo
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biller['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A237E), // Dark Blue
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const Icon(CupertinoIcons.chevron_forward, size: 20, color: Color(0xFF90A4AE)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}


class BillPaymentFormPage extends StatefulWidget {
  final String biller;
  final User user;

  const BillPaymentFormPage({
    super.key,
    required this.biller,
    required this.user,
  });

  @override
  _BillPaymentFormPageState createState() => _BillPaymentFormPageState();
}

class _BillPaymentFormPageState extends State<BillPaymentFormPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  Future<void> _submitPayment() async {
    final amount = _amountController.text.trim();
    final accNum = _accountNumberController.text.trim();

    if (amount.isEmpty || accNum.isEmpty) {
      _setMessage("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('https://quickcart.icu/app/pay_bills.php'),
        body: {
          'user_id': widget.user.id.toString(),
          'biller': widget.biller,
          'amount': amount,
          'account_number': accNum,
        },
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("Server response: ${response.body}");

          _setMessage("You have successfully paid ₱$amount for ${widget.biller}", success: true);
        } else {
          _setMessage("Payment failed: ${jsonResponse['message']}");
        }
      } else {
        _setMessage("Server error: ${response.statusCode}");
      }
    } catch (e) {
      _setMessage("Error: ${e.toString()}");
    }

    setState(() => _isLoading = false);
  }

  void _setMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    if (success) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // go back to biller list
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ReceiptPage(
              biller: widget.biller,
              amount: _amountController.text,
              accountNumber: _accountNumberController.text,
              user: widget.user,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF0F4C3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.back, color: Color(0xFF1A237E)),
                      SizedBox(width: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Biller: ${widget.biller}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),

                const SizedBox(height: 20),

                if (_message != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green[100] : Colors.red[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                                color: _isSuccess ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildTextField(
                  controller: _accountNumberController,
                  label: 'Account Number',
                  placeholder: 'Enter account number',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _amountController,
                  label: 'Amount (₱)',
                  placeholder: 'Enter amount',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 40),

                _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : GestureDetector(
                  onTap: _submitPayment,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3F51B5), // Indigo
                          Color(0xFF283593), // Dark Indigo
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pay Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required String placeholder,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1A237E), // Dark Blue
        ),
      ),
      const SizedBox(height: 6),
      CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        padding: const EdgeInsets.all(15),
        keyboardType: keyboardType,
        cursorColor: const Color(0xFF1A237E),
        style: const TextStyle(
          color: Color(0xFF283593), // Dark Indigo text
          fontSize: 16,
        ),
        placeholderStyle: const TextStyle(
          color: Color(0xFF9FA8DA), // Light Indigo placeholder
          fontSize: 15,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF), // Very light blue background
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
      ),
    ],
  );
}


// Only the updated ReceiptPage class for brevity
class ReceiptPage extends StatelessWidget {
  final String biller;
  final String amount;
  final String accountNumber;
  final User user;

  const ReceiptPage({
    super.key,
    required this.biller,
    required this.amount,
    required this.user,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    final double amountValue = double.tryParse(amount) ?? 0;
    final double totalAmount = amountValue + 15;
    final String formattedDate = DateTime.now().toString().substring(0, 16); // yyyy-MM-dd HH:mm

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Very light blue
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(CupertinoIcons.checkmark_seal_fill, size: 80, color: Color(0xFF1A237E)), // Dark Blue
              const SizedBox(height: 24),
              const Text(
                'Payment Successful',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)), // Dark Blue title
              ),
              const SizedBox(height: 30),
              _buildReceiptItem('Date:', formattedDate),
              _buildReceiptItem('Biller:', biller),
              _buildReceiptItem('Account No.:', accountNumber),
              _buildReceiptItem('Amount Paid:', '₱$amount', isBold: true),
              _buildReceiptItem('Transaction Fee:', '₱15.00'),
              const Divider(color: Color(0xFF9FA8DA), thickness: 1.5, height: 40), // Light Indigo divider
              _buildReceiptItem('Total Amount:', '₱${totalAmount.toStringAsFixed(2)}', isBold: true, color: Color(0xFF1A237E)), // Dark Blue total
              const SizedBox(height: 40),
              CupertinoButton(
                color: const Color(0xFF304FFE), // Indigo
                borderRadius: BorderRadius.circular(12),
                child: const Text('Go to Dashboard', style: TextStyle(fontSize: 18)),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement( // Use pushReplacement to avoid going back to the receipt
                    context,
                    CupertinoPageRoute(
                      builder: (context) => DashboardScaffold(user: user),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Thank you for your payment!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF9FA8DA)), // Light Indigo message
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptItem(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

}

