import 'package:flutter/material.dart';

import 'models.dart';

class ResultScreen extends StatelessWidget {
  final PredictionResult result;
  const ResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Predicted Results')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (result.confidence < 0.6) const _LowConfidenceBanner(),
            Card(
              color: scheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Most likely condition',
                        style: text.labelLarge
                            ?.copyWith(color: scheme.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(result.disease,
                        style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer)),
                    const SizedBox(height: 12),
                    Text(
                        'Model confidence: ${(result.confidence * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: scheme.onPrimaryContainer)),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: result.confidence.clamp(0.0, 1.0),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 0,
                      children: [
                        for (final s in result.symptoms)
                          Chip(
                            label: Text(s),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (result.alternatives.isNotEmpty)
              _Section(
                icon: Icons.compare_arrows,
                title: 'Other possibilities',
                child: _Bullets([
                  for (final a in result.alternatives)
                    '${a.disease} (${(a.confidence * 100).toStringAsFixed(0)}%)',
                ]),
              ),
            _Section(
              icon: Icons.description_outlined,
              title: 'Description',
              child: Text(result.description),
            ),
            _Section(
              icon: Icons.health_and_safety_outlined,
              title: 'Precautions',
              child: _Bullets(result.precautions),
            ),
            _Section(
              icon: Icons.medication_outlined,
              title: 'Medications',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bullets(result.medications),
                  const SizedBox(height: 8),
                  Text(
                    'Do not take any medication without consulting a doctor.',
                    style: text.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            _Section(
              icon: Icons.restaurant_outlined,
              title: 'Diet',
              child: _Bullets(result.diet),
            ),
            _Section(
              icon: Icons.fitness_center,
              title: 'Workout & lifestyle',
              child: _Bullets(result.workout),
            ),
            const SizedBox(height: 8),
            Text(
              'This is not a medical diagnosis. Please consult a qualified '
              'healthcare professional.',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Section(
      {required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  final List<String> items;
  const _Bullets(this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('No information available.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }
}

class _LowConfidenceBanner extends StatelessWidget {
  const _LowConfidenceBanner();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Low confidence: only a few symptoms were entered, so several '
              'conditions fit. Add more symptoms for a more reliable result.',
              style: TextStyle(color: scheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}
