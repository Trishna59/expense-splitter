// lib/feature/auth/data/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool emailVerified;
  final List<String> groupIds; // we'll use this when building groups

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.emailVerified,
    this.groupIds = const [],
  });

  // ── toMap ──────────────────────────────────────────────────────────────
  // Used when WRITING to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      'groupIds': groupIds,
    };
  }

  // ── fromMap ────────────────────────────────────────────────────────────
  // Used when READING from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      emailVerified: map['emailVerified'] ?? false,
      groupIds: List<String>.from(map['groupIds'] ?? []),
    );
  }

  // ── fromDocument ───────────────────────────────────────────────────────
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}