const mongoose = require("mongoose");
const { UserProfile } = require("../models/user-profile");
const { SavingsGoal } = require("../models/savings-goal");
const { Expense } = require("../models/expense");
const { IdempotencyKey } = require("../models/idempotency-key");

function serialize(document) {
  if (!document) {
    return null;
  }

  const plain = document.toObject
    ? document.toObject({ versionKey: false })
    : { ...document };

  if (plain._id && !plain.id) {
    plain.id = plain._id.toString();
  }

  delete plain._id;
  return JSON.parse(JSON.stringify(plain));
}

const mongoRepository = {
  async upsertProfile(userId, profile) {
    const doc = await UserProfile.findOneAndUpdate(
      { userId },
      {
        userId,
        monthlyIncome: profile.monthlyIncome,
        currency: profile.currency
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    return serialize(doc);
  },

  async getProfile(userId) {
    return serialize(await UserProfile.findOne({ userId }));
  },

  async upsertGoal(userId, goal) {
    const doc = await SavingsGoal.findOneAndUpdate(
      { userId },
      {
        userId,
        goalName: goal.goalName,
        targetAmount: goal.targetAmount,
        currentSavedAmount: goal.currentSavedAmount,
        targetDate: goal.targetDate
      },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );

    return serialize(doc);
  },

  async getGoal(userId) {
    return serialize(await SavingsGoal.findOne({ userId }));
  },

  async saveExpense(expense) {
    if (expense.id) {
      const payload = { ...expense };
      delete payload.id;
      const doc = await Expense.findOneAndUpdate({ _id: expense.id }, payload, {
        new: true,
        overwrite: true
      });
      return serialize(doc);
    }

    const doc = await Expense.create(expense);
    return serialize(doc);
  },

  async getExpense(expenseId) {
    if (!mongoose.Types.ObjectId.isValid(expenseId)) {
      return null;
    }

    return serialize(await Expense.findById(expenseId));
  },

  async getExpensesByUser(userId) {
    const docs = await Expense.find({ userId }).sort({ date: -1, createdAt: -1 });
    return docs.map((doc) => serialize(doc));
  },

  async deleteExpense(expenseId) {
    if (!mongoose.Types.ObjectId.isValid(expenseId)) {
      return null;
    }

    return serialize(await Expense.findByIdAndDelete(expenseId));
  },

  async getIdempotencyRecord(userId, key) {
    const record = await IdempotencyKey.findOne({ userId, key });
    if (!record) {
      return null;
    }

    const expense = await Expense.findById(record.expenseId);
    if (!expense) {
      return null;
    }

    return { expense: serialize(expense) };
  },

  async saveIdempotencyRecord(userId, key, value) {
    await IdempotencyKey.findOneAndUpdate(
      { userId, key },
      { userId, key, expenseId: value.expense.id },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
  }
};

module.exports = { mongoRepository };
