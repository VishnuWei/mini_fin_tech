const { ApiError } = require("../lib/api-error");
const { normalizeText } = require("../utils/serializers");

function validateProfileInput(payload) {
  const monthlyIncome = Number(payload.monthlyIncome);

  if (!Number.isFinite(monthlyIncome) || monthlyIncome <= 0) {
    throw new ApiError(400, "monthlyIncome must be greater than 0");
  }

  const currency = normalizeText(payload.currency || "INR").toUpperCase();

  return {
    monthlyIncome,
    currency
  };
}

module.exports = { validateProfileInput };
