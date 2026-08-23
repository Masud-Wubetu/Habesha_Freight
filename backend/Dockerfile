# Stage 1: Build TypeScript Backend
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy source code and build
COPY tsconfig.json ./
COPY knexfile.ts ./
COPY src ./src
RUN npm run build

# Stage 2: Production Image
FROM node:20-alpine AS runner

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

# Copy compiled JS, source code, and knexfile for CLI migrations
COPY knexfile.ts ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src ./src

ENV NODE_ENV=production

# Expose server port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5000/api/health || exit 1

CMD ["node", "dist/server.js"]