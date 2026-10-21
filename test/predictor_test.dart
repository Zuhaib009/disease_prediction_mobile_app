import 'dart:convert';
import 'dart:io';

import 'package:disease_prediction_app/predictor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Predictor predictor;

  setUpAll(() {
    final model = jsonDecode(File('assets/model.json').readAsStringSync())
        as Map<String, dynamic>;
    final info = jsonDecode(File('assets/disease_info.json').readAsStringSync())
        as Map<String, dynamic>;
    predictor = Predictor.fromJson(model, info);
  });

  test('exposes 131 selectable symptoms', () {
    expect(predictor.symptoms.length, 131);
  });

  test('fungal infection', () {
    final r = predictor
        .predict(['itching', 'skin rash', 'nodal skin eruptions']);
    expect(r.disease, 'Fungal infection');
    expect(r.confidence, greaterThan(0.9));
    expect(r.medications, isNotEmpty);
  });

  test('heart attack', () {
    final r = predictor
        .predict(['chest pain', 'vomiting', 'breathlessness', 'sweating']);
    expect(r.disease, 'Heart attack');
  });

  test('few symptoms give low confidence', () {
    final r = predictor.predict(['headache', 'high fever']);
    expect(r.confidence, lessThan(0.6));
  });

  test('rejects empty and unknown input', () {
    expect(() => predictor.predict([]), throwsArgumentError);
    expect(() => predictor.predict(['not a symptom']), throwsArgumentError);
  });
}
