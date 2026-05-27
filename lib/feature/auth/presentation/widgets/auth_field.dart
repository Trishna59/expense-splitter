import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false, // ← made optional with default false
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,   // ← was missing!
      obscureText: isPassword,  // ← was missing!
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}