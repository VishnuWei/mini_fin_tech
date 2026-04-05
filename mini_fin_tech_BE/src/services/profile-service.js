const { repository } = require("../repositories");
const { validateProfileInput } = require("../validators/profile-validator");

async function upsertProfile(userId, payload) {
  const input = validateProfileInput(payload);
  return repository.upsertProfile(userId, {
    userId,
    monthlyIncome: input.monthlyIncome,
    currency: input.currency
  });
}

async function getProfile(userId) {
  return repository.getProfile(userId);
}

module.exports = { upsertProfile, getProfile };
