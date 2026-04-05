const crypto = require("crypto");

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

class MemoryDb {
  constructor() {
    this.userProfiles = new Map();
    this.userGoals = new Map();
    this.expenses = new Map();
    this.expensesByUser = new Map();
    this.idempotencyKeys = new Map();
  }

  generateId(prefix) {
    return `${prefix}_${crypto.randomUUID()}`;
  }

  upsertProfile(userId, profile) {
    this.userProfiles.set(userId, clone(profile));
    return clone(profile);
  }

  getProfile(userId) {
    return clone(this.userProfiles.get(userId) || null);
  }

  upsertGoal(userId, goal) {
    this.userGoals.set(userId, clone(goal));
    return clone(goal);
  }

  getGoal(userId) {
    return clone(this.userGoals.get(userId) || null);
  }

  saveExpense(expense) {
    this.expenses.set(expense.id, clone(expense));

    const ids = this.expensesByUser.get(expense.userId) || [];
    if (!ids.includes(expense.id)) {
      ids.push(expense.id);
      this.expensesByUser.set(expense.userId, ids);
    }

    return clone(expense);
  }

  getExpense(expenseId) {
    return clone(this.expenses.get(expenseId) || null);
  }

  getExpensesByUser(userId) {
    const ids = this.expensesByUser.get(userId) || [];
    return ids
      .map((id) => this.expenses.get(id))
      .filter(Boolean)
      .map((expense) => clone(expense));
  }

  deleteExpense(expenseId) {
    const expense = this.expenses.get(expenseId);
    if (!expense) {
      return null;
    }

    this.expenses.delete(expenseId);
    const ids = this.expensesByUser.get(expense.userId) || [];
    this.expensesByUser.set(
      expense.userId,
      ids.filter((id) => id !== expenseId)
    );

    return clone(expense);
  }

  getIdempotencyRecord(userId, key) {
    const record = this.idempotencyKeys.get(`${userId}:${key}`);
    return clone(record || null);
  }

  saveIdempotencyRecord(userId, key, value) {
    this.idempotencyKeys.set(`${userId}:${key}`, clone(value));
  }
}

const db = new MemoryDb();

module.exports = { db };
