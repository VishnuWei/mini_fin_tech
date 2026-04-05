const { asyncHandler } = require("../lib/async-handler");
const { sendSuccess } = require("../lib/response");
const goalService = require("../services/goal-service");

const goalController = {
  upsertGoal: asyncHandler(async (req, res) => {
    const goal = await goalService.upsertGoal(req.params.userId, req.body);
    return sendSuccess(res, 200, goal);
  }),

  getGoal: asyncHandler(async (req, res) => {
    const goal = await goalService.getGoal(req.params.userId);
    return sendSuccess(res, 200, goal);
  })
};

module.exports = { goalController };
