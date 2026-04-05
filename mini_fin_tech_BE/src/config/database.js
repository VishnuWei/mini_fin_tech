const mongoose = require("mongoose");
const { env } = require("./env");

async function connectDatabase() {
  if (env.storageMode !== "mongo") {
    return { mode: "memory" };
  }

  await mongoose.connect(env.mongoUri, {
    serverSelectionTimeoutMS: 5000
  });

  return { mode: "mongo" };
}

module.exports = { connectDatabase };
