# API Contract For Flutter

Base URL:

```text
http://localhost:4000/api/v1
```

## Expense object

```json
{
  "id": "69cffa717b0f2d6087a7278f",
  "userId": "demo-user",
  "amount": 320,
  "category": "food",
  "merchant": "Swiggy",
  "description": "Dinner order",
  "date": "2026-04-02T19:30:00.000Z",
  "paymentMode": "upi",
  "notes": "Team dinner",
  "clientReferenceId": "mobile-1748",
  "syncStatus": "synced",
  "createdAt": "2026-04-03T17:35:45.787Z",
  "updatedAt": "2026-04-03T17:35:45.787Z"
}
```

## Create expense response

```json
{
  "data": {
    "id": "69cffa717b0f2d6087a7278f",
    "userId": "demo-user",
    "amount": 320,
    "category": "food",
    "merchant": "Swiggy",
    "description": "Dinner order",
    "date": "2026-04-02T19:30:00.000Z",
    "paymentMode": "upi",
    "notes": "Team dinner",
    "clientReferenceId": "mobile-1748",
    "syncStatus": "synced",
    "createdAt": "2026-04-03T17:35:45.787Z",
    "updatedAt": "2026-04-03T17:35:45.787Z"
  },
  "meta": {
    "idempotentReplay": false,
    "duplicatePrevented": false,
    "syncState": "synced"
  }
}
```

## Dashboard response shape

```json
{
  "data": {
    "profile": {
      "id": "69cff9fd5f606544c5548af4",
      "userId": "demo-user",
      "monthlyIncome": 60000,
      "currency": "INR",
      "createdAt": "2026-04-03T17:33:48.566Z",
      "updatedAt": "2026-04-03T17:38:09.264Z"
    },
    "goal": {
      "id": "69cffa725f606544c5548b1a",
      "userId": "demo-user",
      "goalName": "Emergency Fund",
      "targetAmount": 25000,
      "currentSavedAmount": 4000,
      "targetDate": "2026-08-29T18:30:00.000Z",
      "createdAt": "2026-04-03T17:35:45.758Z",
      "updatedAt": "2026-04-03T17:38:09.354Z"
    },
    "summary": {
      "totalSpentWeek": 320,
      "totalSpentMonth": 320,
      "remainingMonthlyBudget": 59680,
      "expenseCount": 1,
      "categoryBreakdown": [
        {
          "category": "food",
          "amount": 320
        }
      ]
    },
    "savingsGoalProgress": {
      "goalName": "Emergency Fund",
      "currentSavedAmount": 4000,
      "targetAmount": 25000,
      "progressPercent": 16,
      "targetDate": "2026-08-29T18:30:00.000Z"
    },
    "recommendation": {
      "recommendedAmount": 5134.09,
      "confidence": "medium",
      "reason": "Recommendation balances income, spending pace, discretionary spend, and savings-goal urgency.",
      "factors": [],
      "diagnostics": {}
    },
    "alerts": [],
    "insights": []
  }
}
```

## Error response shape

```json
{
  "error": {
    "code": "ApiError",
    "message": "amount must be greater than 0"
  }
}
```

## Flutter mapping notes

- Treat all dates as ISO-8601 strings.
- Use `id` as the FE primary key.
- Preserve `clientReferenceId` locally for retry-safe sync.
- Use `meta.duplicatePrevented` to avoid duplicate success toasts.
- Recommendation `factors` can be shown as explanation chips or expandable details.
