# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install production dependencies
COPY package*.json ./
RUN npm ci --only=production

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/migrations ./migrations
COPY --from=builder /app/seeds ./seeds

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
        adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/server.js"]