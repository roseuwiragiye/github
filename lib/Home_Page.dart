import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'calculator_screen.dart';
import 'drawer_navigation.dart';
import 'theme_provider.dart';

class HomeScreen extends StatefulWidget {
  final GoogleSignInAccount user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription _subscription;
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
        backgroundColor: Color.fromARGB(202, 94, 159, 160),
        currentIndex: _selectedIndex,
        onTap: (index) => _onTabSelected(index, context),
        selectedItemColor: Color.fromARGB(255, 65, 111, 181),
        unselectedItemColor: Color.fromARGB(255, 143, 157, 132),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Contact us',
          ),
        ],
      ),
      drawer: DrawerNavigation(
        onItemSelected: (index) {
          _onTabSelected(index, context);
        },
        selectedIndex: _selectedIndex,
        user: widget.user,
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
            'Hello,  welcome to My First flutter App! ',
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
