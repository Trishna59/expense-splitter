import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<String> signUpUser({
    required String name,
    required String email,
    required String password,
    Uint8List? file,
  }) async {
    String res = "Some error occurred";
    try {
      if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Send verification email
        await credential.user!.sendEmailVerification();

        await _firestore.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'name': name,
          'email': email,
          'emailVerified': false,
        });
        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } catch (err) {
      print("❌ Error: $err");
      res = err.toString();
    }
    return res;
  }

  // Sign In — blocks unverified users
  Future<String> signInUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Block sign in if email not verified
        if (!credential.user!.emailVerified) {
          await _auth.signOut();
          return "Please verify your email before signing in";
        }

        // Update emailVerified in Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .update({'emailVerified': true});

        res = "success";
      } else {
        res = "Please fill in all fields";
      }
    } catch (err) {
      print("❌ Error: $err");
      res = err.toString();
    }
    return res;
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload(); // refresh user data from Firebase
    return user?.emailVerified ?? false;
  }

  // Resend verification email
  Future<String> resendVerificationEmail() async {
    String res = "Some error occurred";
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        res = "success";
      }
    } catch (err) {
      print("❌ Error: $err");
      res = err.toString();
    }
    return res;
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}