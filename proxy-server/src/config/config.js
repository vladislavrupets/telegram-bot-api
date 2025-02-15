const dotenv = require("dotenv");
const path = require("path");

dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const proxyServer = {
  host: process.env.HOST,
  port: process.env.PORT,
};

const telegramApi = {
  host: process.env.HOST,
  port: process.env.TELEGRAM_API_PORT,
};

module.exports = {
  proxyServer,
  telegramApi,
};
