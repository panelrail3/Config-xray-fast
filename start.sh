#!/bin/sh
set -eu
mkdir -p /app/runtime /app/data
rm -f /run/nginx.pid
node /app/server.js &
NODE_PID=$!
# Generate initial config using the public host if available.
HOST="${RAILWAY_PUBLIC_DOMAIN:-${RAILWAY_PUBLIC_DOMAIN:-YOUR-RAILWAY-DOMAIN}}"
# Server generates the canonical config at startup; nginx starts after panel.
sleep 1
/opt/xray/xray run -test -config /app/runtime/xray.json >/app/runtime/xray-test.log 2>&1 || { cat /app/runtime/xray-test.log; exit 1; }
nginx -c /app/nginx.conf -g 'daemon off;' &
NGINX_PID=$!
trap 'kill $NGINX_PID $NODE_PID 2>/dev/null || true' INT TERM EXIT
/opt/xray/xray run -config /app/runtime/xray.json >/app/runtime/xray-stdout.log 2>/app/runtime/xray-stderr.log &
XRAY_PID=$!
trap 'kill $XRAY_PID $NGINX_PID $NODE_PID 2>/dev/null || true' INT TERM EXIT
wait -n $NODE_PID $NGINX_PID $XRAY_PID
exit $?
