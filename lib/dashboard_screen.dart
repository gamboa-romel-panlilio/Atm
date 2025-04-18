import 'package:bankapp/pay_bills_screen.dart';
import 'package:bankapp/settings_screen.dart';
import 'package:bankapp/transfer_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'home_screen.dart';

class DashboardScaffold extends StatefulWidget {
  final User user;

  const DashboardScaffold({super.key, required this.user});

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  void _onFeatureTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(user: widget.user, onFeatureTap: _onFeatureTap);
      case 1:
        return TransferPage(user: widget.user, onFeatureTap: _onFeatureTap);
      case 2:
        return BillsPaymentPage(user: widget.user, onFeatureTap: _onFeatureTap);
      case 3:
        return SettingsPage(user: widget.user, onFeatureTap: _onFeatureTap);
      default:
        return Center(child: Text("Page $_selectedIndex"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: const Color(0xFFE3F2FD), // light pastel blue
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(CupertinoIcons.person_crop_circle, size: 50, color: Color(0xFF1565C0)), // blue
                    const SizedBox(height: 10),
                    Text(
                      widget.user.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                    ),
                    Text(widget.user.bankName, style: const TextStyle(color: Color(0xFF1976D2))),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.home, color: Color(0xFF1565C0)),
                title: const Text("Home"),
                onTap: () {
                  _onFeatureTap(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.money_dollar, color: Color(0xFF1565C0)),
                title: const Text("Transfer"),
                onTap: () {
                  _onFeatureTap(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.doc_on_doc, color: Color(0xFF1565C0)),
                title: const Text("Pay Bills"),
                onTap: () {
                  _onFeatureTap(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.settings, color: Color(0xFF1565C0)),
                title: const Text("Settings"),
                onTap: () {
                  _onFeatureTap(3);
                  Navigator.pop(context);
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(CupertinoIcons.square_arrow_right, color: Colors.blueAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.blueAccent)),
                onTap: () {
                  // handle logout
                },
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          _getPage(),
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(CupertinoIcons.bars, size: 26, color: Color(0xFF1565C0)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
