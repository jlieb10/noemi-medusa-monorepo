#!/bin/bash

# NOEMI Development Setup Script
# This script helps set up the development environment

set -e

echo "🚀 Setting up NOEMI development environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check Node.js version
echo "📋 Checking prerequisites..."
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_NODE="20"

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js 20 or higher.${NC}"
    exit 1
fi

# Check if Node version is sufficient
if [ "$(printf '%s\n' "$REQUIRED_NODE" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_NODE" ]; then
    echo -e "${RED}❌ Node.js version $NODE_VERSION is too old. Please install Node.js $REQUIRED_NODE or higher.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $NODE_VERSION detected${NC}"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

echo -e "${GREEN}✅ Dependencies installed${NC}"

# Set up environment files
echo "⚙️ Setting up environment files..."

# Backend environment
if [ ! -f "noemi-medusa-backend/.env" ]; then
    if [ -f "noemi-medusa-backend/.env.example" ]; then
        cp noemi-medusa-backend/.env.example noemi-medusa-backend/.env
        echo -e "${YELLOW}📝 Created noemi-medusa-backend/.env from template${NC}"
        echo -e "${YELLOW}   Please edit this file with your database and Redis credentials${NC}"
    fi
fi

# Frontend environment
if [ ! -f "noemi-medusa-storefront/.env.local" ]; then
    if [ -f "noemi-medusa-storefront/.env.example" ]; then
        cp noemi-medusa-storefront/.env.example noemi-medusa-storefront/.env.local
        echo -e "${YELLOW}📝 Created noemi-medusa-storefront/.env.local from template${NC}"
        echo -e "${YELLOW}   Please edit this file with your Medusa publishable key${NC}"
    fi
fi

# Test builds
echo "🔨 Testing builds..."

echo "  Building backend..."
npm run build --workspace=noemi-medusa-backend

echo "  Building frontend..."
npm run build --workspace=noemi-medusa-storefront

echo -e "${GREEN}✅ Both applications build successfully${NC}"

# Print next steps
echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Set up a PostgreSQL database (or use Supabase)"
echo "2. Set up Redis (or use Upstash)"
echo "3. Update environment files with your credentials:"
echo "   - noemi-medusa-backend/.env"
echo "   - noemi-medusa-storefront/.env.local"
echo "4. Start development servers:"
echo "   npm run dev:backend   # Backend on http://localhost:9000"
echo "   npm run dev:frontend  # Frontend on http://localhost:8000"
echo ""
echo "📚 Documentation:"
echo "   - README.md - Project overview and setup"
echo "   - docs/agents.md - AI agent instructions"
echo "   - docs/deployment.md - Deployment guide"
echo ""
echo -e "${GREEN}Happy coding! 🚀${NC}"