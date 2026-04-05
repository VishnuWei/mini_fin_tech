const { ApiError } = require("../lib/api-error");
const { normalizeText } = require("../utils/serializers");

function validateGoalInput(payload) {
  const goalName = normalizeText(payload.goalName);
  const targetAmount = Number(payload.targetAmount);
  const currentSavedAmount = Number(payload.currentSavedAmount || 0);
  const targetDate = normalizeText(payload.targetDate);

  if (!goalName) {
    throw new ApiError(400, "goalName is required");
  }

  if (!Number.isFinite(targetAmount) || targetAmount <= 0) {
    throw new ApiError(400, "targetAmount must be greater than 0");
  }

  if (!Number.isFinite(currentSavedAmount) || currentSavedAmount < 0) {
    throw new ApiError(400, "currentSavedAmount must be 0 or greater");
  }

  if (!targetDate) {
    throw new ApiError(400, "targetDate is required");
  }

  const target = new Date(targetDate);
  if (Number.isNaN(target.getTime())) {
    throw new ApiError(400, "targetDate must be a valid date");
  }

  const now = new Date();
  target.setHours(0, 0, 0, 0);
  now.setHours(0, 0, 0, 0);

  if (target.getTime() <= now.getTime()) {
    throw new ApiError(400, "targetDate must be in the future");
  }

  return {
    goalName,
    targetAmount,
    currentSavedAmount,
    targetDate: target.toISOString()
  };
}

module.exports = { validateGoalInput };
