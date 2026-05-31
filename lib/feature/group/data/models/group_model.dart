// lib/feature/group/data/models/group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class MemberInfo {
  final String name;
  final String email;

  MemberInfo({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
      };

  factory MemberInfo.fromMap(Map<String, dynamic> map) => MemberInfo(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemberInfo &&
          runtimeType == other.runtimeType &&
          email == other.email;

  @override
  int get hashCode => email.hashCode;
}

class GroupModel {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final DateTime createdAt;
  final List<String> members;
  final Map<String, MemberInfo> memberDetails;
  final double totalAmount;
  final String currency;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    required this.memberDetails,
    this.totalAmount = 0.0,
    this.currency = 'NPR',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'members': members,
      'memberDetails': memberDetails.map(
        (uid, info) => MapEntry(uid, info.toMap()),
      ),
      'totalAmount': totalAmount,
      'currency': currency,
    };
  }

  factory GroupModel.fromMap(String id, Map<String, dynamic> map) {
    final rawDetails = map['memberDetails'] as Map<String, dynamic>? ?? {};
    final memberDetails = rawDetails.map(
      (uid, value) => MapEntry(
        uid,
        MemberInfo.fromMap(value as Map<String, dynamic>),
      ),
    );

    return GroupModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      members: List<String>.from(map['members'] ?? []),
      memberDetails: memberDetails,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'NPR',
    );
  }

  factory GroupModel.fromDocument(DocumentSnapshot doc) {
    return GroupModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  GroupModel copyWith({
    String? name,
    String? description,
    List<String>? members,
    Map<String, MemberInfo>? memberDetails,
    double? totalAmount,
  }) {
    return GroupModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy,
      createdAt: createdAt,
      members: members ?? this.members,
      memberDetails: memberDetails ?? this.memberDetails,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency,
    );
  }

  // ── EQUALITY ───────────────────────────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}