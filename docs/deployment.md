# Deployment Guide - NOEMI E-commerce Platform

This guide provides comprehensive instructions for deploying the NOEMI luxury supplements e-commerce platform to staging and production environments.

## 🏗️ Architecture Overview

### Recommended Deployment Stack

**Frontend (Next.js Storefront)**:
- **Recommended**: Vercel (optimal Next.js support)
- **Alternatives**: Netlify, Azure Static Web Apps, AWS Amplify

**Backend (Medusa API)**:
- **Recommended**: Railway (PostgreSQL + Redis included)
- **Alternatives**: Fly.io, Digital Ocean App Platform, Heroku

**Database**:
- **Recommended**: Supabase (PostgreSQL with real-time features)
- **Alternatives**: Railway PostgreSQL, PlanetScale, Neon

**Cache/Sessions**:
- **Recommended**: Upstash Redis (serverless)
- **Alternatives**: Railway Redis, ElastiCache

### Environment Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ localhost:8000  │    │ staging.noemi   │    │  www.noemi.com  │
│ localhost:9000  │    │ api-staging...  │    │  api.noemi.com  │
│ Local PostgreSQL│    │ Supabase (Dev)  │    │ Supabase (Prod) │
│ Local Redis     │    │ Upstash (Dev)   │    │ Upstash (Prod)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Deployment Instructions

### Prerequisites

1. **Accounts Required**:
   - Vercel account (Frontend)
   - Railway account (Backend) OR Fly.io
   - Supabase account (Database)
   - Upstash account (Redis)
   - GitHub repository access

2. **CLI Tools**:
   ```bash
   npm install -g vercel
   npm install -g @railway/cli
   # OR
   curl -L https://fly.io/install.sh | sh
   ```

3. **Environment Setup**:
   - Clone repository
   - Install dependencies: `npm install`
   - Verify builds work locally

### Step 1: Database Setup (Supabase)

1. **Create Supabase Project**:
   ```bash
   # Go to https://supabase.com/dashboard
   # Create new project
   # Note down:
   # - Database URL
   # - Anon Key
   # - Service Role Key
   ```

2. **Configure Database**:
   ```sql
   -- Enable necessary extensions
   CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
   CREATE EXTENSION IF NOT EXISTS "pg_trgm";
   
   -- Medusa will handle schema creation
   ```

3. **Environment Variables**:
   ```env
   # Staging
   DATABASE_URL=postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres
   
   # Production  
   DATABASE_URL=postgresql://postgres:[password]@db.[project-ref].supabase.co:5432/postgres
   ```

### Step 2: Cache Setup (Upstash Redis)

1. **Create Redis Database**:
   ```bash
   # Go to https://console.upstash.com/
   # Create new Redis database
   # Copy connection string
   ```

2. **Environment Variables**:
   ```env
   # Staging/Production
   REDIS_URL=rediss://:[password]@[host]:[port]
   ```

### Step 3: Backend Deployment (Railway)

1. **Initialize Railway Project**:
   ```bash
   railway login
   railway init
   railway link [project-id]  # If existing project
   ```

2. **Configure Environment Variables**:
   ```bash
   # Set via Railway dashboard or CLI
   railway variables set DATABASE_URL="postgresql://..."
   railway variables set REDIS_URL="rediss://..."
   railway variables set JWT_SECRET="your-secure-jwt-secret"
   railway variables set COOKIE_SECRET="your-secure-cookie-secret"
   railway variables set NODE_ENV="production"
   
   # CORS settings
   railway variables set STORE_CORS="https://your-domain.com,https://www.your-domain.com"
   railway variables set ADMIN_CORS="https://admin.your-domain.com"
   railway variables set AUTH_CORS="https://admin.your-domain.com"
   ```

3. **Deploy Backend**:
   ```bash
   # Create railway.json in backend directory
   cd noemi-medusa-backend
   echo '{
     "build": {
       "builder": "NIXPACKS"
     },
     "deploy": {
       "startCommand": "npm run start",
       "healthcheckPath": "/health"
     }
   }' > railway.json
   
   # Deploy
   railway up
   ```

4. **Run Database Migrations**:
   ```bash
   # After first deployment
   railway run npm run migration:run
   
   # Seed with sample data (optional)
   railway run npm run seed
   ```

5. **Custom Domain** (Optional):
   ```bash
   # In Railway dashboard
   # Go to Settings > Domains
   # Add custom domain: api.your-domain.com
   # Configure DNS CNAME record
   ```

### Step 4: Frontend Deployment (Vercel)

1. **Connect to Vercel**:
   ```bash
   cd noemi-medusa-storefront
   vercel
   # Follow prompts to link project
   ```

2. **Configure Environment Variables**:
   ```bash
   # Via Vercel dashboard or CLI
   vercel env add NEXT_PUBLIC_MEDUSA_BACKEND_URL production
   # Enter: https://your-backend-domain.railway.app
   
   vercel env add NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY production
   # Enter: pk_live_[your-key] (get from Medusa admin)
   
   vercel env add NEXT_PUBLIC_STRIPE_KEY production
   # Enter: pk_live_[your-stripe-key]
   
   vercel env add NEXT_PUBLIC_BASE_URL production
   # Enter: https://your-domain.com
   ```

3. **Deploy Frontend**:
   ```bash
   vercel --prod
   ```

4. **Custom Domain**:
   ```bash
   # Via Vercel dashboard
   # Go to Settings > Domains
   # Add: your-domain.com and www.your-domain.com
   # Configure DNS records as instructed
   ```

### Alternative: Fly.io Backend Deployment

1. **Initialize Fly Application**:
   ```bash
   cd noemi-medusa-backend
   fly launch
   # Follow prompts, don't deploy yet
   ```

2. **Configure fly.toml**:
   ```toml
   app = "noemi-medusa-api"
   primary_region = "sjc"

   [build]
     builder = "heroku/buildpacks:20"

   [env]
     NODE_ENV = "production"
     PORT = "8080"

   [http_service]
     internal_port = 8080
     force_https = true
     auto_stop_machines = true
     auto_start_machines = true
     min_machines_running = 1

   [[http_service.checks]]
     grace_period = "30s"
     interval = "10s"
     method = "GET"
     path = "/health"
     timeout = "5s"
   ```

3. **Set Environment Variables**:
   ```bash
   fly secrets set DATABASE_URL="postgresql://..."
   fly secrets set REDIS_URL="rediss://..."
   fly secrets set JWT_SECRET="your-jwt-secret"
   fly secrets set COOKIE_SECRET="your-cookie-secret"
   ```

4. **Deploy**:
   ```bash
   fly deploy
   ```

### Alternative: Netlify Frontend Deployment

1. **Configure netlify.toml**:
   ```toml
   [build]
     command = "npm run build"
     publish = ".next"

   [build.environment]
     NODE_VERSION = "20"

   [[redirects]]
     from = "/*"
     to = "/index.html"
     status = 200

   [functions]
     directory = "netlify/functions"
   ```

2. **Deploy**:
   ```bash
   # Connect repository in Netlify dashboard
   # Configure environment variables
   # Deploy automatically on git push
   ```

## 🔧 Environment Configuration

### Staging Environment Variables

**Backend (.env)**:
```env
# Database
DATABASE_URL=postgresql://postgres:[password]@db.[staging-ref].supabase.co:5432/postgres
REDIS_URL=rediss://:[password]@[staging-host]:[port]

# Secrets
JWT_SECRET=staging-jwt-secret-change-in-production
COOKIE_SECRET=staging-cookie-secret-change-in-production

# CORS
STORE_CORS=https://staging.your-domain.com
ADMIN_CORS=https://admin-staging.your-domain.com
AUTH_CORS=https://admin-staging.your-domain.com

# Environment
NODE_ENV=staging
```

**Frontend (.env.local)**:
```env
# API
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api-staging.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_test_[staging-key]

# Stripe (test keys)
NEXT_PUBLIC_STRIPE_KEY=pk_test_[test-key]

# Environment
NODE_ENV=staging
NEXT_PUBLIC_BASE_URL=https://staging.your-domain.com
```

### Production Environment Variables

**Backend (.env)**:
```env
# Database
DATABASE_URL=postgresql://postgres:[password]@db.[prod-ref].supabase.co:5432/postgres
REDIS_URL=rediss://:[password]@[prod-host]:[port]

# Secrets (CHANGE THESE!)
JWT_SECRET=super-secure-jwt-secret-min-32-chars
COOKIE_SECRET=super-secure-cookie-secret-min-32-chars

# CORS
STORE_CORS=https://your-domain.com,https://www.your-domain.com
ADMIN_CORS=https://admin.your-domain.com
AUTH_CORS=https://admin.your-domain.com

# Environment
NODE_ENV=production
```

**Frontend (.env.local)**:
```env
# API
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_live_[production-key]

# Stripe (live keys)
NEXT_PUBLIC_STRIPE_KEY=pk_live_[live-key]

# Environment
NODE_ENV=production
NEXT_PUBLIC_BASE_URL=https://your-domain.com
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy NOEMI Platform

on:
  push:
    branches: [main, staging]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run tests
        run: npm run test
      
      - name: Build backend
        run: npm run build --workspace=noemi-medusa-backend
      
      - name: Build frontend
        run: npm run build --workspace=noemi-medusa-storefront
        env:
          NEXT_PUBLIC_MEDUSA_BACKEND_URL: ${{ secrets.NEXT_PUBLIC_MEDUSA_BACKEND_URL }}
          NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY: ${{ secrets.NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY }}

  deploy-staging:
    if: github.ref == 'refs/heads/staging'
    needs: test
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Backend to Railway
        run: |
          railway login --token ${{ secrets.RAILWAY_TOKEN }}
          railway deploy --service backend
      
      - name: Deploy Frontend to Vercel
        run: |
          vercel --token ${{ secrets.VERCEL_TOKEN }} --scope ${{ secrets.VERCEL_ORG_ID }}

  deploy-production:
    if: github.ref == 'refs/heads/main'
    needs: test
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v4
      
      - name: Deploy Backend to Railway
        run: |
          railway login --token ${{ secrets.RAILWAY_TOKEN }}
          railway deploy --service backend --environment production
      
      - name: Deploy Frontend to Vercel
        run: |
          vercel --prod --token ${{ secrets.VERCEL_TOKEN }} --scope ${{ secrets.VERCEL_ORG_ID }}
```

### Required Secrets

Add these to GitHub repository secrets:

```env
# Railway
RAILWAY_TOKEN=your-railway-token

# Vercel  
VERCEL_TOKEN=your-vercel-token
VERCEL_ORG_ID=your-vercel-org-id
VERCEL_PROJECT_ID=your-vercel-project-id

# Environment variables for builds
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_live_your-key
```

## 🔍 Monitoring & Maintenance

### Health Checks

**Backend Health Endpoint**:
```typescript
// src/api/health/route.ts
export async function GET() {
  return Response.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version
  })
}
```

**Frontend Health Check**:
```typescript
// pages/api/health.ts
export default function handler(req: NextApiRequest, res: NextApiResponse) {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString()
  })
}
```

### Monitoring Setup

1. **Vercel Analytics**:
   ```bash
   npm install @vercel/analytics
   # Add to _app.tsx
   ```

2. **Railway Monitoring**:
   - Built-in CPU/Memory monitoring
   - Custom metrics via telegraf

3. **Uptime Monitoring**:
   - UptimeRobot for external monitoring
   - Pingdom for detailed performance metrics

4. **Error Tracking**:
   ```bash
   npm install @sentry/nextjs @sentry/node
   # Configure Sentry for both frontend and backend
   ```

### Backup Strategy

**Database Backups**:
```bash
# Supabase provides automatic backups
# Additional manual backup:
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
```

**File Uploads**:
```bash
# If using local file storage, backup uploads directory
# Recommended: Use cloud storage (AWS S3, Cloudinary)
```

## 🚨 Troubleshooting

### Common Deployment Issues

1. **Build Failures**:
   ```bash
   # Check environment variables
   # Verify all dependencies installed
   # Clear build cache
   rm -rf .next/ dist/ node_modules/
   npm install
   ```

2. **Database Connection Issues**:
   ```bash
   # Verify connection string format
   # Check IP allowlisting in Supabase
   # Test connection manually
   ```

3. **CORS Errors**:
   ```bash
   # Verify CORS environment variables
   # Check domain configuration
   # Test with curl/Postman
   ```

### Performance Optimization

1. **CDN Configuration**:
   - Vercel automatically provides CDN
   - Configure caching headers for static assets

2. **Database Performance**:
   - Enable connection pooling
   - Add database indexes for frequent queries
   - Use read replicas for heavy read workloads

3. **Caching Strategy**:
   - Redis for session storage
   - Next.js built-in caching for API routes
   - CDN caching for static assets

## 📊 Success Metrics

### Deployment Health Indicators

- **Uptime**: > 99.9%
- **Response Time**: < 500ms p95
- **Error Rate**: < 0.1%
- **Build Success Rate**: > 95%

### Performance Targets

- **Lighthouse Performance**: ≥ 95
- **Time to First Byte**: < 200ms
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s

This deployment guide ensures a robust, scalable, and maintainable deployment of the NOEMI e-commerce platform across staging and production environments.