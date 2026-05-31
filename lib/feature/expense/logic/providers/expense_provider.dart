// lib/feature/expense/logic/providers/expense_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Expenses_splitter/feature/expense/data/models/expense_model.dart';
import 'package:Expenses_splitter/feature/expense/data/repositories/expense_repository.dart';
import 'package:Expenses_splitter/feature/expense/logic/split_calculator.dart';
import 'package:Expenses_splitter/feature/expense/logic/settlement_service.dart';
import 'package:Expenses_splitter/feature/group/logic/providers/group_provider.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

final groupExpensesProvider =
    StreamProvider.family<List<ExpenseModel>, String>((ref, groupId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getGroupExpenses(groupId);
});

final settlementProvider =
    Provider.family<List<Settlement>, String>((ref, groupId) {
  final groupAsync = ref.watch(groupProvider(groupId));
  final expensesAsync = ref.watch(groupExpensesProvider(groupId));
  return expensesAsync.when(
    data: (expenses) {
      final group = groupAsync.value;
      if (group == null) return [];
      final memberNames = group.memberDetails.map(
        (uid, info) => MapEntry(uid, info.name),
      );
      return SettlementService.getSettlements(
        expenses: expenses,
        memberNames: memberNames,
      );
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final netBalancesProvider =
    Provider.family<Map<String, double>, String>((ref, groupId) {
  final groupAsync = ref.watch(groupProvider(groupId));
  final expensesAsync = ref.watch(groupExpensesProvider(groupId));
  return expensesAsync.when(
    data: (expenses) {
      final group = groupAsync.value;
      if (group == null) return {};
      final memberNames = group.memberDetails.map(
        (uid, info) => MapEntry(uid, info.name),
      );
      return SettlementService.calculateNetBalances(expenses, memberNames);
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

class ExpenseNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addExpense({
    required String groupId,
    required String title,
    required double amount,
    required String paidBy,
    required String paidByName,
    required List<String> participants,
    required DateTime date,
    String notes = '',
  }) async {
    final repo = ref.read(expenseRepositoryProvider);

    final splits = SplitCalculator.equalSplit(
      amount: amount,
      participants: participants,
    );

    if (!SplitCalculator.validateSplits(
      totalAmount: amount,
      splits: splits,
    )) {
      throw Exception('Split calculation error');
    }

    final expense = ExpenseModel(
      id: '',
      groupId: groupId,
      title: title,
      amount: amount,
      paidBy: paidBy,
      paidByName: paidByName,
      date: date,
      notes: notes,
      splitType: SplitType.equal,
      splits: splits,
      participants: participants,
    );

    state = const AsyncLoading();
    try {
      await repo.addExpense(expense);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final expenseNotifierProvider =
    AsyncNotifierProvider<ExpenseNotifier, void>(ExpenseNotifier.new);