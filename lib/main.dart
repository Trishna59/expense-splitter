// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';       
import 'package:Expenses_splitter/core/theme/theme.dart';
import 'package:Expenses_splitter/feature/auth/presentation/pages/signin_page.dart';
import 'package:Expenses_splitter/feature/auth/presentation/pages/verify_email_page.dart';
import 'package:Expenses_splitter/feature/group/presentation/pages/groups_list_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,       // enable local cache
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // no cache size limit
  );
  runApp(const ProviderScope(child: MyApp()));                     
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Splitter',
      theme: AppTheme.darkThemeMode,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            if (snapshot.data!.emailVerified) {
              return const GroupsListPage();
            } else {
              return const VerifyEmailPage();
            }
          }
          return const SignInPage();
        },
      ),
    );
  }
}