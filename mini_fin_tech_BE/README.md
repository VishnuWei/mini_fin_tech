# Smart Spend & Auto-Save Backend

Node.js + Express backend for the Flutter take-home challenge, now wired for MongoDB persistence and local Docker-based setup.

## What is included

- User profile API for monthly income and currency
- Savings goal API
- Expense CRUD API
- Dashboard summary API
- Explainable smart auto-save recommendation engine
- Insights and budget alert engine
- Duplicate prevention via `Idempotency-Key`, `clientReferenceId`, and semantic duplicate checks
- Clear validation and error responses
- MongoDB persistence via Mongoose
- Docker Compose for MongoDB

## Tech stack

- Runtime: Node.js 24
- Framework: Express
- Database: MongoDB
- ODM: Mongoose
- Local infra: Docker Desktop + Docker Compose

## Run locally

### Option 1: local Node + Docker Mongo

1. Start MongoDB:

```bash
docker compose up -d mongo
```

2. Install dependencies:

```bash
npm install
```

3. Start the API:

```bash
npm start
```

API base URL:

```text
http://localhost:4000/api/v1
```

### Option 2: full Docker flow

```bash
docker compose up --build
```

## Environment

Copy `.env.example` to `.env` if you want custom values.

```env
PORT=4000
NODE_ENV=development
STORAGE_MODE=mongo
MONGODB_URI=mongodb://127.0.0.1:27017/smart-spend
DUPLICATE_EXPENSE_WINDOW_MINUTES=5
DEFAULT_DISCRETIONARY_CATEGORIES=food,shopping,entertainment,travel
```

For temporary no-DB development, you can set:

```env
STORAGE_MODE=memory
```

## Core endpoints

### Upsert profile

`PUT /users/:userId/profile`

```json
{
  "monthlyIncome": 60000,
  "currency": "INR"
}
```

### Get profile

`GET /users/:userId/profile`

### Upsert goal

`PUT /users/:userId/goals/current`

```json
{
  "goalName": "Emergency Fund",
  "targetAmount": 25000,
  "currentSavedAmount": 4000,
  "targetDate": "2026-08-30"
}
```

### Get goal

`GET /users/:userId/goals/current`

### Create expense

`POST /users/:userId/expenses`

Headers:

```text
Idempotency-Key: exp-001
```

Body:

```json
{
  "amount": 320,
  "category": "food",
  "merchant": "Swiggy",
  "description": "Dinner order",
  "date": "2026-04-02T19:30:00.000Z",
  "paymentMode": "upi",
  "notes": "Team dinner",
  "clientReferenceId": "mobile-1748"
}
```

### List expenses

`GET /users/:userId/expenses`

Optional query params:

- `category`
- `fromDate`
- `toDate`

### Update expense

`PUT /users/:userId/expenses/:expenseId`

### Delete expense

`DELETE /users/:userId/expenses/:expenseId`

### Dashboard

`GET /users/:userId/dashboard`

### Recommendation only

`GET /users/:userId/recommendation`

### Insights only

`GET /users/:userId/insights`

## API behavior notes

- Future-dated expenses are rejected.
- Goal dates in the past or today are rejected.
- Negative or zero values are rejected.
- Duplicate taps are handled through idempotency and client reference IDs.
- Near-identical expenses submitted in a short time window are deduplicated.
- Expense create responses include sync metadata:
  - `syncState`
  - `duplicatePrevented`
  - `idempotentReplay`

## Verification completed

The backend has been verified with:

- `npm test`
- MongoDB container started successfully via Docker Compose
- End-to-end smoke test for:
  - profile upsert
  - goal upsert
  - expense create
  - dashboard fetch

## Suggested Flutter integration

- Generate a `clientReferenceId` for every locally created expense.
- Add an `Idempotency-Key` header when retrying POSTs after network failures.
- Use `meta.syncState` and `meta.duplicatePrevented` to display sync status in the app.
- Cache dashboard and insights responses for offline read support.
- Use [docs/api_contract.md](D:\projects\mini_fin_tech_BE\docs\api_contract.md) as the FE contract reference.

## Project structure

```text
src/
  app.js
  server.js
  config/
  controllers/
  lib/
  middleware/
  models/
  repositories/
  routes/
  services/
  utils/
  validators/
```

## Useful commands

```bash
npm test
docker compose up -d mongo
docker compose down
```
