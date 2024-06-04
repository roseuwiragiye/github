import 'package:flutter/material.dart';

class ThemeSwitcher extends StatefulWidget {
  final ThemeData initialTheme;
  final Widget child;

  const ThemeSwitcher({required this.initialTheme, required this.child});

  static _ThemeSwitcherState of(BuildContext context) {
    return context.findAncestorStateOfType<_ThemeSwitcherState>()!;
  }

  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  late ThemeData _themeData;

  @override
  void initState() {
    _themeData = widget.initialTheme;
    super.initState();
  }

  void switchTheme(ThemeData themeData) {
    setState(() {
      _themeData = themeData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeData,
      home: widget.child,
    );
  }
}