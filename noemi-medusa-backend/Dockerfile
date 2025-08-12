# Dockerfile for Medusa Backend
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package.json yarn.lock .yarnrc.yml ./
COPY package.json yarn.lock ./
COPY .yarnrc.yml* ./
# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Expose the port
EXPOSE 9000

# Default command (can be overridden in docker-compose)
CMD ["yarn", "dev"]