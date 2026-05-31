// lib/feature/expense/data/repositories/expense_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _expenses => _firestore.collection('expenses');
  CollectionReference get _groups   => _firestore.collection('groups');

  // ── ADD EXPENSE ─────────────────────────────────────────────────────────
  // Adds expense AND updates group's totalAmount atomically
  Future<String> addExpense(ExpenseModel expense) async {
    // Use a batch — both writes succeed or both fail
    final batch = _firestore.batch();

    // 1. Create the expense document
    final expenseRef = _expenses.doc(); // auto-generated ID
    batch.set(expenseRef, expense.toMap());

    // 2. Increment the group's totalAmount
    final groupRef = _groups.doc(expense.groupId);
    batch.update(groupRef, {
      'totalAmount': FieldValue.increment(expense.amount),
    });

    await batch.commit();
    return expenseRef.id;
  }

  // ── GET GROUP EXPENSES (REAL-TIME) ──────────────────────────────────────
  Stream<List<ExpenseModel>> getGroupExpenses(String groupId) {
    return _expenses
        .where('groupId', isEqualTo: groupId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromDocument(doc))
            .toList());
  }

  // ── DELETE EXPENSE ──────────────────────────────────────────────────────
  Future<void> deleteExpense(ExpenseModel expense) async {
    final batch = _firestore.batch();

    batch.delete(_expenses.doc(expense.id));

    // Decrement group total
    batch.update(_groups.doc(expense.groupId), {
      'totalAmount': FieldValue.increment(-expense.amount),
    });

    await batch.commit();
  }
}