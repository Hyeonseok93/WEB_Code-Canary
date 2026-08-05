#!/bin/sh
set -eu

CONF="/tmp/nginx.conf"

if [ "${NGINX_HSTS_ENABLED:-false}" = "true" ]; then
  REPL='        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;'
else
  REPL=""
fi

awk -v repl="$REPL" '{ gsub(/# HSTS_INSERT/, repl); print }' "$CONF" > /tmp/nginx.conf.new
mv /tmp/nginx.conf.new "$CONF"
