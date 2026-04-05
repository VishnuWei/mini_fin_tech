const mongoose = require("mongoose");

const userProfileSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true, index: true },
    monthlyIncome: { type: Number, required: true },
    currency: { type: String, required: true, default: "INR" }
  },
  {
    timestamps: true,
    versionKey: false
  }
);

const UserProfile = mongoose.model("UserProfile", userProfileSchema);

module.exports = { UserProfile };
