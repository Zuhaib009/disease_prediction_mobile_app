import 'package:flutter/material.dart';

import 'models.dart';
import 'predictor.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _commonKeys = [
    'headache',
    'high fever',
    'cough',
    'fatigue',
    'vomiting',
    'nausea',
    'chills',
    'skin rash',
  ];

  Predictor? _predictor;
  final List<Symptom> _selected = [];
  bool _loading = true;
  bool _failed = false;
  TextEditingController? _fieldController;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final p = await Predictor.load();
      if (!mounted) return;
      setState(() {
        _predictor = p;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _add(Symptom s) {
    if (!_selected.contains(s)) setState(() => _selected.add(s));
  }

  void _predict() {
    final result = _predictor!.predict(_selected.map((s) => s.key).toList());
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Prediction'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
            onPressed: _selected.isEmpty
                ? null
                : () => setState(() => _selected.clear()),
          ),
        ],
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_failed || _predictor == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            const Text('Could not load the prediction model.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final all = _predictor!.symptoms;
    final common = _commonKeys
        .map((k) => all.where((s) => s.key == k))
        .where((m) => m.isNotEmpty)
        .map((m) => m.first)
        .where((s) => !_selected.contains(s))
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Type your symptoms',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Autocomplete<Symptom>(
          displayStringForOption: (s) => s.label,
          optionsBuilder: (value) {
            final q = value.text.trim().toLowerCase();
            if (q.isEmpty) return const Iterable<Symptom>.empty();
            return all
                .where((s) =>
                    !_selected.contains(s) && s.label.toLowerCase().contains(q))
                .take(8);
          },
          onSelected: (s) {
            _add(s);
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _fieldController?.clear());
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            _fieldController = controller;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search, e.g. headache, mild fever, acidity...',
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
        if (common.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Common symptoms',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in common)
                ActionChip(label: Text(s.label), onPressed: () => _add(s)),
            ],
          ),
        ],
        const SizedBox(height: 20),
        Text('Selected (${_selected.length})',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (_selected.isEmpty)
          const Text('No symptoms selected yet.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final s in _selected)
                InputChip(
                  label: Text(s.label),
                  onDeleted: () => setState(() => _selected.remove(s)),
                ),
            ],
          ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: _selected.isEmpty ? null : _predict,
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          child: const Text('Predict'),
        ),
        const SizedBox(height: 24),
        const _Disclaimer(),
      ],
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'For educational purposes only. This is not a medical diagnosis. '
              'Please consult a qualified doctor for any health concern.',
            ),
          ),
        ],
      ),
    );
  }
}
