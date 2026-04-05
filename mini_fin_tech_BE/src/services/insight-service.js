const { sumAmounts, roundCurrency } = require("../utils/money");
const { startOfWeek } = require("../utils/date");
const { env } = require("../config/env");

function groupByCategory(expenses) {
  return expenses.reduce((acc, expense) => {
    acc[expense.category] = (acc[expense.category] || 0) + expense.amount;
    return acc;
  }, {});
}

function buildInsights({ profile, goal, expenses, recommendation }) {
  const now = new Date();
  const weekStart = startOfWeek(now);
  const lastWeekStart = new Date(weekStart);
  lastWeekStart.setDate(lastWeekStart.getDate() - 7);

  const thisWeekExpenses = expenses.filter((expense) => new Date(expense.date) >= weekStart);
  const lastWeekExpenses = expenses.filter((expense) => {
    const expenseDate = new Date(expense.date);
    return expenseDate >= lastWeekStart && expenseDate < weekStart;
  });

  const thisWeekByCategory = groupByCategory(thisWeekExpenses);
  const lastWeekByCategory = groupByCategory(lastWeekExpenses);
  const insights = [];

  Object.entries(thisWeekByCategory).forEach(([category, total]) => {
    const previous = lastWeekByCategory[category] || 0;
    if (previous > 0 && total > previous * 1.2) {
      const increase = roundCurrency(((total - previous) / previous) * 100);
      insights.push({
        type: "spend_spike",
        severity: "medium",
        message: `${category} spend is ${increase}% higher than last week.`
      });
    }
  });

  if (profile) {
    const discretionarySpend = sumAmounts(
      expenses.filter((expense) => env.discretionaryCategories.includes(expense.category))
    );
    const totalSpend = sumAmounts(expenses);
    const discretionaryRatio = discretionarySpend / Math.max(totalSpend, 1);

    if (discretionaryRatio > 0.4) {
      const possibleSave = roundCurrency(profile.monthlyIncome * 0.08);
      insights.push({
        type: "budget_opportunity",
        severity: "medium",
        message: `You can still save INR ${possibleSave} this month if you reduce discretionary spend.`
      });
    }
  }

  insights.push({
    type: "autosave",
    severity: recommendation.recommendedAmount > 0 ? "info" : "warning",
    message: `Recommended auto-save this week: INR ${recommendation.recommendedAmount}.`
  });

  if (goal) {
    const remaining = roundCurrency(Math.max(goal.targetAmount - goal.currentSavedAmount, 0));
    insights.push({
      type: "goal_status",
      severity: remaining > 0 ? "info" : "success",
      message:
        remaining > 0
          ? `You still need INR ${remaining} to reach "${goal.goalName}".`
          : `Savings goal "${goal.goalName}" has been achieved.`
    });
  }

  return insights.slice(0, 5);
}

module.exports = { buildInsights };
