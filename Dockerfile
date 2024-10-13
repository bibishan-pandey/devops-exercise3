# Base stage to install dependencies
FROM node:18-alpine AS base
WORKDIR /app

# Enable corepack
RUN corepack enable

# Install dependencies separately for production and development
COPY ./package.json ./yarn.lock ./
RUN yarn install --frozen-lockfile

# Build stage
FROM base AS builder
WORKDIR /app
COPY --chown=node:node . .
RUN yarn build

# Final stage for production
FROM node:18-alpine AS production
WORKDIR /app

# Set environment variables
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy only the production dependencies from the base image
COPY --from=base /app/node_modules ./node_modules

# Copy the build artifacts and necessary config files from the builder
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.mjs ./next.config.mjs

# Set appropriate user and expose port
USER node
EXPOSE 3000

# Use volume for caching
VOLUME /home/node/.next/cache

# Start the application
CMD ["yarn", "start"]
