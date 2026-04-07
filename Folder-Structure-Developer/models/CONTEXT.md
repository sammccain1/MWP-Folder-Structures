# models/ — Model Registry and Training Artifacts

You are in the **models directory**. All serialized machine learning models, training checkpoints, and model metadata live here.

## What Belongs Here

- **Serialized Models** — `.pkl`, `.onnx`, `.pt`, `.h5` files, or Hugging Face model checkpoints
- **Model Metadata** — `model_metadata.json` showing hyperparameters, training dates, and evaluation metrics for each version
- **Model Registry Index** — `model_registry.md` mapping logical model names to concrete file versions

## What Does NOT Belong Here

- **Training Scripts** — code to train models belongs in `src/services/` (if production) or `notebooks/` (if exploratory)
- **Feature Engineering** — data prep scripts belong in `data/feature-engineering/`
- **Raw Data** — dataset splits or raw CSVs belong in `data/`

## Subdirectory Guide

If you have many models, organize them by architecture or functional domain:
- `models/classifiers/`
- `models/llms/`
- `models/embeddings/`

## Rules

- **Version Everything**: Never overwrite a model file. Append a version or timestamp (e.g., `rf_classifier_v1.pkl` or `rf_classifier_20260325.pkl`).
- **Update the Registry**: Every time a new model file is created, you MUST document its purpose, inputs, and outputs in `model_registry.md`.
- **Large Files**: If model artifacts exceed 100MB, track them using `git-lfs` or upload them to cloud storage and document the URI in `model_registry.md` instead of committing the raw binary file.
