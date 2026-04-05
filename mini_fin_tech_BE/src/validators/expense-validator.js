const { ApiError } = require("../lib/api-error");
const { normalizeCategory, normalizeText } = require("../utils/serializers");

function validateExpenseInput(payload, { isUpdate = false } = {}) {
  const amount = payload.amount === undefined ? undefined : Number(payload.amount);
  const category = payload.category === undefined ? undefined : normalizeCategory(payload.category);
  const merchant = payload.merchant === undefined ? undefined : normalizeText(payload.merchant);
  const description = payload.description === undefined ? undefined : normalizeText(payload.description);
  const paymentMode = payload.paymentMode === undefined ? undefined : normalizeText(payload.paymentMode).toLowerCase();
  const notes = payload.notes === undefined ? undefined : normalizeText(payload.notes);
  const date = payload.date === undefined ? undefined : new Date(payload.date);
  const clientReferenceId =
    payload.clientReferenceId === undefined ? undefined : normalizeText(payload.clientReferenceId);

  if (!isUpdate || payload.amount !== undefined) {
    if (!Number.isFinite(amount) || amount <= 0) {
      throw new ApiError(400, "amount must be greater than 0");
    }
  }

  if (!isUpdate || payload.category !== undefined) {
    if (!category) {
      throw new ApiError(400, "category is required");
    }
  }

  if (!isUpdate || payload.merchant !== undefined) {
    if (!merchant) {
      throw new ApiError(400, "merchant is required");
    }
  }

  if (!isUpdate || payload.date !== undefined) {
    if (!(date instanceof Date) || Number.isNaN(date.getTime())) {
      throw new ApiError(400, "date must be a valid date");
    }

    if (date.getTime() > Date.now()) {
      throw new ApiError(400, "date cannot be in the future");
    }
  }

  if (!isUpdate || payload.paymentMode !== undefined) {
    if (!paymentMode) {
      throw new ApiError(400, "paymentMode is required");
    }
  }

  return {
    ...(amount !== undefined ? { amount } : {}),
    ...(category !== undefined ? { category } : {}),
    ...(merchant !== undefined ? { merchant } : {}),
    ...(description !== undefined ? { description } : {}),
    ...(date !== undefined ? { date: date.toISOString() } : {}),
    ...(paymentMode !== undefined ? { paymentMode } : {}),
    ...(notes !== undefined ? { notes } : {}),
    ...(clientReferenceId !== undefined ? { clientReferenceId } : {})
  };
}

module.exports = { validateExpenseInput };
