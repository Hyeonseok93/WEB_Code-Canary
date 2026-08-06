# Stage 1: Build React app inside Docker (repo root .env supplies VITE_*)
FROM node:22-alpine@sha256:968df39aedcea65eeb078fb336ed7191baf48f972b4479711397108be0966920 AS build

COPY .env /app/.env
WORKDIR /app/Canary-frontend

COPY Canary-frontend/package.json Canary-frontend/package-lock.json ./
RUN npm ci

COPY Canary-frontend/index.html Canary-frontend/vite.config.ts Canary-frontend/tsconfig.json Canary-frontend/tsconfig.app.json Canary-frontend/tsconfig.node.json Canary-frontend/eslint.config.js ./
COPY Canary-frontend/public ./public
COPY Canary-frontend/src ./src

RUN npm run build

# Stage 2: Serve with non-root Nginx (listens on 8080)
FROM nginxinc/nginx-unprivileged:stable-alpine@sha256:37f356a5eba5d187365b4f59cd6cc29f1f922ad18146d554b576a80983377e6a

COPY --chown=nginx:nginx --from=build /app/Canary-frontend/dist /usr/share/nginx/html
COPY Canary-frontend/nginx.conf /etc/nginx/nginx.conf
# --chmod avoids RUN chmod (fails on Windows Docker bind/NTFS builds)
COPY --chmod=755 Canary-frontend/docker-entrypoint.d/00-seed-nginx-conf.sh /docker-entrypoint.d/00-seed-nginx-conf.sh
COPY --chmod=755 Canary-frontend/docker-entrypoint.d/30-backend-upstream.sh /docker-entrypoint.d/30-backend-upstream.sh
COPY --chmod=755 Canary-frontend/docker-entrypoint.d/35-real-ip.sh /docker-entrypoint.d/35-real-ip.sh
COPY --chmod=755 Canary-frontend/docker-entrypoint.d/40-hsts.sh /docker-entrypoint.d/40-hsts.sh
COPY --chmod=755 Canary-frontend/docker-entrypoint.d/50-operator-allowlist.sh /docker-entrypoint.d/50-operator-allowlist.sh
# Strip Windows CRLF so Alpine can exec entrypoint scripts.
USER root
RUN sed -i 's/\r$//' /docker-entrypoint.d/00-seed-nginx-conf.sh \
        /docker-entrypoint.d/30-backend-upstream.sh \
        /docker-entrypoint.d/35-real-ip.sh \
        /docker-entrypoint.d/40-hsts.sh \
        /docker-entrypoint.d/50-operator-allowlist.sh
USER nginx

# Entrypoints edit /tmp/nginx.conf (tmpfs); nginx must load that path.
CMD ["nginx", "-g", "daemon off;", "-c", "/tmp/nginx.conf"]

EXPOSE 8080
