class Symptom {
  final String key; // sent back to the API
  final String label; // shown to the user

  const Symptom({required this.key, required this.label});

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      Symptom(key: json['key'] as String, label: json['label'] as String);
}

class Alternative {
  final String disease;
  final double confidence;

  const Alternative({required this.disease, required this.confidence});

  factory Alternative.fromJson(Map<String, dynamic> json) => Alternative(
        disease: json['disease'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

class PredictionResult {
  final String disease;
  final double confidence;
  final List<String> symptoms;
  final List<Alternative> alternatives;
  final String description;
  final List<String> precautions;
  final List<String> medications;
  final List<String> diet;
  final List<String> workout;

  const PredictionResult({
    required this.disease,
    required this.confidence,
    required this.symptoms,
    required this.alternatives,
    required this.description,
    required this.precautions,
    required this.medications,
    required this.diet,
    required this.workout,
  });

  static List<String> _strings(dynamic v) =>
      v == null ? <String>[] : List<String>.from(v as List);

  factory PredictionResult.fromJson(Map<String, dynamic> json) =>
      PredictionResult(
        disease: json['disease'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        symptoms: _strings(json['symptoms']),
        alternatives: ((json['alternatives'] ?? []) as List)
            .map((e) => Alternative.fromJson(e as Map<String, dynamic>))
            .toList(),
        description: (json['description'] ?? '') as String,
        precautions: _strings(json['precautions']),
        medications: _strings(json['medications']),
        diet: _strings(json['diet']),
        workout: _strings(json['workout']),
      );
}
