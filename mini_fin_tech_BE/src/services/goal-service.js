const { repository } = require("../repositories");
const { validateGoalInput } = require("../validators/goal-validator");

async function upsertGoal(userId, payload) {
  const input = validateGoalInput(payload);
  return repository.upsertGoal(userId, {
    userId,
    goalName: input.goalName,
    targetAmount: input.targetAmount,
    currentSavedAmount: input.currentSavedAmount,
    targetDate: input.targetDate
  });
}

async function getGoal(userId) {
  return repository.getGoal(userId);
}

module.exports = { upsertGoal, getGoal };
