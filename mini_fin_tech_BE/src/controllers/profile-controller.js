const { asyncHandler } = require("../lib/async-handler");
const { sendSuccess } = require("../lib/response");
const profileService = require("../services/profile-service");

const profileController = {
  upsertProfile: asyncHandler(async (req, res) => {
    const profile = await profileService.upsertProfile(req.params.userId, req.body);
    return sendSuccess(res, 200, profile);
  }),

  getProfile: asyncHandler(async (req, res) => {
    const profile = await profileService.getProfile(req.params.userId);
    return sendSuccess(res, 200, profile);
  })
};

module.exports = { profileController };
