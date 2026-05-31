import 'package:flutter/material.dart';

class WhatChangedCard extends StatelessWidget {
  final List<String> changes;

  const WhatChangedCard({super.key, required this.changes});

  @override
  Widget build(BuildContext context) {
    if (changes.isEmpty) return const SizedBox.shrink();

    return Card(
      color: Colors.orange.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_fix_high, color: Colors.orange.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'What changed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.orange.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...changes.map(
              (change) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(change, style: const TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
