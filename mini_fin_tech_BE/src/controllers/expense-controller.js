const { asyncHandler } = require("../lib/async-handler");
const { sendSuccess } = require("../lib/response");
const expenseService = require("../services/expense-service");

const expenseController = {
  createExpense: asyncHandler(async (req, res) => {
    const idempotencyKey = req.header("Idempotency-Key");
    const result = await expenseService.createExpense(req.params.userId, req.body, idempotencyKey);
    const statusCode = result.meta.idempotentReplay || result.meta.duplicatePrevented ? 200 : 201;
    return sendSuccess(res, statusCode, result.expense, result.meta);
  }),

  listExpenses: asyncHandler(async (req, res) => {
    const expenses = await expenseService.listExpenses(req.params.userId, req.query);
    return sendSuccess(res, 200, expenses, { count: expenses.length });
  }),

  getExpense: asyncHandler(async (req, res) => {
    const expense = await expenseService.getExpense(req.params.userId, req.params.expenseId);
    return sendSuccess(res, 200, expense);
  }),

  updateExpense: asyncHandler(async (req, res) => {
    const expense = await expenseService.updateExpense(req.params.userId, req.params.expenseId, req.body);
    return sendSuccess(res, 200, expense);
  }),

  deleteExpense: asyncHandler(async (req, res) => {
    const expense = await expenseService.deleteExpense(req.params.userId, req.params.expenseId);
    return sendSuccess(res, 200, expense);
  })
};

module.exports = { expenseController };
