# ============================================
# Stage 1: Build the React/Vite application
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files and install dependencies
COPY package.json ./
RUN npm install --ignore-scripts

# Copy source code
COPY . .

# VITE_API_PATH is a build-time variable — Vite inlines it into the JS bundle.
# Default points to localhost:8080; override with --build-arg for GKE deployment.
ARG VITE_API_PATH="http://localhost:8080"
ENV VITE_API_PATH=${VITE_API_PATH}

# Build the production bundle
RUN npm run build

# ============================================
# Stage 2: Serve with lightweight "serve"
# ============================================
FROM node:20-alpine AS runtime

WORKDIR /app

# Install "serve" — a zero-config static file server
RUN npm install -g serve

# Copy the built static files from the builder stage
COPY --from=builder /app/dist ./dist

# Create a non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expose port 80
EXPOSE 80

# Serve the SPA on port 80 (-s enables single-page app mode with fallback to index.html)
CMD ["serve", "-s", "dist", "-l", "80"]
