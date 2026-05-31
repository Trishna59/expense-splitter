import 'package:flutter/material.dart';

class AppTheme {
  static OutlineInputBorder _border([Color color = const Color.fromARGB(255, 235, 235, 233)]) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: 3,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color.fromARGB(255, 5, 5, 39),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(27),
      enabledBorder: _border(),
      focusedBorder: _border(const Color.fromARGB(255, 214, 124, 161)),
    ),
  );
}