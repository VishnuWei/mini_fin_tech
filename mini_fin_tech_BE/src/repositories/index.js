const { env } = require("../config/env");
const { db } = require("./memory-db");
const { mongoRepository } = require("./mongo-repository");

const repository = env.storageMode === "mongo" ? mongoRepository : db;

module.exports = { repository };
