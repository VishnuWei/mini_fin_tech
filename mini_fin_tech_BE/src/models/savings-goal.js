const mongoose = require("mongoose");

const savingsGoalSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true, index: true },
    goalName: { type: String, required: true },
    targetAmount: { type: Number, required: true },
    currentSavedAmount: { type: Number, required: true, default: 0 },
    targetDate: { type: Date, required: true }
  },
  {
    timestamps: true,
    versionKey: false
  }
);

const SavingsGoal = mongoose.model("SavingsGoal", savingsGoalSchema);

module.exports = { SavingsGoal };
