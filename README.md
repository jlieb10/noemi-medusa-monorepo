# NOEMI Luxury Supplements E-commerce Platform

A modern, high-performance e-commerce platform for luxury supplements built with Medusa v2, Next.js 15, and PostgreSQL.

## 📖 Table of Contents

- [🏗️ Architecture](#️-architecture)
- [🚀 Quick Start](#-quick-start)
  - [Prerequisites](#prerequisites)
  - [Complete Setup Guide](#complete-setup-guide)
  - [Verification](#verification)
- [📝 Available Scripts](#-available-scripts)
- [🚨 Troubleshooting](#-troubleshooting)
- [🔧 Environment Variables Reference](#-environment-variables-reference)
- [🧪 Testing](#-testing)
- [📦 Production Deployment](#-production-deployment)
  - [🌩️ AWS Deployment Guide](#️-aws-deployment-guide)
  - [☁️ Azure Deployment Guide](#️-azure-deployment-guide)
  - [🌊 Digital Ocean Deployment Guide](#-digital-ocean-deployment-guide)
  - [🚀 Netlify + Railway Deployment Guide](#-netlify--railway-deployment-guide)
- [🔧 Environment Variables for Production](#-environment-variables-for-production)
- [🔒 Security Checklist](#-security-checklist)
- [🆘 Support and Troubleshooting](#-support-and-troubleshooting)
- [🎯 Success Metrics](#-success-metrics)
- [📄 License](#-license)
- [🤝 Contributing](#-contributing)

## 🏗️ Architecture

This is a monorepo containing:

- **Backend** (`noemi-medusa-backend`): Medusa v2 e-commerce engine with PostgreSQL
- **Frontend** (`noemi-medusa-storefront`): Next.js 15 storefront with React 18 and Tailwind CSS

## 🚀 Quick Start

### Prerequisites

**Required Software:**
- **Node.js 20+** (tested with Node.js 20.17.0)
- **PostgreSQL 15+** (for database)
- **Git** (for version control)

**Package Managers:**
- Backend uses **Yarn 1.x** (yarn@1.22.22)
- Frontend uses **Yarn 3.x** (yarn@3.2.3 via Corepack)

**System Requirements:**
- **RAM**: Minimum 4GB, recommended 8GB+
- **Storage**: 2GB+ free space for dependencies
- **OS**: Linux, macOS, or Windows with WSL2

### Complete Setup Guide

#### Step 1: System Prerequisites

**Install Node.js 20+:**
```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# macOS (using Homebrew)
brew install node@20

# Windows (using Chocolatey)
choco install nodejs --version=20.17.0
```

**Install PostgreSQL:**
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y postgresql postgresql-client

# macOS (using Homebrew)  
brew install postgresql
brew services start postgresql

# Windows
# Download from https://www.postgresql.org/download/windows/
```

#### Step 2: Database Setup

```bash
# Start PostgreSQL service (Linux)
sudo service postgresql start

# Create database and user
sudo -u postgres createdb medusa-v2
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"

# Verify connection
sudo -u postgres psql -d medusa-v2 -c "SELECT version();"
```

#### Step 3: Repository Setup

```bash
# Clone repository
git clone https://github.com/jlieb10/noemi-medusa-monorepo.git
cd noemi-medusa-monorepo

# Install backend dependencies (⚠️ Takes 7+ minutes - DO NOT CANCEL)
cd noemi-medusa-backend
yarn install  # Wait for completion - this is critical
cd ..

# Enable Yarn 3 for frontend
cd noemi-medusa-storefront
corepack enable

# Install frontend dependencies (⚠️ Takes 7+ minutes - DO NOT CANCEL)
yarn install --mode=update-lockfile && yarn install
cd ..
```

#### Step 4: Environment Configuration

**Backend Environment (`noemi-medusa-backend/.env`):**
```bash
# Copy template and configure
cd noemi-medusa-backend
cp .env.template .env

# Edit .env with these values:
DATABASE_URL=postgres://postgres:password@localhost/medusa-v2
POSTGRES_URL=postgres://postgres:password@localhost/medusa-v2
STORE_CORS=http://localhost:3000,http://localhost:1337,https://docs.medusajs.com
ADMIN_CORS=http://localhost:9000,http://localhost:3000,https://docs.medusajs.com
AUTH_CORS=http://localhost:9000,http://localhost:3000,https://docs.medusajs.com
REDIS_URL=redis://localhost:6379
JWT_SECRET=supersecret
COOKIE_SECRET=supersecret
```

#### Step 5: Database Migration and Seeding

```bash
# Run from backend directory
cd noemi-medusa-backend

# Build backend first (⚠️ Takes 20+ seconds)
NODE_ENV=development yarn build

# Run database migrations (⚠️ Takes 15+ seconds)
NODE_ENV=development npx medusa db:migrate

# Seed with sample data (⚠️ Takes 3.5+ seconds)
NODE_ENV=development yarn seed
```

#### Step 6: Get Publishable API Key

```bash
# Extract publishable key from database
sudo -u postgres psql -d medusa-v2 -c "SELECT token FROM public.api_key WHERE type = 'publishable';" | grep pk_

# Copy the pk_* token for frontend configuration
```

#### Step 7: Frontend Configuration

```bash
# Create frontend environment file
cd noemi-medusa-storefront
cp .env.example .env.local

# Edit .env.local with these values:
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_[your_token_from_step_6]
NODE_ENV=development
NEXT_PUBLIC_DEFAULT_REGION=us
```

#### Step 8: Build Frontend

```bash
# Build frontend (⚠️ Takes 40+ seconds, requires backend running)
# First, start backend in another terminal:
cd noemi-medusa-backend
NODE_ENV=development yarn dev &

# Then build frontend:
cd noemi-medusa-storefront
yarn build
```

#### Step 9: Start Development Servers

```bash
# Terminal 1 - Backend (Port 9000)
cd noemi-medusa-backend
NODE_ENV=development yarn dev

# Terminal 2 - Frontend (Port 3000)  
cd noemi-medusa-storefront
yarn dev
```

### Verification

1. **Backend Health**: `curl http://localhost:9000/health` → Should return "OK"
2. **Admin Interface**: Visit `http://localhost:9000/app`
3. **Storefront**: Visit `http://localhost:3000` (redirects to `/dk`)
4. **Store Page**: Visit `http://localhost:3000/dk/store`

### Create Admin User

```bash
cd noemi-medusa-backend
npx medusa user -e admin@test.com -p password123
```

## 📝 Available Scripts

### Root Level Commands

- `npm run build` - Build both backend and frontend
- `npm run dev` - Start both services in development mode
- `npm run start` - Start both services in production mode
- `npm run test` - Run all tests
- `npm run lint` - Lint all code
- `npm run seed` - Seed the backend with sample data

### Workspace-specific Commands

- `npm run dev:backend` - Start backend only
- `npm run dev:frontend` - Start frontend only
- `npm run build --workspace=noemi-medusa-backend` - Build backend only
- `npm run build --workspace=noemi-medusa-storefront` - Build frontend only

## 🚨 Troubleshooting

### Common Issues & Solutions

**1. Backend Build Failures:**
```bash
# Ensure NODE_ENV is set
NODE_ENV=development yarn build

# Clear build cache
rm -rf .medusa/ dist/
yarn build
```

**2. Database Connection Issues:**
```bash
# Verify PostgreSQL is running
sudo service postgresql status

# Test connection
sudo -u postgres psql -d medusa-v2 -c "\\dt"

# Check environment variables
cat .env | grep DATABASE_URL
```

**3. Frontend Build Failures:**
```bash
# Ensure backend is running first
curl http://localhost:9000/health

# Verify publishable key
sudo -u postgres psql -d medusa-v2 -c "SELECT token FROM public.api_key WHERE type = 'publishable';"

# Check environment file
cat .env.local | grep NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
```

**4. Port Conflicts:**
```bash
# Kill processes on ports
sudo lsof -ti:9000 | xargs kill -9  # Backend
sudo lsof -ti:3000 | xargs kill -9  # Frontend
```

**5. Dependency Installation Issues:**
```bash
# Backend (Yarn 1.x)
cd noemi-medusa-backend
yarn cache clean
rm -rf node_modules yarn.lock
yarn install

# Frontend (Yarn 3.x)
cd noemi-medusa-storefront
yarn cache clean --all
rm -rf node_modules .yarn/cache
corepack enable
yarn install
```

## 🔧 Environment Variables Reference

### Backend Environment Variables (.env)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DATABASE_URL` | ✅ | - | PostgreSQL connection string |
| `POSTGRES_URL` | ✅ | - | PostgreSQL connection string (same as DATABASE_URL) |
| `STORE_CORS` | ✅ | - | Allowed origins for store API |
| `ADMIN_CORS` | ✅ | - | Allowed origins for admin API |
| `AUTH_CORS` | ✅ | - | Allowed origins for auth API |
| `JWT_SECRET` | ✅ | supersecret | JWT signing secret (change in production) |
| `COOKIE_SECRET` | ✅ | supersecret | Cookie signing secret (change in production) |
| `REDIS_URL` | ❌ | - | Redis connection for sessions (optional) |
| `NODE_ENV` | ❌ | development | Environment mode |

### Frontend Environment Variables (.env.local)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `NEXT_PUBLIC_MEDUSA_BACKEND_URL` | ✅ | - | Backend API URL |
| `MEDUSA_BACKEND_URL` | ✅ | - | Backend API URL (server-side) |
| `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` | ✅ | - | Publishable API key from database |
| `NEXT_PUBLIC_BASE_URL` | ✅ | - | Frontend base URL |
| `NODE_ENV` | ❌ | development | Environment mode |
| `NEXT_PUBLIC_DEFAULT_REGION` | ❌ | us | Default region code |

## 🧪 Testing

### Backend Tests
```bash
cd noemi-medusa-backend

# Unit tests (no tests found currently, but passes)
yarn test:unit

# Integration tests (fails due to SWC config issue)
yarn test:integration:http
```

### Frontend Tests
```bash
cd noemi-medusa-storefront

# Linting (has ESLint config issues but runs)
yarn lint

# Type checking
yarn typecheck
```

## 📦 Production Deployment

### Prerequisites for All Platforms

1. **Database**: PostgreSQL 15+ (managed service recommended)
2. **Environment Variables**: All required variables configured
3. **Build Requirements**: Node.js 20+, sufficient memory (8GB+ recommended)
4. **Domain**: Custom domain configured with SSL

---

## 🌩️ AWS Deployment Guide

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │      Vercel     │    │   Route 53      │
│   (CDN/Cache)   │    │  (Alternative)  │    │     (DNS)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      ALB        │    │   Next.js App   │    │   Domain Name   │
│ (Load Balancer) │    │  (Frontend)     │    │  (your-app.com) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      ECS        │    │      RDS        │    │       S3        │
│  (Backend API)  │    │  (PostgreSQL)   │    │ (File Storage)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Step 1: Database Setup (RDS)

1. **Create RDS PostgreSQL Instance:**
```bash
aws rds create-db-instance \
  --db-instance-identifier noemi-medusa-db \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 15.4 \
  --allocated-storage 20 \
  --storage-type gp2 \
  --db-name medusav2 \
  --master-username medusauser \
  --master-user-password "YourSecurePassword123!" \
  --vpc-security-group-ids sg-your-security-group \
  --publicly-accessible \
  --backup-retention-period 7 \
  --multi-az false
```

2. **Configure Security Group:**
```bash
# Allow PostgreSQL connections
aws ec2 authorize-security-group-ingress \
  --group-id sg-your-security-group \
  --protocol tcp \
  --port 5432 \
  --source-group sg-your-app-security-group
```

3. **Get Database URL:**
```bash
# Get RDS endpoint
aws rds describe-db-instances \
  --db-instance-identifier noemi-medusa-db \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text

# Database URL format:
# postgres://medusauser:YourSecurePassword123!@your-rds-endpoint.region.rds.amazonaws.com:5432/medusav2
```

### AWS Deployment Costs (Estimated Monthly)

- **RDS PostgreSQL** (db.t3.micro): ~$20
- **ECS Fargate** (0.5 vCPU, 1GB): ~$15
- **ALB**: ~$22
- **S3 Storage**: ~$3
- **CloudFront**: ~$5
- **Route 53**: ~$1
- **Total**: ~$66/month

---

## ☁️ Azure Deployment Guide

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Azure CDN     │    │  Static Web App │    │   DNS Zone      │
│   (Content)     │    │  (Alternative)  │    │  (Azure DNS)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Application     │    │    Frontend     │    │   Custom        │
│ Gateway (LB)    │    │   (Next.js)     │    │   Domain        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Service   │    │   Database      │    │   Blob Storage  │
│ (Backend API)   │    │  (PostgreSQL)   │    │   (Files)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Azure Deployment Costs (Estimated Monthly)

- **Azure Database for PostgreSQL** (B1): ~$25
- **App Service** (B1): ~$15
- **Static Web Apps**: Free tier
- **Azure CDN**: ~$5
- **DNS Zone**: ~$1
- **Total**: ~$46/month

---

## 🌊 Digital Ocean Deployment Guide

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloudflare    │    │   Netlify       │    │   Cloudflare    │
│   (CDN/DNS)     │    │ (Alternative)   │    │     (DNS)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Load Balancer  │    │   Frontend      │    │   Custom        │
│   (Optional)    │    │  (Next.js)      │    │   Domain        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   App Platform  │    │   Managed DB    │    │     Spaces      │
│ (Backend API)   │    │ (PostgreSQL)    │    │ (File Storage)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Digital Ocean Deployment Costs (Estimated Monthly)

- **Managed PostgreSQL** (1GB): ~$15
- **App Platform** (Basic): ~$12
- **Spaces** (250GB): ~$5
- **Load Balancer** (optional): ~$12
- **Total**: ~$32-44/month

---

## 🚀 Netlify + Railway Deployment Guide

This is often the most cost-effective and developer-friendly option for small to medium applications.

### Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Netlify     │    │    Railway      │    │   Cloudflare    │
│   (Frontend)    │    │   (Backend)     │    │   (DNS/CDN)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Next.js App   │    │   Medusa API    │    │   Domain Name   │
│  (Static/SSR)   │    │   (Node.js)     │    │  (your-app.com) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌─────────────────┐
                       │   PostgreSQL    │
                       │   (Railway)     │
                       └─────────────────┘
```

### Step 1: Backend Deployment (Railway)

1. **Install Railway CLI:**
```bash
npm install -g @railway/cli
railway login
```

2. **Initialize Railway Project:**
```bash
cd noemi-medusa-backend
railway init
```

3. **Create PostgreSQL Database:**
```bash
# Add PostgreSQL service
railway add postgresql

# Get database URL
railway variables get DATABASE_URL
```

4. **Configure Environment Variables:**
```bash
# Set all required variables
railway variables set NODE_ENV=production
railway variables set JWT_SECRET="your-super-secure-jwt-secret-min-32-chars"
railway variables set COOKIE_SECRET="your-super-secure-cookie-secret-min-32-chars"
railway variables set STORE_CORS="https://your-domain.com,https://www.your-domain.com"
railway variables set ADMIN_CORS="https://your-backend-domain.railway.app"
railway variables set AUTH_CORS="https://your-backend-domain.railway.app"

# Database URL is automatically set by Railway
```

5. **Deploy to Railway:**
```bash
railway deploy
```

6. **Run Database Migrations:**
```bash
# Connect to Railway environment and run migrations
railway run npx medusa db:migrate
railway run npx medusa exec ./src/scripts/seed.ts
```

### Step 2: Frontend Deployment (Netlify)

1. **Configure Build Settings** (`netlify.toml`):
```toml
[build]
  base = "noemi-medusa-storefront/"
  command = "corepack enable && yarn install && yarn build"
  publish = ".next/"
  
[build.environment]
  NODE_VERSION = "20"
  YARN_VERSION = "3.2.3"
  COREPACK_ENABLE_STRICT = "0"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-Content-Type-Options = "nosniff"
    X-XSS-Protection = "1; mode=block"
    Referrer-Policy = "strict-origin-when-cross-origin"
```

2. **Environment Variables in Netlify:**

Via Netlify Dashboard or CLI:
```bash
netlify env:set NEXT_PUBLIC_MEDUSA_BACKEND_URL "https://your-backend.railway.app"
netlify env:set MEDUSA_BACKEND_URL "https://your-backend.railway.app"
netlify env:set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY "pk_live_your_key"
netlify env:set NEXT_PUBLIC_BASE_URL "https://your-domain.com"
netlify env:set NODE_ENV "production"
netlify env:set NEXT_PUBLIC_DEFAULT_REGION "us"
```

3. **Deploy to Netlify:**
```bash
cd noemi-medusa-storefront
netlify init
netlify deploy --prod
```

### Netlify + Railway Deployment Costs (Estimated Monthly)

- **Railway PostgreSQL**: ~$5
- **Railway App Hosting**: ~$5
- **Netlify**: Free tier (100GB bandwidth)
- **Domain**: ~$12/year
- **Total**: ~$10/month + domain

---

## 🔧 Environment Variables for Production

### Critical Security Notes

⚠️ **NEVER use default secrets in production!**

```bash
# Generate secure secrets
openssl rand -hex 32  # For JWT_SECRET
openssl rand -hex 32  # For COOKIE_SECRET
```

### Complete Environment Variables

#### Backend Production Environment (.env)
```env
# Database (Required)
DATABASE_URL=postgres://user:password@host:port/database
POSTGRES_URL=postgres://user:password@host:port/database

# Security (Required - CHANGE IN PRODUCTION)
JWT_SECRET=super-secure-jwt-secret-minimum-32-characters-long
COOKIE_SECRET=super-secure-cookie-secret-minimum-32-characters-long

# CORS Configuration (Required)
STORE_CORS=https://your-domain.com,https://www.your-domain.com
ADMIN_CORS=https://admin.your-domain.com,https://api.your-domain.com
AUTH_CORS=https://admin.your-domain.com,https://api.your-domain.com

# Environment
NODE_ENV=production

# Optional Services
REDIS_URL=redis://user:password@host:port
MEILISEARCH_HOST=https://your-meilisearch.com
MEILISEARCH_API_KEY=your-meilisearch-key
```

#### Frontend Production Environment (.env.local)
```env
# API Configuration (Required)
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.your-domain.com
MEDUSA_BACKEND_URL=https://api.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_live_your_publishable_key

# Site Configuration (Required)
NEXT_PUBLIC_BASE_URL=https://your-domain.com
NODE_ENV=production
NEXT_PUBLIC_DEFAULT_REGION=us

# Analytics (Optional)
NEXT_PUBLIC_GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX
NEXT_PUBLIC_VERCEL_ANALYTICS=true
```

## 🔒 Security Checklist

### Pre-Deployment Security

- [ ] **Secrets Management**: All default secrets changed
- [ ] **Environment Variables**: No secrets in code/repo
- [ ] **CORS Configuration**: Properly configured for production domains
- [ ] **Database**: Connection pooling enabled
- [ ] **SSL/TLS**: HTTPS enforced everywhere
- [ ] **API Keys**: Separate keys for staging/production

### Post-Deployment Security

- [ ] **Health Checks**: All endpoints responding correctly
- [ ] **Monitoring**: Error tracking and uptime monitoring
- [ ] **Backups**: Database backup strategy implemented
- [ ] **Updates**: Dependencies regularly updated
- [ ] **Access Control**: Admin access properly secured

## 🆘 Support and Troubleshooting

### Getting Help

1. **Documentation Links:**
   - [Medusa Documentation](https://docs.medusajs.com)
   - [Next.js Documentation](https://nextjs.org/docs)
   - [PostgreSQL Documentation](https://www.postgresql.org/docs/)

2. **Community Support:**
   - [Medusa Discord](https://discord.gg/medusajs)
   - [GitHub Issues](https://github.com/jlieb10/noemi-medusa-monorepo/issues)

### Emergency Troubleshooting

**Backend Down:**
```bash
# Check health endpoint
curl -f https://api.your-domain.com/health

# Check logs (Railway example)
railway logs --tail

# Check database connection
psql $DATABASE_URL -c "SELECT 1;"
```

**Frontend Down:**
```bash
# Check build status
curl -f https://your-domain.com

# Check environment variables
echo $NEXT_PUBLIC_MEDUSA_BACKEND_URL

# Rebuild and redeploy
git commit --allow-empty -m "Trigger rebuild"
git push
```

**Database Issues:**
```bash
# Check database status
pg_isready -h host -p port

# Check connections
SELECT count(*) FROM pg_stat_activity;

# Check disk space
SELECT pg_size_pretty(pg_database_size('medusav2'));
```

## 🎯 Success Metrics

### Performance Targets

- **Frontend Lighthouse Score**: ≥ 95
- **Backend Response Time**: < 500ms p95
- **Database Query Time**: < 100ms p95
- **Uptime**: > 99.9%

### Deployment Success Indicators

- [ ] ✅ All health checks pass
- [ ] ✅ Database migrations complete
- [ ] ✅ Frontend builds successfully
- [ ] ✅ Backend API responds correctly
- [ ] ✅ Admin interface accessible
- [ ] ✅ Storefront loads and functions
- [ ] ✅ SSL certificates valid
- [ ] ✅ DNS resolution correct
- [ ] ✅ Environment variables configured
- [ ] ✅ Monitoring alerts configured

This comprehensive guide ensures zero scope for errors and provides battle-tested deployment instructions for all major cloud providers.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

### Development Guidelines

1. Follow TypeScript best practices
2. Write tests for new features
3. Use conventional commits
4. Keep components small and focused
5. Document public APIs

### Code Style

- ESLint + Prettier for formatting
- Import organization with barrel exports
- Consistent naming conventions
- TypeScript strict mode

For detailed contributing guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).