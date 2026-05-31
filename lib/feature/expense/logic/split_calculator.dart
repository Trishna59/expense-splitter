// lib/feature/expense/logic/split_calculator.dart

class SplitCalculator {

  // ── EQUAL SPLIT ─────────────────────────────────────────────────────────
  // Divides amount equally, handles rounding remainder
  static Map<String, double> equalSplit({
    required double amount,
    required List<String> participants,
  }) {
    if (participants.isEmpty) return {};

    final count = participants.length;
    // Round down to 2 decimal places for each person
    final baseShare = double.parse(
      (amount / count).toStringAsFixed(2),
    );

    final splits = <String, double>{};

    // Give base share to everyone except last person
    for (int i = 0; i < count - 1; i++) {
      splits[participants[i]] = baseShare;
    }

    // Last person gets the remainder to ensure total = amount exactly
    final lastPersonShare = double.parse(
      (amount - (baseShare * (count - 1))).toStringAsFixed(2),
    );
    splits[participants.last] = lastPersonShare;

    return splits;
  }

  // ── VALIDATE SPLITS ─────────────────────────────────────────────────────
  // Checks that all splits add up to the total amount
  // Use this before saving to catch any calculation errors
  static bool validateSplits({
    required double totalAmount,
    required Map<String, double> splits,
  }) {
    final sum = splits.values.fold(0.0, (a, b) => a + b);
    // Allow 1 paisa tolerance for floating point errors
    return (sum - totalAmount).abs() < 0.01;
  }

  // ── TOTAL PER USER ──────────────────────────────────────────────────────
  // Given a list of expenses, calculates how much each user has spent total
  static Map<String, double> totalSpentPerUser(
      List<Map<String, double>> allSplits) {
    final totals = <String, double>{};
    for (final split in allSplits) {
      split.forEach((uid, amount) {
        totals[uid] = (totals[uid] ?? 0) + amount;
      });
    }
    return totals;
  }
}