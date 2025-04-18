import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_model.dart';


class HomeScreen extends StatefulWidget {
  final Function(int) onFeatureTap;
  final User user;

  const HomeScreen({super.key, required this.user, required this.onFeatureTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class BankTransaction {
  final String type;
  final double amount;
  final String date;

  BankTransaction({
    required this.type,
    required this.amount,
    required this.date,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      type: json['Type'],
      amount: double.tryParse(json['Amount'].toString()) ?? 0.0,
      date: json['Date'],
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  late double _currentBalance;
  bool _showBalance = true;
  bool _showCardNumber = true;
  List<BankTransaction> _transactions = [];
  bool _isLoadingTransactions = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _currentBalance = widget.user.balance;
    fetchBalance();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await http.post(
        Uri.parse('https://quickcart.icu/app/get_balance.php'),
        body: {'accountId': widget.user.id.toString()},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final newBalance = double.tryParse(data['balance'].toString()) ?? 0.0;
          setState(() {
            _currentBalance = newBalance;
          });
        }
      }
    } catch (e) {
      print("Exception in fetchBalance: $e");
    }
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.post(
        Uri.parse('https://quickcart.icu/app/transaction.php'),
        body: {
          'accountId': widget.user.id.toString(),
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        await fetchBalance();
        if (responseData['status'].toString() == 'success') {
          List<dynamic> data = responseData['data'];
          setState(() {
            _transactions = data.map((t) => BankTransaction.fromJson(t)).toList();
            _isLoadingTransactions = false;
          });
        } else {
          setState(() {
            _isLoadingTransactions = false;
          });
        }
      } else {
        setState(() {
          _isLoadingTransactions = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.07;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
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
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Balance",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showBalance = !_showBalance;
                                });
                              },
                              child: const Icon(
                                CupertinoIcons.eye_fill,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _showBalance
                              ? _currentBalance.toStringAsFixed(2)
                              : "••••••",
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E88E5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 180,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE53935), Color(0xFFC62828)],
// Light Red to Dark Red
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.bankName,
                          style: const TextStyle(
                            color: Colors.white, // Set the bank name to red
                            fontSize: 40,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              _showCardNumber
                                  ? widget.user.accountNo
                                  : "********",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 2.0,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showCardNumber = !_showCardNumber;
                                });
                              },
                              child: const Icon(
                                CupertinoIcons.eye,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Exp: 12/24",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
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
                        const Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1565C0),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingTransactions)
                          const Center(child: CupertinoActivityIndicator())
                        else if (_transactions.isEmpty)
                          const Text("No transactions found.")
                        else
                          ..._transactions.map((tx) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: TransactionTile(
                              type: tx.type,
                              amount: tx.amount,
                              date: tx.date,
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 160),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String type;
  final double amount;
  final String date;

  const TransactionTile({
    super.key,
    required this.type,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );

    final isIncome = type.toLowerCase().contains("deposit") ||
        type.toLowerCase().contains("from");

    String formattedAmount =
        "${isIncome ? "+" : "-"} ₱${amount.toStringAsFixed(2)}";

    return Theme(
      data: theme,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    formattedAmount,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isIncome ? Colors.green[800] : Colors.red[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(CupertinoIcons.calendar, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}