const { asyncHandler } = require("../lib/async-handler");
const { sendSuccess } = require("../lib/response");
const dashboardService = require("../services/dashboard-service");

const dashboardController = {
  getSummary: asyncHandler(async (req, res) => {
    const summary = await dashboardService.getSummary(req.params.userId);
    return sendSuccess(res, 200, summary);
  }),

  getRecommendation: asyncHandler(async (req, res) => {
    const recommendation = await dashboardService.getRecommendation(req.params.userId);
    return sendSuccess(res, 200, recommendation);
  }),

  getInsights: asyncHandler(async (req, res) => {
    const insights = await dashboardService.getInsights(req.params.userId);
    return sendSuccess(res, 200, insights);
  })
};

module.exports = { dashboardController };
