const mongoose = require("mongoose");

const idempotencyKeySchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },
    key: { type: String, required: true },
    expenseId: { type: String, required: true }
  },
  {
    timestamps: true,
    versionKey: false
  }
);

idempotencyKeySchema.index({ userId: 1, key: 1 }, { unique: true });

const IdempotencyKey = mongoose.model("IdempotencyKey", idempotencyKeySchema);

module.exports = { IdempotencyKey };
