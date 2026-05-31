// lib/feature/expense/data/models/expense_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// The type of split chosen when adding the expense
enum SplitType { equal, custom, percentage }

class ExpenseModel {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String paidBy;         // userId of who paid
  final String paidByName;     // denormalized name for display
  final DateTime date;
  final String notes;
  final SplitType splitType;
  final Map<String, double> splits; // { userId: shareAmount }
  final List<String> participants;  // userIds involved in this expense

  ExpenseModel({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.paidByName,
    required this.date,
    this.notes = '',
    required this.splitType,
    required this.splits,
    required this.participants,
  });

  // ── toMap ──────────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'paidByName': paidByName,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'splitType': splitType.name, // stores as "equal", "custom", "percentage"
      'splits': splits,
      'participants': participants,
    };
  }

  // ── fromMap ────────────────────────────────────────────────────────────
  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      groupId: map['groupId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      paidBy: map['paidBy'] ?? '',
      paidByName: map['paidByName'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      notes: map['notes'] ?? '',
      splitType: SplitType.values.byName(map['splitType'] ?? 'equal'),
      splits: Map<String, double>.from(
        (map['splits'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
      ),
      participants: List<String>.from(map['participants'] ?? []),
    );
  }

  // ── fromDocument ───────────────────────────────────────────────────────
  factory ExpenseModel.fromDocument(DocumentSnapshot doc) {
    return ExpenseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }
}