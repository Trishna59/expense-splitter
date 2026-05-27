import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/theme/theme.dart';
import 'package:flutter_application_1/feature/auth/presentation/pages/signin_page.dart';
import 'package:flutter_application_1/feature/auth/presentation/pages/signup_page.dart';
import 'package:flutter_application_1/feature/auth/presentation/pages/verify_email_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blog app',
      theme: AppTheme.darkThemeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase is still loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // User is logged in
          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return const SignupPage(); 
            } else {
              return const VerifyEmailPage(); // logged in but not verified
            }
          }

          // User is not logged in
          return const SignInPage();
        },
      ),
    );
  }
}