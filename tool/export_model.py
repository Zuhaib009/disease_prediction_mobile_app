"""
Trains a lightweight logistic-regression model on Training.csv and exports everything the
Flutter app needs as two JSON assets:

    assets/model.json         features, classes, coefficients, intercepts
    assets/disease_info.json  description / precautions / medications / diet / workout

Usage (from the app/ folder):
    pip install pandas numpy scikit-learn
    python tool/export_model.py /path/to/Disease-Prediction-and-Medical-Recommendation-System-main
"""
import ast
import json
import os
import re
import sys

import numpy as np
import pandas as pd
from sklearn.linear_model import LogisticRegression

src = sys.argv[1] if len(sys.argv) > 1 else "."
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets")
os.makedirs(out, exist_ok=True)
ds = lambda f: pd.read_csv(os.path.join(src, "dataset", f))


def norm(s):
    return re.sub(r"\s+", " ", str(s).replace("_", " ").lower()).strip()


def canon(s):  # disease names are spelled inconsistently across the CSVs
    return re.sub(r"\s+", " ", str(s)).strip().lower().replace("diseae", "disease")


def display(s):
    n = re.sub(r"\s+", " ", str(s)).strip().replace("diseae", "disease")
    return n[0].upper() + n[1:]


train = ds("Training.csv")
cols = list(train.columns[:-1])
X = train[cols].values.astype(float)
y = np.array([display(v) for v in train.iloc[:, -1]])

model = LogisticRegression(C=10, max_iter=5000).fit(X, y)

hidden = {norm("fluid_overload.1")}  # duplicate column of 'fluid_overload'
features = [{"key": norm(c), "label": norm(c).capitalize(), "hidden": norm(c) in hidden} for c in cols]
json.dump({
    "features": features,
    "classes": list(model.classes_),
    "coef": np.round(model.coef_, 4).tolist(),
    "intercept": np.round(model.intercept_, 4).tolist(),
}, open(os.path.join(out, "model.json"), "w"), separators=(",", ":"))

# ---- disease information -------------------------------------------------
desc, prec, meds, diets, work = (ds("description.csv"), ds("precautions_df.csv"),
                                 ds("medications.csv"), ds("diets.csv"), ds("workout_df.csv"))
for df, c in ((desc, "Disease"), (prec, "Disease"), (meds, "Disease"), (diets, "Disease"), (work, "disease")):
    df["_k"] = df[c].map(canon)


def as_list(s):
    try:
        return [str(x) for x in ast.literal_eval(s)]
    except Exception:
        return []


info = {}
for d in model.classes_:
    k = canon(d)
    p = prec[prec["_k"] == k][["Precaution_1", "Precaution_2", "Precaution_3", "Precaution_4"]]
    m, di = meds[meds["_k"] == k]["Medication"], diets[diets["_k"] == k]["Diet"]
    info[d] = {
        "description": " ".join(desc[desc["_k"] == k]["Description"].tolist()),
        "precautions": [str(x).strip().capitalize() for x in (p.values[0] if len(p) else [])
                        if pd.notna(x) and str(x).strip()],
        "medications": as_list(m.values[0]) if len(m) else [],
        "diet": as_list(di.values[0]) if len(di) else [],
        "workout": [str(x) for x in work[work["_k"] == k]["workout"].tolist()],
    }
json.dump(info, open(os.path.join(out, "disease_info.json"), "w"), ensure_ascii=False, separators=(",", ":"))
print("exported", len(model.classes_), "diseases,", len(features), "features ->", os.path.abspath(out))
