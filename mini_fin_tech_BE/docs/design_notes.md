# Design Notes

## Architecture choices

- `controller -> service -> repository` layering keeps business logic testable and independent of HTTP concerns.
- Validation is handled before data reaches the service layer.
- Recommendation logic is isolated in `recommendation-service.js` so it remains modular and explainable.
- Insights and alerts are generated separately from the recommendation engine to keep responsibilities narrow.
- MongoDB persistence is isolated behind a repository adapter, with optional memory mode for quick local fallback.

## Recommendation logic

The weekly auto-save recommendation is rule based and explainable:

1. Start with a base weekly save anchor at 10% of monthly income.
2. Reduce recommendation if monthly spend is ahead of ideal pace.
3. Reduce recommendation if discretionary categories are consuming too much spend.
4. Reduce recommendation if recent 7-day spend sharply increased vs the previous 7 days.
5. Increase recommendation modestly when the savings goal is behind schedule.
6. Cap the result using projected month-end cash flow so the recommendation stays realistic.

The response includes `factors` and `diagnostics` so the Flutter app can show why the number was chosen.

## Budget and alert rules

The backend includes at least two explicit rules:

1. `CATEGORY_BUDGET_80`
   A category triggers a warning when it crosses 80% of a notional monthly category budget.

2. `DISCRETIONARY_SPEND_HIGH`
   When discretionary spend ratio is high, the recommendation engine reduces auto-save and emits an alert.

## Duplicate prevention strategy

- Primary defense: `Idempotency-Key` header
- Secondary defense: `clientReferenceId` from the mobile app
- Tertiary defense: semantic duplicate detection for near-identical expenses created within a small time window

This combination is useful for:

- duplicate taps
- retries after weak network
- app restarts during sync

## Persistent data model

### `user_profiles`

- `userId`
- `monthlyIncome`
- `currency`
- `createdAt`
- `updatedAt`

### `savings_goals`

- `userId`
- `goalName`
- `targetAmount`
- `currentSavedAmount`
- `targetDate`
- `createdAt`
- `updatedAt`

### `expenses`

- `userId`
- `amount`
- `category`
- `merchant`
- `description`
- `paymentMode`
- `notes`
- `date`
- `clientReferenceId`
- `syncStatus`
- `createdAt`
- `updatedAt`

### `idempotency_keys`

- `userId`
- `key`
- `expenseId`
- `createdAt`
- `updatedAt`

## Trade-offs

- Chose MongoDB because the app data is document-shaped and the take-home scope benefits from fast schema iteration.
- Kept auth out of scope because the challenge is centered on product logic and integration quality.
- Kept tests focused on business logic and added live smoke verification against MongoDB rather than building a larger test harness first.
