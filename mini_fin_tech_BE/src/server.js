const { createApp } = require("./app");
const { env } = require("./config/env");
const { connectDatabase } = require("./config/database");

async function bootstrap() {
  await connectDatabase();

  const app = createApp();
  app.listen(env.port, () => {
    console.log(`Smart Spend API listening on port ${env.port}`);
  });
}

bootstrap().catch((error) => {
  console.error("Failed to start server", error);
  process.exit(1);
});
