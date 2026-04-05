const test = require("node:test");
const assert = require("node:assert/strict");
const { buildRecommendation } = require("../src/services/recommendation-service");

test("recommendation is reduced when spending pressure is high", () => {
  const profile = { monthlyIncome: 50000 };
  const goal = {
    targetAmount: 30000,
    currentSavedAmount: 5000,
    targetDate: "2026-08-30T00:00:00.000Z"
  };

  const expenses = [
    { amount: 18000, category: "shopping", date: new Date().toISOString() },
    { amount: 15000, category: "food", date: new Date().toISOString() }
  ];

  const result = buildRecommendation({ profile, goal, expenses });

  assert.ok(result.recommendedAmount >= 0);
  assert.ok(result.factors.some((factor) => factor.key === "overspending_guard"));
});
