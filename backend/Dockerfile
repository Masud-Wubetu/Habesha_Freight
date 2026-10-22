# Stage 1: Build TypeScript Backend
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY tsconfig.json ./
COPY knexfile.ts ./
COPY src ./src
RUN npm run build

# Stage 2: Production Image
FROM node:20-alpine AS runner

WORKDIR /app

RUN apk add --no-cache wget

COPY package*.json ./
# Keep tsx available for Knex TS migrations/seeds
RUN npm ci --omit=dev && npm install tsx@4.23.12 --omit=dev

COPY knexfile.ts ./
COPY docker-entrypoint.sh ./docker-entrypoint.sh
COPY --from=builder /app/dist ./dist
# Seeds/migrations are TypeScript and import shared utils
COPY --from=builder /app/src ./src

RUN chmod +x ./docker-entrypoint.sh \
  && mkdir -p uploads

ENV NODE_ENV=production
ENV PORT=5000

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=5 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:5000/health || exit 1

ENTRYPOINT ["./docker-entrypoint.sh"]
