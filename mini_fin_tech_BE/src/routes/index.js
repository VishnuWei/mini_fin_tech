const express = require("express");
const { profileController } = require("../controllers/profile-controller");
const { goalController } = require("../controllers/goal-controller");
const { expenseController } = require("../controllers/expense-controller");
const { dashboardController } = require("../controllers/dashboard-controller");

const router = express.Router();

router.put("/users/:userId/profile", profileController.upsertProfile);
router.get("/users/:userId/profile", profileController.getProfile);

router.put("/users/:userId/goals/current", goalController.upsertGoal);
router.get("/users/:userId/goals/current", goalController.getGoal);

router.post("/users/:userId/expenses", expenseController.createExpense);
router.get("/users/:userId/expenses", expenseController.listExpenses);
router.get("/users/:userId/expenses/:expenseId", expenseController.getExpense);
router.put("/users/:userId/expenses/:expenseId", expenseController.updateExpense);
router.delete("/users/:userId/expenses/:expenseId", expenseController.deleteExpense);

router.get("/users/:userId/dashboard", dashboardController.getSummary);
router.get("/users/:userId/recommendation", dashboardController.getRecommendation);
router.get("/users/:userId/insights", dashboardController.getInsights);

module.exports = router;
