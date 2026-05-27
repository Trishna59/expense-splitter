import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/theme.dart';
import 'package:flutter_application_1/feature/auth/presentation/pages/signup_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized(); // required before Firebase init
  await Firebase.initializeApp();            //  Firebase call with ()
  runApp(const MyApp());                     // single MaterialApp, no wrapper
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog app',
      theme: AppTheme.darkThemeMode,
      home: const SignupPage(),
    );
  }
}