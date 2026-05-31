// lib/feature/expense/logic/settlement_service.dart

import '../data/models/expense_model.dart';

// Represents one settlement transaction
// "from" owes "to" the given amount
class Settlement {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;

  Settlement({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
  });

  @override
  String toString() =>
      '$fromName owes $toName ${amount.toStringAsFixed(2)}';
}

class SettlementService {

  // ── STEP 1: CALCULATE NET BALANCE PER PERSON ──────────────────────────
  //
  // For each expense:
  //   the payer gets CREDIT  (+amount they paid)
  //   each participant gets DEBIT (-their share)
  //
  // netBalance > 0 means person is OWED money (creditor)
  // netBalance < 0 means person OWES money (debtor)
  //
  static Map<String, double> calculateNetBalances(
    List<ExpenseModel> expenses,
    Map<String, String> memberNames, // { uid: name }
  ) {
    final balances = <String, double>{};

    // Initialize everyone at 0
    memberNames.keys.forEach((uid) => balances[uid] = 0.0);

    for (final expense in expenses) {
      // Payer gets credit for the full amount they paid
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;

      // Each participant gets debited their share
      expense.splits.forEach((uid, share) {
        balances[uid] = (balances[uid] ?? 0) - share;
      });
    }

    // Round to 2 decimal places to avoid floating point noise
    // e.g. -0.000000001 should be 0
    balances.updateAll(
      (uid, balance) =>
          double.parse(balance.toStringAsFixed(2)),
    );

    return balances;
  }

  // ── STEP 2: MINIMIZE TRANSACTIONS ─────────────────────────────────────
  //
  // Greedy two-pointer algorithm:
  // Sort creditors (positive) and debtors (negative)
  // Match largest debtor with largest creditor
  // Repeat until all settled
  //
  static List<Settlement> minimizeTransactions(
    Map<String, double> balances,
    Map<String, String> memberNames, // { uid: name }
  ) {
    final settlements = <Settlement>[];

    // Separate into creditors and debtors
    // Filter out anyone with ~0 balance (already settled)
    final creditors = balances.entries
        .where((e) => e.value > 0.01)
        .map((e) => _Balance(uid: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount)); // descending

    final debtors = balances.entries
        .where((e) => e.value < -0.01)
        .map((e) => _Balance(uid: e.key, amount: e.value.abs()))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount)); // descending

    int i = 0; // creditor index
    int j = 0; // debtor index

    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];

      // The settlement amount is the smaller of the two
      final amount = creditor.amount < debtor.amount
          ? creditor.amount
          : debtor.amount;

      // Round to avoid floating point noise
      final roundedAmount = double.parse(amount.toStringAsFixed(2));

      if (roundedAmount > 0.01) {
        settlements.add(Settlement(
          fromId: debtor.uid,
          fromName: memberNames[debtor.uid] ?? debtor.uid,
          toId: creditor.uid,
          toName: memberNames[creditor.uid] ?? creditor.uid,
          amount: roundedAmount,
        ));
      }

      // Reduce both balances by the settled amount
      creditor.amount -= amount;
      debtor.amount -= amount;

      // Move to next if fully settled
      if (creditor.amount < 0.01) i++;
      if (debtor.amount < 0.01) j++;
    }

    return settlements;
  }

  // ── COMBINED: GET SETTLEMENTS FROM EXPENSES ───────────────────────────
  // Convenience method — takes expenses and member info, returns settlements
  static List<Settlement> getSettlements({
    required List<ExpenseModel> expenses,
    required Map<String, String> memberNames,
  }) {
    final balances = calculateNetBalances(expenses, memberNames);
    return minimizeTransactions(balances, memberNames);
  }

  // ── GET BALANCE FOR ONE USER ───────────────────────────────────────────
  // Positive = they are owed money
  // Negative = they owe money
  // Zero = settled
  static double getUserBalance(
    String userId,
    Map<String, double> balances,
  ) {
    return balances[userId] ?? 0.0;
  }
}

// Private helper class for the algorithm
class _Balance {
  final String uid;
  double amount;
  _Balance({required this.uid, required this.amount});
}