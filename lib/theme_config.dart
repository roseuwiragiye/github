import 'package:flutter/material.dart';

class ThemeConfig {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade50,
    colorScheme: const ColorScheme.light(
      primary: Color.fromARGB(255, 159, 158, 96),
      onPrimary: Color.fromARGB(255, 66, 149, 227),
      primaryContainer: Color.fromARGB(255, 242, 246, 211),
      onPrimaryContainer: Color(0xFF22005d),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFcfbcff),
      onPrimary: Color(0xFF381e72),
      primaryContainer: Color(0xFF4f378a),
      onPrimaryContainer: Color(0xFFe9ddff),
    ),
  );
}