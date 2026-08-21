# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first for better layer caching
COPY package*.json ./

# Install all dependencies required for building
RUN npm ci

# Copy application source
COPY . .

# Build application
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copy dependency files
COPY package*.json ./

# Install production dependencies only
RUN npm ci --omit=dev

# Copy production files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/src/database/migrations ./migrations
COPY --from=builder /app/src/database/seeds ./seeds

# Create non-root u     ser
RUN addgroup -g 1001 -S nodejs && \
        adduser -S nodejs -u 1001

# Run application as non-root user
USER nodejs

EXPOSE 3000

CMD ["node", "dist/server.js"]