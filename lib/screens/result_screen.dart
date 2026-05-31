import 'package:flutter/material.dart';
import '../models/remix_result.dart';
import '../widgets/what_changed_card.dart';

class ResultScreen extends StatefulWidget {
  final RemixResult result;

  const ResultScreen({super.key, required this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _useMetric = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    if (!result.canAdapt) {
      return _CannotAdaptScreen(reason: result.reason);
    }

    final recipe = result.recipe!;
    final ingredients =
        _useMetric ? result.metricIngredients : recipe.ingredients;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title, overflow: TextOverflow.ellipsis),
        actions: [
          Row(
            children: [
              Text(
                _useMetric ? 'Metric' : 'Imperial',
                style: const TextStyle(fontSize: 13),
              ),
              Switch(
                value: _useMetric,
                onChanged: (v) => setState(() => _useMetric = v),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Meta chips
                Wrap(
                  spacing: 8,
                  children: [
                    if (recipe.servings.isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.people_outline, size: 16),
                        label: Text(recipe.servings),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (recipe.time.isNotEmpty)
                      Chip(
                        avatar: const Icon(Icons.timer_outlined, size: 16),
                        label: Text(recipe.time),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ingredients
                _SectionHeader(label: 'Ingredients'),
                const SizedBox(height: 8),
                ...ingredients.map(
                  (ing) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 15)),
                        Expanded(
                          child: Text(ing, style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Instructions
                _SectionHeader(label: 'Instructions'),
                const SizedBox(height: 8),
                ...recipe.instructions.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${e.key + 1}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                WhatChangedCard(changes: result.whatChanged),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CannotAdaptScreen extends StatelessWidget {
  final String reason;

  const _CannotAdaptScreen({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Remixer')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_meals, size: 64, color: Colors.orange.shade400),
                const SizedBox(height: 24),
                Text(
                  "We couldn't remix this one",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.orange.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      reason,
                      style: const TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Try a different constraint'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
