// lib/feature/group/presentation/widgets/group_card.dart

import 'package:flutter/material.dart';
import 'package:Expenses_splitter/feature/group/data/models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  const GroupCard({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          radius: 24,
          child: Text(
            group.name[0].toUpperCase(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          group.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${group.members.length} member${group.members.length == 1 ? '' : 's'}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              group.currency,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              group.totalAmount.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        onTap: () {
          // group detail page — coming next
        },
      ),
    );
  }
}