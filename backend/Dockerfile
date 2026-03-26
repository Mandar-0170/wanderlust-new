# ============================================
# Stage 1: Build the TypeScript application
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install ALL dependencies (including devDependencies for tsc)
COPY package.json ./
RUN npm install

# Copy source code and build
COPY . .
RUN npm run build

# ============================================
# Stage 2: Production runtime
# ============================================
FROM node:20-alpine AS runtime

WORKDIR /app

# Copy package files and install ONLY production dependencies
COPY package.json ./
RUN npm install --omit=dev

# Copy the compiled JavaScript from the builder stage
COPY --from=builder /app/dist ./dist

# Copy the sample data (needed for seeding if applicable)
COPY data ./data

# -----------------------------------------------
# Environment Variables
# -----------------------------------------------
# All env vars are injected at runtime:
#   - Local:  docker-compose env_file (.env)
#   - GKE:    Kubernetes ConfigMaps / Secrets
# No defaults are baked into the image.

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose the backend port
EXPOSE 8080

# Start the server
CMD ["node", "dist/server.js"]
