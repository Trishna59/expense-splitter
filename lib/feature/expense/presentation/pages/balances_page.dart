// lib/feature/expense/presentation/pages/balances_page.dart

import 'package:flutter/material.dart';
import 'package:expenses_splitter/feature/expense/logic/settlement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expenses_splitter/feature/expense/logic/providers/expense_provider.dart';
import 'package:expenses_splitter/feature/auth/logic/providers/auth_provider.dart';
import 'package:expenses_splitter/feature/group/data/models/group_model.dart';

class BalancesPage extends ConsumerWidget {
  final GroupModel group;
  const BalancesPage({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlements = ref.watch(settlementProvider(group.id));
    final balances = ref.watch(netBalancesProvider(group.id));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Balances & Settlements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── NET BALANCES SECTION ───────────────────────────────────
          const Text(
            'Net Balances',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: group.memberDetails.entries.map((entry) {
                final uid = entry.key;
                final name = entry.value.name;
                final balance = balances[uid] ?? 0.0;
                final isCurrentUser = uid == currentUser?.uid;

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(name[0].toUpperCase()),
                  ),
                  title: Text(
                    isCurrentUser ? '$name (you)' : name,
                  ),
                  trailing: _BalanceChip(balance: balance, currency: group.currency),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── SETTLEMENTS SECTION ────────────────────────────────────
          const Text(
            'Who Pays Whom',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (settlements.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    '🎉 All settled up!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )
          else
            ...settlements.map((s) => _SettlementCard(
                  settlement: s,
                  currency: group.currency,
                  currentUserId: currentUser?.uid ?? '',
                )),
        ],
      ),
    );
  }
}

// ── BALANCE CHIP ───────────────────────────────────────────────────────────
class _BalanceChip extends StatelessWidget {
  final double balance;
  final String currency;
  const _BalanceChip({required this.balance, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isPositive = balance > 0.01;
    final isNegative = balance < -0.01;
    final color = isPositive
        ? Colors.green
        : isNegative
            ? Colors.red
            : Colors.grey;
    final prefix = isPositive ? '+' : '';
    final label = isNegative ? 'owes' : isPositive ? 'gets back' : 'settled';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$prefix$currency ${balance.abs().toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 11),
        ),
      ],
    );
  }
}

// ── SETTLEMENT CARD ────────────────────────────────────────────────────────
class _SettlementCard extends StatelessWidget {
  final Settlement settlement;
  final String currency;
  final String currentUserId;

  const _SettlementCard({
    required this.settlement,
    required this.currency,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUserDebtor = settlement.fromId == currentUserId;
    final isCurrentUserCreditor = settlement.toId == currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // From (debtor)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCurrentUserDebtor ? 'You' : settlement.fromName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'pays',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              children: [
                const Icon(Icons.arrow_forward, color: Colors.orange),
                Text(
                  '$currency ${settlement.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            // To (creditor)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCurrentUserCreditor ? 'You' : settlement.toName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'receives',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
