# Disease Prediction Mobile App

An offline Flutter app that predicts a likely medical condition from the symptoms you select and shows practical health guidance for it. The machine learning model runs **entirely on the device**: no server, no account and no internet connection is needed, and symptom data never leaves the phone.

This is my first project in artificial intelligence and data science, built as the final project of a six-month Artificial Intelligence and Data Science course.

> **Disclaimer:** This app is for educational purposes only. It is not a medical diagnosis and does not replace a qualified doctor.

## Features

- **Symptom search:** autocomplete over 131 symptoms, plus one-tap chips for common ones (headache, high fever, cough, fatigue, vomiting, nausea, chills, skin rash).
- **Symptom management:** selected symptoms appear as removable chips, with a reset button. Predict is disabled until at least one symptom is chosen.
- **Prediction with confidence:** the most likely condition, a confidence bar and up to two alternative possibilities.
- **Low-confidence warning:** when only a few symptoms are entered, the app asks for more instead of presenting a weak guess as a firm answer.
- **Health recommendations** for the predicted condition, shown as separate cards:
  - Disease description and general information
  - Medication suggestions
  - Dietary recommendations
  - Exercise and workout plans
  - Preventive precautions
- **Error handling and disclaimers:** a retry screen if the model fails to load, and a medical disclaimer on both screens.

## How it works

### Model and data

The model is trained offline in Python and exported to JSON:

- **Data:** 41 diseases and 132 symptoms (131 are shown to the user after removing a duplicate column), with curated descriptions, medications, diets, workouts and precautions for each disease.
- **Model:** multinomial logistic regression (scikit-learn, `C = 10`).
- **Export:** `tool/export_model.py` writes two assets:
  - `assets/model.json`: symptom features, class names, coefficients and intercepts
  - `assets/disease_info.json`: recommendations for each disease

I chose logistic regression because it suits binary symptom features, its parameters are only a coefficient matrix and an intercept vector, and it produces class probabilities that can be shown as confidence. It also needs no mobile ML runtime.

### On-device inference

The Dart `Predictor` class loads both JSON files and runs inference directly. Because every feature is binary, each class score is the intercept plus the coefficients of the selected symptoms. A numerically stable softmax converts the scores to probabilities, and the app returns the top class with its probability and up to two alternatives above 2%. No external ML library is used.

## Project structure

```
lib/
  main.dart            App entry point and Material 3 theme
  models.dart          Data classes (symptoms, alternatives, prediction result)
  predictor.dart       Model loading and inference (independent of the UI)
  home_screen.dart     Symptom search and selection
  result_screen.dart   Prediction and recommendation cards
assets/
  model.json           Exported model parameters
  disease_info.json    Recommendations for each disease
tool/
  export_model.py      Trains the model and exports the JSON assets
test/
  predictor_test.dart  Unit tests for the prediction engine
  widget_test.dart     Basic widget test
```

## Getting started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) with Dart SDK `>=3.3.0 <4.0.0`
- An Android or iOS device, or an emulator

### Run the app

```bash
git clone https://github.com/Zuhaib009/disease_prediction_mobile_app.git
cd disease_prediction_mobile_app
flutter pub get
flutter run
```

### Run the tests

```bash
flutter test
```

The tests check that all 131 symptoms are exposed, that clear symptom sets predict the right disease (for example, itching, skin rash and nodal skin eruptions give "Fungal infection"), that vague input gives low confidence, and that empty or unknown input is rejected.

### Retrain the model (optional)

The trained assets are already included. To regenerate them, you need the original dataset folder (with `Training.csv`, `description.csv`, `medications.csv`, `diets.csv`, `workout_df.csv` and `precautions_df.csv`):

```bash
pip install pandas numpy scikit-learn
python tool/export_model.py /path/to/dataset-project-folder
```

## Limitations

- The model is trained on a single structured symptom dataset, not on real clinical records.
- Predictions and the medication, diet and workout content are educational and have not been clinically validated.
- Inputs are binary (present or absent), so severity, duration, age and medical history are not considered.

## Future work

- Proper train/test evaluation with cross-validation, and comparison with other classifiers
- Severity and demographic inputs
- Clinician review of the recommendation content
- Local prediction history
- Urdu and other language support
- Urgent-care alerts for high-risk symptom combinations such as chest pain

## Author

**Zuhaib Hassan**: Flutter developer. [GitHub](https://github.com/Zuhaib009)
