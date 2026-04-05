const { roundCurrency, sumAmounts } = require("../utils/money");
const { daysBetween, endOfMonth, startOfMonth } = require("../utils/date");
const { env } = require("../config/env");

function buildRecommendation({ profile, goal, expenses }) {
  if (!profile) {
    return {
      recommendedAmount: 0,
      confidence: "low",
      reason: "Set monthly income first to enable recommendations.",
      factors: []
    };
  }

  const now = new Date();
  const monthStart = startOfMonth(now);
  const monthEnd = endOfMonth(now);
  const monthExpenses = expenses.filter((expense) => new Date(expense.date) >= monthStart);
  const totalMonthSpend = sumAmounts(monthExpenses);
  const income = profile.monthlyIncome;
  const daysLeftInMonth = Math.max(daysBetween(now, monthEnd), 1);
  const daysInMonth = endOfMonth(now).getDate();
  const elapsedDays = Math.min(now.getDate(), daysInMonth);
  const idealSpendByNow = (income / daysInMonth) * elapsedDays;
  const spendingPressure = totalMonthSpend / Math.max(idealSpendByNow, 1);
  const discretionarySpend = sumAmounts(
    monthExpenses.filter((expense) => env.discretionaryCategories.includes(expense.category))
  );
  const discretionaryRatio = discretionarySpend / Math.max(totalMonthSpend, 1);

  let baseWeeklySave = income * 0.1;
  const factors = [
    {
      key: "base_rate",
      impact: roundCurrency(baseWeeklySave),
      note: "Starts from 10% of monthly income as a weekly save anchor."
    }
  ];

  if (spendingPressure > 1.1) {
    const reduction = roundCurrency(baseWeeklySave * 0.35);
    baseWeeklySave -= reduction;
    factors.push({
      key: "overspending_guard",
      impact: -reduction,
      note: "Monthly spend is ahead of the ideal pace, so the recommendation is reduced."
    });
  }

  if (discretionaryRatio > 0.45) {
    const reduction = roundCurrency(baseWeeklySave * 0.2);
    baseWeeklySave -= reduction;
    factors.push({
      key: "discretionary_spend_guard",
      impact: -reduction,
      note: "Discretionary categories are taking a large share of spend, so cash flow is protected."
    });
  }

  const last7Days = expenses.filter((expense) => Date.now() - new Date(expense.date).getTime() <= 7 * 24 * 60 * 60 * 1000);
  const previous7Days = expenses.filter((expense) => {
    const ageInMs = Date.now() - new Date(expense.date).getTime();
    return ageInMs > 7 * 24 * 60 * 60 * 1000 && ageInMs <= 14 * 24 * 60 * 60 * 1000;
  });

  const recentSpend = sumAmounts(last7Days);
  const previousSpend = sumAmounts(previous7Days);
  if (previousSpend > 0 && recentSpend > previousSpend * 1.25) {
    const reduction = roundCurrency(baseWeeklySave * 0.15);
    baseWeeklySave -= reduction;
    factors.push({
      key: "spike_detection",
      impact: -reduction,
      note: "Recent spending spiked versus the prior week, so the save amount is softened."
    });
  }

  if (goal) {
    const remainingGoal = Math.max(goal.targetAmount - goal.currentSavedAmount, 0);
    const weeksLeft = Math.max(Math.ceil(daysBetween(now, new Date(goal.targetDate)) / 7), 1);
    const goalPace = remainingGoal / weeksLeft;
    const topUp = roundCurrency(Math.min(goalPace * 0.35, income * 0.06));
    baseWeeklySave += topUp;
    factors.push({
      key: "goal_pacing",
      impact: topUp,
      note: "Goal pace increases the recommendation when the target date is getting closer."
    });
  }

  const projectedMonthEndBalance = income - totalMonthSpend;
  const safeWeeklyCap = Math.max(projectedMonthEndBalance / Math.max(Math.ceil(daysLeftInMonth / 7), 1), 0);
  const recommendedAmount = roundCurrency(Math.max(Math.min(baseWeeklySave, safeWeeklyCap), 0));

  return {
    recommendedAmount,
    confidence: recommendedAmount > 0 ? "medium" : "low",
    reason:
      recommendedAmount > 0
        ? "Recommendation balances income, spending pace, discretionary spend, and savings-goal urgency."
        : "Current spending pattern leaves little safe room for an automatic save this week.",
    factors,
    diagnostics: {
      totalMonthSpend,
      spendingPressure: roundCurrency(spendingPressure),
      discretionaryRatio: roundCurrency(discretionaryRatio),
      projectedMonthEndBalance: roundCurrency(projectedMonthEndBalance)
    }
  };
}

module.exports = { buildRecommendation };
