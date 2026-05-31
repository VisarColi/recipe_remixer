import 'package:flutter/material.dart';
import '../services/remix_service.dart';
import '../widgets/loading_overlay.dart';
import 'result_screen.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _recipeController = TextEditingController();
  final _constraintController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _recipeController.dispose();
    _constraintController.dispose();
    super.dispose();
  }

  Future<void> _onRemix() async {
    final recipe = _recipeController.text.trim();
    final constraint = _constraintController.text.trim();

    if (recipe.isEmpty || constraint.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both the recipe and the constraint.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await RemixService.remix(
        recipe: recipe,
        constraint: constraint,
      );
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } on RemixException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Remixer'),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Paste any recipe, add a constraint, get a remix.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _recipeController,
                      maxLines: 10,
                      minLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Recipe',
                        hintText: 'Paste your recipe here…',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _constraintController,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        labelText: 'Constraint',
                        hintText: 'e.g. make it vegan, halve it, kid-friendly',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isLoading,
                      onSubmitted: (_) => _isLoading ? null : _onRemix(),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _onRemix,
                      icon: const Icon(Icons.shuffle),
                      label: const Text('Remix It'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 40),
                    _ConstraintChips(
                      onSelected: (constraint) {
                        _constraintController.text = constraint;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}

class _ConstraintChips extends StatelessWidget {
  final void Function(String) onSelected;

  const _ConstraintChips({required this.onSelected});

  static const _suggestions = [
    'Make it vegan',
    'Halve the recipe',
    'Kid-friendly',
    '30-minute version',
    'Gluten-free',
    'Low-calorie',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try one of these:',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _suggestions
              .map(
                (s) => ActionChip(
                  label: Text(s),
                  onPressed: () => onSelected(s),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
