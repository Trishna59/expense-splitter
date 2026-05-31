// lib/feature/group/presentation/pages/group_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Expenses_splitter/feature/group/data/models/group_model.dart';
import 'package:Expenses_splitter/feature/group/logic/providers/group_provider.dart';
import 'package:Expenses_splitter/feature/auth/logic/providers/auth_provider.dart';
import 'package:Expenses_splitter/feature/expense/presentation/pages/add_expense_page.dart';
import 'package:Expenses_splitter/feature/expense/presentation/pages/balances_page.dart';
import 'package:Expenses_splitter/feature/expense/logic/providers/expense_provider.dart';
import 'package:Expenses_splitter/feature/expense/presentation/widgets/expense_tile.dart';

class GroupDetailPage extends ConsumerWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupProvider(groupId));
    final currentUser = ref.watch(currentUserProvider);

    return groupAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Error: $err')),
      ),
      data: (group) => Scaffold(
        appBar: AppBar(
          title: Text(group.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              tooltip: 'Balances',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BalancesPage(group: group),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showAddMemberSheet(context, ref, group),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── SUMMARY ──────────────────────────────────────────────
            Consumer(
              builder: (context, ref, _) {
                final expensesAsync =
                    ref.watch(groupExpensesProvider(group.id));
                final count = expensesAsync.value?.length ?? 0;
                return _SummaryCard(group: group, expenseCount: count);
              },
            ),
            const SizedBox(height: 20),

            // ── MEMBERS ───────────────────────────────────────────────
            const Text(
              'Members',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _MembersList(
              group: group,
              currentUserId: currentUser?.uid ?? '',
            ),
            const SizedBox(height: 20),

            // ── EXPENSES ──────────────────────────────────────────────
            const Text(
              'Expenses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _ExpensesList(
              groupId: group.id,
              currency: group.currency,
              currentUserId: currentUser?.uid ?? '',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddExpensePage(group: group),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Expense'),
        ),
      ),
    );
  }

  void _showAddMemberSheet(
      BuildContext context, WidgetRef ref, GroupModel group) {
    final emailController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Member',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'They must already have an account in the app',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'friend@email.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (emailController.text.trim().isEmpty) return;
                  Navigator.pop(context);
                  try {
                    await ref
                        .read(groupNotifierProvider.notifier)
                        .addMember(group.id, emailController.text.trim());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Member added!')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Text('Add Member', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SUMMARY CARD ───────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final GroupModel group;
  final int expenseCount;
  const _SummaryCard({required this.group, required this.expenseCount});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'Total Spent',
              value:
                  '${group.currency} ${group.totalAmount.toStringAsFixed(2)}',
            ),
            _StatItem(
              label: 'Members',
              value: '${group.members.length}',
            ),
            _StatItem(
              label: 'Expenses',
              value: '$expenseCount',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// ── MEMBERS LIST ───────────────────────────────────────────────────────────
class _MembersList extends StatelessWidget {
  final GroupModel group;
  final String currentUserId;
  const _MembersList({required this.group, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: group.memberDetails.entries.map((entry) {
          final uid = entry.key;
          final member = entry.value;
          final isYou = uid == currentUserId;

          return ListTile(
            leading: CircleAvatar(
              child: Text(member.name[0].toUpperCase()),
            ),
            title: Text(member.name),
            subtitle: Text(member.email),
            trailing: isYou ? const Chip(label: Text('You')) : null,
          );
        }).toList(),
      ),
    );
  }
}

// ── EXPENSES LIST ──────────────────────────────────────────────────────────
class _ExpensesList extends ConsumerWidget {
  final String groupId;
  final String currency;
  final String currentUserId;

  const _ExpensesList({
    required this.groupId,
    required this.currency,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(groupExpensesProvider(groupId));

    return expensesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
      data: (expenses) {
        if (expenses.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'No expenses yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }
        return Column(
          children: expenses
              .map((expense) => ExpenseTile(
                    expense: expense,
                    currentUserId: currentUserId,
                    currency: currency,
                  ))
              .toList(),
        );
      },
    );
  }
}