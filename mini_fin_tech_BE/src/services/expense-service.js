const { ApiError } = require("../lib/api-error");
const { repository } = require("../repositories");
const { env } = require("../config/env");
const { validateExpenseInput } = require("../validators/expense-validator");
const { normalizeCategory } = require("../utils/serializers");

function isDuplicate(existingExpense, incomingExpense) {
  return (
    Number(existingExpense.amount) === Number(incomingExpense.amount) &&
    normalizeCategory(existingExpense.category) === normalizeCategory(incomingExpense.category) &&
    String(existingExpense.merchant).toLowerCase() === String(incomingExpense.merchant).toLowerCase() &&
    String(existingExpense.paymentMode).toLowerCase() === String(incomingExpense.paymentMode).toLowerCase() &&
    new Date(existingExpense.date).toISOString() === new Date(incomingExpense.date).toISOString()
  );
}

async function findSemanticDuplicate(userId, incomingExpense) {
  const allExpenses = await repository.getExpensesByUser(userId);
  const now = Date.now();
  const windowMs = env.duplicateExpenseWindowMinutes * 60 * 1000;

  return allExpenses.find((expense) => {
    const createdAt = new Date(expense.createdAt).getTime();
    return now - createdAt <= windowMs && isDuplicate(expense, incomingExpense);
  });
}

async function createExpense(userId, payload, idempotencyKey) {
  const input = validateExpenseInput(payload);

  if (idempotencyKey) {
    const existingRecord = await repository.getIdempotencyRecord(userId, idempotencyKey);
    if (existingRecord) {
      return {
        expense: existingRecord.expense,
        meta: {
          idempotentReplay: true,
          duplicatePrevented: true,
          syncState: "synced"
        }
      };
    }
  }

  if (input.clientReferenceId) {
    const match = (await repository.getExpensesByUser(userId)).find(
      (expense) => expense.clientReferenceId && expense.clientReferenceId === input.clientReferenceId
    );

    if (match) {
      return {
        expense: match,
        meta: {
          idempotentReplay: true,
          duplicatePrevented: true,
          syncState: "synced"
        }
      };
    }
  }

  const duplicate = await findSemanticDuplicate(userId, input);
  if (duplicate) {
    return {
      expense: duplicate,
      meta: {
        idempotentReplay: false,
        duplicatePrevented: true,
        syncState: "synced"
      }
    };
  }

  const expense = await repository.saveExpense({
    userId,
    amount: input.amount,
    category: input.category,
    merchant: input.merchant,
    description: input.description || input.merchant,
    date: input.date,
    paymentMode: input.paymentMode,
    notes: input.notes || "",
    clientReferenceId: input.clientReferenceId || null,
    syncStatus: "synced"
  });

  if (idempotencyKey) {
    await repository.saveIdempotencyRecord(userId, idempotencyKey, { expense });
  }

  return {
    expense,
    meta: {
      idempotentReplay: false,
      duplicatePrevented: false,
      syncState: "synced"
    }
  };
}

async function listExpenses(userId, query) {
  let items = await repository.getExpensesByUser(userId);

  if (query.category) {
    items = items.filter((expense) => expense.category === normalizeCategory(query.category));
  }

  if (query.fromDate) {
    const from = new Date(query.fromDate).getTime();
    items = items.filter((expense) => new Date(expense.date).getTime() >= from);
  }

  if (query.toDate) {
    const to = new Date(query.toDate).getTime();
    items = items.filter((expense) => new Date(expense.date).getTime() <= to);
  }

  return items.sort((a, b) => new Date(b.date) - new Date(a.date));
}

async function getExpense(userId, expenseId) {
  const expense = await repository.getExpense(expenseId);

  if (!expense || expense.userId !== userId) {
    throw new ApiError(404, "Expense not found");
  }

  return expense;
}

async function updateExpense(userId, expenseId, payload) {
  const existing = await getExpense(userId, expenseId);
  const input = validateExpenseInput(payload, { isUpdate: true });

  return repository.saveExpense({
    ...existing,
    ...input,
    updatedAt: new Date().toISOString()
  });
}

async function deleteExpense(userId, expenseId) {
  const expense = await getExpense(userId, expenseId);
  await repository.deleteExpense(expense.id);
  return expense;
}

module.exports = {
  createExpense,
  listExpenses,
  getExpense,
  updateExpense,
  deleteExpense
};
