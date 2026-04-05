# AI Usage

## Tools used

- ChatGPT / Codex
  Helped scaffold the backend structure, validation flow, MongoDB migration, and documentation.

## Where AI helped

- Turning the challenge statement into a modular backend structure
- Drafting a first-pass rule engine for auto-save recommendations
- Generating controller/service boilerplate faster
- Converting the backend from in-memory scaffolding to MongoDB-backed persistence

## Examples where AI output needed correction

1. Initial goal validation logic was too permissive around target dates.
   I corrected it to reject invalid, same-day, and past goal dates after normalizing day boundaries.

2. The first MongoDB integration pass introduced async service methods, but some controllers were still treating them synchronously.
   I fixed the controllers to `await` service results and reran end-to-end verification.

## One design decision that was mine

I chose a layered `controller -> service -> repository` structure with a `STORAGE_MODE` switch so the app can run with MongoDB for submission quality while still supporting a lighter memory mode for emergency local fallback.
