# Design Notes

## Architecture choices

- `AppController` owns app state and coordinates persistence, validation, and sync actions.
- `LocalStorageService` is intentionally simple for take-home speed and offline reliability.
- `RecommendationEngine` is pure and explainable so it can move to backend rules later.
- UI is split by feature: home, expenses, dashboard, and insights.

## Recommendation logic

The weekly auto-save recommendation starts from an income-derived baseline and is adjusted by:

- monthly spend pace versus expected pace
- discretionary spend ratio
- category spike detection against the prior week
- distance remaining to the savings goal
- remaining days in the month

The engine returns both the amount and reasons so the UI can explain the suggestion.

## Trade-offs

- Shared Preferences was chosen over a heavier local database to keep setup fast.
- Sync is simulated client-side because this deliverable is frontend-only.
- Charts favor readability over dense financial analytics.
