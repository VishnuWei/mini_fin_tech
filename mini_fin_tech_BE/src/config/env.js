const fs = require("fs");
const path = require("path");

function loadEnvFile() {
  const envPath = path.resolve(__dirname, "../../.env");

  if (!fs.existsSync(envPath)) {
    return;
  }

  const envContents = fs.readFileSync(envPath, "utf8");

  for (const rawLine of envContents.split(/\r?\n/)) {
    const line = rawLine.trim();

    if (!line || line.startsWith("#")) {
      continue;
    }

    const separatorIndex = line.indexOf("=");

    if (separatorIndex === -1) {
      continue;
    }

    const key = line.slice(0, separatorIndex).trim();
    const value = line.slice(separatorIndex + 1).trim().replace(/^['"]|['"]$/g, "");

    if (key && process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

function parseNumber(value, fallback) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : fallback;
}

loadEnvFile();

const env = {
  port: parseNumber(process.env.PORT, 4000),
  nodeEnv: process.env.NODE_ENV || "development",
  storageMode: (process.env.STORAGE_MODE || "mongo").toLowerCase(),
  mongoUri: process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/smart-spend",
  duplicateExpenseWindowMinutes: parseNumber(process.env.DUPLICATE_EXPENSE_WINDOW_MINUTES, 5),
  discretionaryCategories: (process.env.DEFAULT_DISCRETIONARY_CATEGORIES || "food,shopping,entertainment,travel")
    .split(",")
    .map((item) => item.trim().toLowerCase())
    .filter(Boolean)
};

module.exports = { env };
