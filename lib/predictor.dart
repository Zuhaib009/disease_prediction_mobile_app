import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

import 'models.dart';

/// On-device multinomial logistic regression (exported by tool/export_model.py).
class Predictor {
  /// Symptoms the user can pick from (sorted by label).
  final List<Symptom> symptoms;

  final List<String> _classes;
  final List<List<double>> _coef; // [class][feature]
  final List<double> _intercept;
  final Map<String, int> _index; // symptom key -> feature column
  final Map<String, dynamic> _info;

  Predictor._(this.symptoms, this._classes, this._coef, this._intercept,
      this._index, this._info);

  factory Predictor.fromJson(
      Map<String, dynamic> model, Map<String, dynamic> info) {
    final features =
        (model['features'] as List).map((e) => e as Map<String, dynamic>).toList();

    final index = <String, int>{
      for (var i = 0; i < features.length; i++) features[i]['key'] as String: i,
    };

    final symptoms = <Symptom>[
      for (final f in features)
        if (f['hidden'] != true)
          Symptom(key: f['key'] as String, label: f['label'] as String),
    ]..sort((a, b) => a.label.compareTo(b.label));

    final coef = (model['coef'] as List)
        .map((row) =>
            (row as List).map((v) => (v as num).toDouble()).toList())
        .toList();

    return Predictor._(
      symptoms,
      (model['classes'] as List).map((e) => e as String).toList(),
      coef,
      (model['intercept'] as List).map((v) => (v as num).toDouble()).toList(),
      index,
      info,
    );
  }

  static Future<Predictor> load() async {
    final model = jsonDecode(await rootBundle.loadString('assets/model.json'))
        as Map<String, dynamic>;
    final info =
        jsonDecode(await rootBundle.loadString('assets/disease_info.json'))
            as Map<String, dynamic>;
    return Predictor.fromJson(model, info);
  }

  PredictionResult predict(List<String> symptomKeys) {
    final keys = symptomKeys.toSet();
    if (keys.isEmpty) throw ArgumentError('Select at least one symptom.');

    // logits = intercept + sum of the coefficients of the selected symptoms
    final z = List<double>.from(_intercept);
    for (final k in keys) {
      final j = _index[k];
      if (j == null) throw ArgumentError('Unknown symptom: $k');
      for (var c = 0; c < z.length; c++) {
        z[c] += _coef[c][j];
      }
    }

    // softmax
    final maxZ = z.reduce(math.max);
    final exps = z.map((v) => math.exp(v - maxZ)).toList();
    final total = exps.fold<double>(0, (a, b) => a + b);
    final probs = exps.map((e) => e / total).toList();

    final order = List<int>.generate(probs.length, (i) => i)
      ..sort((a, b) => probs[b].compareTo(probs[a]));

    final best = _classes[order.first];
    final detail = (_info[best] ?? <String, dynamic>{}) as Map<String, dynamic>;
    List<String> list(String k) =>
        ((detail[k] ?? []) as List).map((e) => e.toString()).toList();

    return PredictionResult(
      disease: best,
      confidence: probs[order.first],
      symptoms: keys.toList(),
      alternatives: [
        for (final i in order.skip(1).take(2))
          if (probs[i] >= 0.02)
            Alternative(disease: _classes[i], confidence: probs[i]),
      ],
      description: (detail['description'] ?? '') as String,
      precautions: list('precautions'),
      medications: list('medications'),
      diet: list('diet'),
      workout: list('workout'),
    );
  }
}
