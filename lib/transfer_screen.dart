import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_model.dart';
import 'transfer_receipt.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TransferPage extends StatelessWidget {
  final User user;
  final void Function(int index) onFeatureTap;
  const TransferPage({super.key, required this.user, required this.onFeatureTap});
  @override
  Widget build(BuildContext context) {
    // Access the Hive box
    final Box savedAccountsBox = Hive.box('savedAccounts');
    // Retrieve saved accounts.  Handle nulls and ensure the data is in the expected format.
    final List<Map<String, String>> savedAccounts = savedAccountsBox.values
        .map<Map<String, String>>((value) {
      if (value is Map) {
        // Attempt to cast the Map to the expected type.
        try {
          return value.cast<String, String>();
        } catch (e) {
          // Log the error and return an empty map.  Crucial for debugging.
          print("Error casting Hive value: $e, value: $value");
          return {}; // Or handle as appropriate for your app.
        }
      } else {
        print("Unexpected value type in Hive: ${value.runtimeType}, value: $value");
        return {};
      }
    })
        .toList();


    final List<String> partnerBanks = [
      "China Bank", "BDO", "Landbank", "PNB"
    ];

    return CupertinoPageScaffold(
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)], // Blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 65),
                  const SizedBox(width: 50),
                  Text(
                    'Transfer Funds',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D2), // Dark blue color
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Saved Accounts Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saved Accounts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E88E5), // Blue color
                          ),
                        ),
                        const SizedBox(height: 12),
                        savedAccounts.isEmpty
                            ? const Text("No saved accounts yet.")
                            : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: savedAccounts.map((acc) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => TransferFormPage(
                                        bankOrAccount: acc['bank'] ?? 'Unknown Bank', //Provide Default
                                        accountId: user.id.toString(),
                                        initialName: acc['name'] ?? 'Unknown Name',  //Provide Default
                                        initialAccount: acc['account'] ?? 'Unknown Account', //Provide Default
                                        user: user,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 180,
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD), // Light blue background
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFF90CAF9)), // Light blue border
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        acc['name'] ?? 'No Name', // Provide a default
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1E88E5), // Dark blue text
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${acc['bank'] ?? ' '} • ${acc['account'] ?? ' '}", // Provide defaults
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14,
                                        ),
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

                  const SizedBox(height: 30),

                  // Partner Banks Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Partner Banks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E88E5), // Blue color
                          ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: partnerBanks.map((bank) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => TransferFormPage(
                                      bankOrAccount: bank,
                                      accountId: user.id.toString(),
                                      user: user,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 12,
                                ),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F8FF), // Very light blue
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFBBDEFB)), // Lighter blue border
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        bank,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1976D2), // Dark blue text
                                        ),
                                      ),
                                    ),
                                    const Icon(CupertinoIcons.chevron_forward,
                                        size: 20, color: Color(0xFF90CAF9)),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransferFormPage extends StatefulWidget {
  final String bankOrAccount;
  final String accountId;
  final String? initialName;
  final String? initialAccount;
  final User user;

  const TransferFormPage({
    super.key,
    required this.bankOrAccount,
    required this.accountId,
    required this.user,
    this.initialName,
    this.initialAccount,
  });

  @override
  TransferFormPageState createState() => TransferFormPageState();
}

class TransferFormPageState extends State<TransferFormPage> {
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  String? _message;
  bool _isSuccess = false;

  final String _transferApiUrl = "https://quickcart.icu/app/transfer.php";

  Future<void> _submitTransfer() async {
    final name = _recipientNameController.text.trim();
    final account = _accountNumberController.text.trim();
    final amount = _amountController.text.trim();
    final bank = widget.bankOrAccount;
    final accountId = widget.accountId;

    if (name.isEmpty || account.isEmpty || amount.isEmpty) {
      _showMessage("Please fill out all fields.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(_transferApiUrl),
        body: {
          "accountId": accountId,
          "recipientBankName": bank,
          "recipientAccountNumber": account,
          "amount": amount,
        },
      );

      if (response.statusCode != 200) {
        _showMessage("Server error: ${response.statusCode}");
        return; // IMPORTANT: Stop if the status code is not 200
      }
      final json = jsonDecode(response.body);
      if (json.containsKey('success')) {
        _showMessage(json['success'], success: true);
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => TransferReceiptPage(
                recipientName: name,
                bank: bank,
                accountNumber: account,
                amount: amount,
                user: widget.user,
              ),
            ),
          );
        });
      } else if (json.containsKey('error')) {
        _showMessage(json['error']);
      } else {
        _showMessage('Transfer failed.');
      }
    } catch (e) {
      _showMessage("Failed to connect to server: $e"); //Show the error
    }
  }

  void _showMessage(String message, {bool success = false}) {
    setState(() {
      _message = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => _message = null);
    });
  }

  Future<void> _saveAccountToHive() async {
    final name = _recipientNameController.text.trim();
    final bank = widget.bankOrAccount;
    final account = _accountNumberController.text.trim();

    if (name.isEmpty || account.isEmpty) {
      _showMessage("Please fill out recipient name and account number.");
      return;
    }

    final box = Hive.box('savedAccounts'); //Access the box.

    // Check if the account already exists
    bool accountExists = false;
    for (var savedAccount in box.values) {
      if (savedAccount is Map &&
          savedAccount['account'] == account &&
          savedAccount['bank'] == bank) {
        accountExists = true;
        break;
      }
      //Handle the case where savedAccount is not a Map.
      else if (savedAccount is! Map)
      {
        print("Skipping non-map value: $savedAccount");
      }
    }

    if (accountExists) {
      _showMessage("This account is already saved.");
      return;
    }

    try
    {
      await box.add({
        'name': name,
        'bank': bank,
        'account': account,
      });
      _showMessage("Account saved successfully!", success: true);
    }
    catch(e)
    {
      _showMessage("Error saving account: $e");
    }

  }

  @override
  void initState() {
    super.initState();
    _recipientNameController.text = widget.initialName ?? '';
    _accountNumberController.text = widget.initialAccount ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF0F8FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(CupertinoIcons.back, color: Color(0xFF1976D2)),
                      SizedBox(width: 6),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Flash message
                if (_message != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isSuccess ? const Color(0xFFE0F2F7) : const Color(0xFFFDE0DC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSuccess ? Colors.green.shade700 : Colors.red.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isSuccess ? Icons.check_circle : Icons.error,
                          color: _isSuccess ? Colors.green.shade700 : Colors.red.shade400,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _message!,
                            style: TextStyle(
                                color: _isSuccess ? Colors.green.shade900 : Colors.red.shade800,
                                fontWeight: FontWeight.bold, fontSize: 12
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                const Text(
                  'Transfer Money',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 10),

                Text(
                  "Enter recipient's account details for ${widget.bankOrAccount}.",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF607D8B),
                  ),
                ),
                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _saveAccountToHive,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF64B5F6), Color(0xFF1E88E5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.bookmark_fill, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Save Account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Fields
                _buildTextField(
                  controller: _recipientNameController,
                  label: 'Recipient Name',
                  placeholder: 'e.g. Juan Dela Cruz',
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _accountNumberController,
                  label: 'Bank Account Number',
                  placeholder: 'e.g. 1234-5678-9012',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _amountController,
                  label: 'Amount (₱)',
                  placeholder: 'e.g. 1500.00',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 25),

                // Transfer Now Button
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _submitTransfer,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(CupertinoIcons.paperplane_fill, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Transfer Now',
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

                const SizedBox(height: 150), // Extra spacing to avoid keyboard overlap
              ],
            ),
          ),
        ),
      ),
    );
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
            fontWeight: FontWeight.w500,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          cursorColor: const Color(0xFF1976D2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          style: const TextStyle(fontSize: 16, color: Color(0xFF263238)),
          placeholderStyle: const TextStyle(fontSize: 15, color: Color(0xFF90A4AE)),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8FF),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TransferReceiptPage extends StatelessWidget {
  final String recipientName;
  final String bank;
  final String accountNumber;
  final String amount;
  final User user;

  const TransferReceiptPage({super.key,
    required this.recipientName,
    required this.bank,
    required this.accountNumber,
    required this.amount,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFF0F4C3)], // Light Greenish gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  CupertinoIcons.checkmark_circle_fill,
                  size: 100,
                  color: Color(0xFF4CAF50), // Green checkmark
                ),
                const SizedBox(height: 30),
                const Text(
                  'Transfer Successful!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00897B), // Darker green
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildReceiptRow(label: 'Recipient Name', value: recipientName),
                      _buildReceiptRow(label: 'Bank', value: bank),
                      _buildReceiptRow(label: 'Account Number', value: accountNumber),
                      _buildReceiptRow(label: 'Amount', value: '₱$amount'),
                      _buildReceiptRow(label: 'Transaction Date', value: DateTime.now().toString()), //Added Transaction Date
                      _buildReceiptRow(label: 'Sender Name', value: user.name), // Added Sender's Name
                      _buildReceiptRow(label: 'Sender ID', value: user.id.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                CupertinoButton( // Changed to CupertinoButton
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF4CAF50), // Green color
                      boxShadow: const [ //Added shadow
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildReceiptRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF424242), // Dark grey
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121), // Very dark grey
            ),
          ),
        ],
      ),
    );
  }
}

