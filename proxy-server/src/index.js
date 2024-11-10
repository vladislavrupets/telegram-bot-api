const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");
const { proxyServer, telegramApi } = require("./config/config");
const fileProxyRoutes = require("./routes/fileProxyRoutes");

const app = express();

app.use("/file-proxy", fileProxyRoutes);

app.use(
  "/telegram-api",
  createProxyMiddleware({
    target: `http://${telegramApi.host}:${telegramApi.port}`,
    changeOrigin: true,
    logLevel: "debug",
    pathRewrite: {
      "^/telegram-api": "",
    },
  })
);

app.listen({ port: proxyServer.port, host: proxyServer.host }, () => {
  console.log(`Proxy server running on port ${proxyServer.port}`);
});
