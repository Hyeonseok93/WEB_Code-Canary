#!/bin/sh
set -eu

# Seed a writable copy under tmpfs so later entrypoints can edit conf
# while the container rootfs stays read-only.
SRC="/etc/nginx/nginx.conf"
CONF="/tmp/nginx.conf"
if [ ! -f "$CONF" ]; then
  cp "$SRC" "$CONF"
fi
