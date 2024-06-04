import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:github/drawer_navigation1.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'calculator_screen.dart';
import 'theme_provider.dart';

class HomeScreenOne extends StatefulWidget {
  final GoogleSignInAccount? googleUser;
  final String? email;
  HomeScreenOne({this.googleUser, this.email});

  @override
  _HomeScreenOneState createState() => _HomeScreenOneState();
}

class _HomeScreenOneState extends State<HomeScreenOne> {
  late StreamSubscription _subscription;
  final _auth = FirebaseAuth.instance;
  bool _isDeviceConnected = false;
  bool _isAlertSet = false;

  @override
  void initState() {
    // Call getConnectivity in initState if needed
    // getConnectivity();
    super.initState();
  }

  @override
  void dispose() {
    // Cancel the subscription in dispose
    _subscription.cancel();
    super.dispose();
  }

  int _selectedIndex = 0;
  final List<Widget> _screens = [
    ScreenOne(),
    CalculatorScreen(),
    ScreenThree(),
  ];

  // List of titles for the AppBar based on the tab index
  final List<String> _appBarTitles = ['Home', 'Calc', 'Contact us'];

  void _onTabSelected(int index, BuildContext context) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user signed in with Google
    String? email;
    if (widget.googleUser != null) {
      email = widget.googleUser!.email;
    } else {
      // Check if the user is signed in with Firebase
      email = _auth.currentUser?.email;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_selectedIndex]), // Dynamic title
        actions: [
          IconButton(
            onPressed: () {
              context.read<ThemeStateProvider>().setDarkTheme();
            },
            icon: context.select((ThemeStateProvider theme) => theme.isDarkTheme)
                ? const Icon(Icons.dark_mode_outlined)
                : const Icon(Icons.light_mode_outlined),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 105, 171, 165),
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabSelected(index, context),
        selectedItemColor: const Color.fromARGB(255, 79, 162, 203),
        unselectedItemColor: Color.fromARGB(255, 111, 113, 74),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
        ],
      ),
      drawer: DrawerNavigationOne(
        onItemSelected: (index) {
          _onTabSelected(index, context);
        },
        selectedIndex: _selectedIndex,
        googleUser: widget.googleUser,
        email: email,
      ),
    );
  }
}

class ScreenOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Hello, and welcome to My First flutter App!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class ScreenThree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Enjoy our app.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
