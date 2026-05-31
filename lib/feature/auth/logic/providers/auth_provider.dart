// lib/feature/auth/logic/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Exposes the Firebase auth state stream as a Riverpod provider
// This emits a new User? every time auth state changes (login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Convenience provider — gives you just the current uid as a String
// Throws if called when user is not logged in
final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('No user logged in');
  return user.uid;
});

// Convenience provider — gives you the full User object or null
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});
final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  Future<void> signOut() => _auth.signOut();
}