#!/bin/sh

/app/telegram-bot-api/bin/telegram-bot-api \
  --api-id="$APP_ID" \
  --api-hash="$APP_HASH" \
  --http-port=${TELEGRAM_API_PORT} \
  --local \
  --http-stat-ip-address=0.0.0.0 \
  "$@" &

cd /app/proxy-server && \
PROXY_SERVER_HOST=$HOST \
PROXY_SERVER_PORT=$PORT \
npm start