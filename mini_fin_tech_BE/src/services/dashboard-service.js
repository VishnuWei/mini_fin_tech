const { ApiError } = require("../lib/api-error");
const { repository } = require("../repositories");
const { startOfWeek, startOfMonth } = require("../utils/date");
const { sumAmounts, roundCurrency } = require("../utils/money");
const { buildRecommendation } = require("./recommendation-service");
const { buildInsights } = require("./insight-service");

function categoryBreakdown(expenses) {
  const totals = expenses.reduce((acc, expense) => {
    acc[expense.category] = (acc[expense.category] || 0) + expense.amount;
    return acc;
  }, {});

  return Object.entries(totals)
    .map(([category, amount]) => ({ category, amount: roundCurrency(amount) }))
    .sort((a, b) => b.amount - a.amount);
}

function buildAlerts({ profile, expenses, recommendation }) {
  const alerts = [];
  const monthlyBudget = profile?.monthlyIncome || 0;
  const categoryTotals = expenses.reduce((acc, expense) => {
    acc[expense.category] = (acc[expense.category] || 0) + expense.amount;
    return acc;
  }, {});

  Object.entries(categoryTotals).forEach(([category, total]) => {
    const categoryBudget = monthlyBudget * 0.25;
    if (categoryBudget > 0 && total >= categoryBudget * 0.8) {
      alerts.push({
        code: "CATEGORY_BUDGET_80",
        message: `${category} is above 80% of its notional monthly budget.`,
        severity: "warning"
      });
    }
  });

  if (recommendation.diagnostics?.discretionaryRatio > 0.45) {
    alerts.push({
      code: "DISCRETIONARY_SPEND_HIGH",
      message: "Discretionary spend is high, so auto-save has been reduced for safety.",
      severity: "warning"
    });
  }

  return alerts;
}

async function getSummary(userId) {
  const profile = await repository.getProfile(userId);
  const goal = await repository.getGoal(userId);
  const expenses = await repository.getExpensesByUser(userId);

  if (!profile) {
    throw new ApiError(404, "User profile not found");
  }

  const now = new Date();
  const weekExpenses = expenses.filter((expense) => new Date(expense.date) >= startOfWeek(now));
  const monthExpenses = expenses.filter((expense) => new Date(expense.date) >= startOfMonth(now));
  const totalSpentWeek = sumAmounts(weekExpenses);
  const totalSpentMonth = sumAmounts(monthExpenses);
  const remainingMonthlyBudget = roundCurrency(profile.monthlyIncome - totalSpentMonth);
  const recommendation = buildRecommendation({ profile, goal, expenses });
  const insights = buildInsights({ profile, goal, expenses, recommendation });

  return {
    profile,
    goal,
    summary: {
      totalSpentWeek,
      totalSpentMonth,
      remainingMonthlyBudget,
      categoryBreakdown: categoryBreakdown(monthExpenses),
      expenseCount: expenses.length
    },
    savingsGoalProgress: goal
      ? {
          goalName: goal.goalName,
          currentSavedAmount: goal.currentSavedAmount,
          targetAmount: goal.targetAmount,
          progressPercent: roundCurrency((goal.currentSavedAmount / Math.max(goal.targetAmount, 1)) * 100),
          targetDate: goal.targetDate
        }
      : null,
    recommendation,
    alerts: buildAlerts({ profile, expenses: monthExpenses, recommendation }),
    insights
  };
}

async function getRecommendation(userId) {
  const profile = await repository.getProfile(userId);
  const goal = await repository.getGoal(userId);
  const expenses = await repository.getExpensesByUser(userId);
  return buildRecommendation({ profile, goal, expenses });
}

async function getInsights(userId) {
  const profile = await repository.getProfile(userId);
  const goal = await repository.getGoal(userId);
  const expenses = await repository.getExpensesByUser(userId);
  const recommendation = buildRecommendation({ profile, goal, expenses });
  return buildInsights({ profile, goal, expenses, recommendation });
}

module.exports = { getSummary, getRecommendation, getInsights };
