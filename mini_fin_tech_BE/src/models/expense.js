const mongoose = require("mongoose");

const expenseSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, index: true },
    amount: { type: Number, required: true },
    category: { type: String, required: true, index: true },
    merchant: { type: String, required: true },
    description: { type: String, required: true },
    date: { type: Date, required: true, index: true },
    paymentMode: { type: String, required: true },
    notes: { type: String, default: "" },
    clientReferenceId: { type: String, default: null },
    syncStatus: { type: String, default: "synced" }
  },
  {
    timestamps: true,
    versionKey: false,
    toJSON: {
      transform: (_doc, ret) => {
        ret.id = ret._id.toString();
        delete ret._id;
        return ret;
      }
    }
  }
);

expenseSchema.index({ userId: 1, clientReferenceId: 1 }, { unique: true, sparse: true });

const Expense = mongoose.model("Expense", expenseSchema);

module.exports = { Expense };
