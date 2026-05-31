// lib/feature/expense/presentation/pages/add_expense_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expenses_splitter/feature/expense/logic/providers/expense_provider.dart';
import 'package:expenses_splitter/feature/group/data/models/group_model.dart';
import 'package:expenses_splitter/feature/auth/logic/providers/auth_provider.dart';

class AddExpensePage extends ConsumerStatefulWidget {
  final GroupModel group;
  const AddExpensePage({super.key, required this.group});

  @override
  ConsumerState<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends ConsumerState<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String? _paidBy;        // userId of who paid
  String? _paidByName;    // name of who paid
  List<String> _selectedParticipants = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // By default select all members as participants
    _selectedParticipants = List.from(widget.group.members);

    // By default paidBy is the current user
    final currentUser = ref.read(currentUserProvider);
    if (currentUser != null) {
      _paidBy = currentUser.uid;
      _paidByName = widget.group.memberDetails[currentUser.uid]?.name ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        actions: [
          // Save button in app bar
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _saveExpense,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── TITLE ──────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'e.g. Hotel, Dinner, Bus ticket',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description_outlined),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),

            // ── AMOUNT ─────────────────────────────────────────────────
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.payments_outlined),
                prefixText: '${widget.group.currency} ',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                if (double.tryParse(value) == null) {
                  return 'Enter a valid number';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── DATE ───────────────────────────────────────────────────
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey.shade600),
              ),
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // ── PAID BY ────────────────────────────────────────────────
            const Text(
              'Paid by',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _PaidBySelector(
              group: widget.group,
              selectedUid: _paidBy,
              onChanged: (uid, name) {
                setState(() {
                  _paidBy = uid;
                  _paidByName = name;
                });
              },
            ),
            const SizedBox(height: 16),

            // ── PARTICIPANTS ───────────────────────────────────────────
            const Text(
              'Split between',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            const Text(
              'Select who is involved in this expense',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _ParticipantsSelector(
              group: widget.group,
              selectedParticipants: _selectedParticipants,
              onChanged: (participants) {
                setState(() => _selectedParticipants = participants);
              },
            ),
            const SizedBox(height: 16),

            // ── SPLIT PREVIEW ──────────────────────────────────────────
            if (_amountController.text.isNotEmpty &&
                double.tryParse(_amountController.text) != null &&
                _selectedParticipants.isNotEmpty)
              _SplitPreview(
                amount: double.parse(_amountController.text),
                participants: _selectedParticipants,
                group: widget.group,
                currency: widget.group.currency,
              ),
            const SizedBox(height: 16),

            // ── NOTES ──────────────────────────────────────────────────
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── DATE PICKER ──────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ── SAVE EXPENSE ─────────────────────────────────────────────────────────
  Future<void> _saveExpense() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) return;

    // Validate paid by
    if (_paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who paid')),
      );
      return;
    }

    // Validate participants
    if (_selectedParticipants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one participant')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(expenseNotifierProvider.notifier).addExpense(
            groupId: widget.group.id,
            title: _titleController.text.trim(),
            amount: double.parse(_amountController.text),
            paidBy: _paidBy!,
            paidByName: _paidByName ?? '',
            participants: _selectedParticipants,
            date: _selectedDate,
            notes: _notesController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context); // go back to group detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ── PAID BY SELECTOR ───────────────────────────────────────────────────────
class _PaidBySelector extends StatelessWidget {
  final GroupModel group;
  final String? selectedUid;
  final Function(String uid, String name) onChanged;

  const _PaidBySelector({
    required this.group,
    required this.selectedUid,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: group.memberDetails.entries.map((entry) {
        final uid = entry.key;
        final member = entry.value;
        final isSelected = selectedUid == uid;

        return ChoiceChip(
          label: Text(member.name),
          selected: isSelected,
          onSelected: (_) => onChanged(uid, member.name),
        );
      }).toList(),
    );
  }
}

// ── PARTICIPANTS SELECTOR ──────────────────────────────────────────────────
class _ParticipantsSelector extends StatelessWidget {
  final GroupModel group;
  final List<String> selectedParticipants;
  final Function(List<String>) onChanged;

  const _ParticipantsSelector({
    required this.group,
    required this.selectedParticipants,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: group.memberDetails.entries.map((entry) {
        final uid = entry.key;
        final member = entry.value;
        final isSelected = selectedParticipants.contains(uid);

        return CheckboxListTile(
          title: Text(member.name),
          subtitle: Text(member.email),
          value: isSelected,
          onChanged: (checked) {
            final updated = List<String>.from(selectedParticipants);
            if (checked == true) {
              updated.add(uid);
            } else {
              updated.remove(uid);
            }
            onChanged(updated);
          },
        );
      }).toList(),
    );
  }
}

// ── SPLIT PREVIEW ──────────────────────────────────────────────────────────
// Shows a live preview of how much each person owes
// Updates as user types the amount
class _SplitPreview extends StatelessWidget {
  final double amount;
  final List<String> participants;
  final GroupModel group;
  final String currency;

  const _SplitPreview({
    required this.amount,
    required this.participants,
    required this.group,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate equal share per person
    final sharePerPerson = amount / participants.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Split Preview (Equal)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ...participants.map((uid) {
              final name = group.memberDetails[uid]?.name ?? uid;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name),
                    Text(
                      '$currency ${sharePerPerson.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}