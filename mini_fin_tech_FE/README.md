# Smart Spend & Auto-Save Frontend

Flutter frontend for a fintech take-home challenge. The app is mobile-first and demonstrates:

- onboarding with income and savings goal setup
- expense entry with validation and duplicate prevention
- dashboard summaries, charts, and savings progress
- insights and alerts driven by a modular recommendation engine
- offline-friendly local persistence with sync state and retry UX

## Tech stack

- Flutter
- Riverpod
- Shared Preferences for local persistence
- `fl_chart` for lightweight visualizations

## Run locally

1. Install Flutter 3.22+.
2. From the project root run:

```bash
flutter pub get
flutter run
```

## Current scope

This repository contains the frontend application requested by the take-home. It is structured so an API-backed repository/service layer can be dropped in later without changing the UI architecture.

## Key product behaviors

- Expenses are written locally first.
- New expenses start in a `pending` sync state.
- Users can toggle offline mode and retry sync manually.
- Duplicate expense submissions are prevented using an idempotency-style fingerprint.
- Dashboard recommendations consider income, spend pace, category mix, goal distance, and unusual spikes.
