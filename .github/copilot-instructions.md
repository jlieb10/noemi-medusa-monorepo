# Noemi Medusa Monorepo

Noemi Medusa Monorepo is an e-commerce system built with Medusa v2.8.8 (backend) and Next.js 15 (storefront). The backend provides headless commerce APIs while the frontend delivers a modern e-commerce experience.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### System Requirements
- Node.js >=20 (use `node --version` to verify)
- PostgreSQL database server
- Redis server (used for caching and sessions)
- Yarn (managed via Corepack - use `corepack enable`)

### Initial Setup
Bootstrap the complete development environment:
1. `sudo apt-get update && sudo apt-get install -y redis-server postgresql-client` - Install required services
2. `sudo service postgresql start` - Start PostgreSQL
3. `redis-server --version` - Verify Redis installation (Redis should auto-start)
4. `corepack enable` - Enable Yarn package manager via Corepack

### Backend Setup (noemi-medusa-backend)
Set up the Medusa backend server:
1. `cd noemi-medusa-backend`
2. `cp .env.template .env` - Copy environment template
3. Configure `.env` file with database credentials:
   ```
   DATABASE_URL=postgresql://username:password@localhost:5432/medusa-v2
   POSTGRES_URL=postgresql://username:password@localhost:5432/medusa-v2
   ```
4. `time yarn install` - Install dependencies (takes ~3.5 minutes)
5. `time yarn build` - Build backend (takes ~25 seconds. NEVER CANCEL)
6. `time npx medusa db:setup` - Setup database and run migrations (takes ~10.5 minutes. NEVER CANCEL)
   - Press Enter when prompted for database name to use default "medusa-v2"
7. `time yarn seed` - Seed database with sample data (takes ~3.5 seconds)

### Frontend Setup (noemi-medusa-storefront)
Set up the Next.js storefront:
1. `cd noemi-medusa-storefront`
2. Get publishable API key from backend: `PGPASSWORD=password psql -h localhost -U runner -d medusa-v2 -c "SELECT id FROM api_key WHERE type = 'publishable';"`
3. Create `.env.local` with:
   ```
   NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=<api_key_from_step_2>
   MEDUSA_BACKEND_URL=http://localhost:9000
   ```
4. `time yarn install` - Install dependencies (takes ~2.5 minutes)

### Development Servers
Run both backend and frontend in development mode:
- **Backend**: `cd noemi-medusa-backend && yarn dev` - Runs on http://localhost:9000
- **Frontend**: `cd noemi-medusa-storefront && yarn dev` - Runs on http://localhost:8000
- **Admin Panel**: Access at http://localhost:9000/app after starting backend

### Build Commands
Production builds:
- **Backend**: `yarn build` - takes ~25 seconds. NEVER CANCEL. Set timeout to 60+ seconds.
- **Frontend**: `yarn build` - may fail during static generation if API connection issues exist. Run dev mode instead.

## Validation

### Manual Testing Scenarios
Always manually validate changes by testing complete user workflows:

1. **Backend API Validation**:
   - Test health endpoint: `curl http://localhost:9000/health`
   - Test store API: `curl "http://localhost:9000/store/regions" -H "x-publishable-api-key: YOUR_KEY"`

2. **Frontend Validation**:
   - Access storefront at http://localhost:8000
   - Verify home page loads without errors
   - Test product browsing and cart functionality

3. **Database Validation**:
   - Check seeded data: `PGPASSWORD=password psql -h localhost -U runner -d medusa-v2 -c "SELECT count(*) FROM product;"`
   - Verify API keys: `PGPASSWORD=password psql -h localhost -U runner -d medusa-v2 -c "SELECT id, title FROM api_key;"`

### Testing
- **Backend Unit Tests**: `yarn test:unit` - No unit tests currently exist
- **Backend Integration Tests**: `yarn test:integration:http` - May fail due to database configuration issues
- **Frontend Linting**: `yarn lint` - Currently has configuration issues

## Common Issues and Workarounds

### Known Build/Runtime Issues
- **Frontend build fails**: Static generation requires working API connection. Use dev mode instead.
- **API key validation fails**: Publishable key may not be properly associated with sales channel. Verify database seeding completed successfully.
- **Integration tests fail**: Database connection configuration for test environment needs adjustment.
- **Frontend linting fails**: ESLint configuration has path resolution issues.

### Environment Setup Issues
- **Yarn version conflicts**: Use `corepack enable` to use project-specified Yarn version
- **PostgreSQL authentication**: Set PGPASSWORD environment variable or configure ~/.pgpass file
- **Redis connection**: Ensure Redis is running on default port 6379

## Repository Structure

### Backend (noemi-medusa-backend)
```
noemi-medusa-backend/
├── src/
│   ├── api/          # API route handlers
│   ├── admin/        # Admin panel customizations
│   ├── modules/      # Custom business logic modules
│   ├── scripts/      # Database seeding and migration scripts
│   └── workflows/    # Business process workflows
├── integration-tests/ # HTTP API integration tests
├── medusa-config.ts  # Main Medusa configuration
└── package.json      # Dependencies and scripts
```

### Frontend (noemi-medusa-storefront)
```
noemi-medusa-storefront/
├── src/
│   ├── app/          # Next.js App Router pages
│   ├── lib/          # Utility functions and SDK configuration
│   └── components/   # React components
├── public/           # Static assets
├── next.config.js    # Next.js configuration
└── package.json      # Dependencies and scripts
```

### Key Configuration Files
- `noemi-medusa-backend/.env` - Backend environment variables
- `noemi-medusa-storefront/.env.local` - Frontend environment variables  
- `noemi-medusa-backend/medusa-config.ts` - Medusa server configuration
- `noemi-medusa-storefront/src/lib/config.ts` - Frontend SDK configuration

## Timing Expectations

### NEVER CANCEL - Critical Timing Information
- **Backend yarn install**: 3.5 minutes - Set timeout to 10+ minutes
- **Frontend yarn install**: 2.5 minutes - Set timeout to 10+ minutes  
- **Backend build**: 25 seconds - Set timeout to 60+ seconds
- **Database setup**: 10.5 minutes - Set timeout to 20+ minutes. NEVER CANCEL.
- **Database seeding**: 3.5 seconds - Set timeout to 30+ seconds

### Development Server Startup
- **Backend dev server**: Ready in ~11ms after initial bootstrap
- **Frontend dev server**: Ready in ~1.4 seconds with Turbopack

## Integration with CI/CD

### Pre-commit Validation
Before committing changes, always run:
1. `cd noemi-medusa-backend && yarn build` - Verify backend builds
2. `cd noemi-medusa-storefront && yarn dev` - Verify frontend starts in dev mode
3. Test API endpoints manually as automated tests may be unreliable

### Environment Variables for Production
Ensure these environment variables are set in production:
- Backend: `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `COOKIE_SECRET`
- Frontend: `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY`, `MEDUSA_BACKEND_URL`

## Troubleshooting Quick Reference

### Common Error Messages
- "A valid publishable key is required": Check API key configuration and database seeding
- "relation does not exist": Run database migrations with `npx medusa db:setup`
- "SASL: SCRAM-SERVER-FIRST-MESSAGE": PostgreSQL authentication issue - check credentials
- "packageManager": "yarn@3.2.3": Run `corepack enable` to use correct Yarn version

### Reset Commands
To completely reset the development environment:
1. `cd noemi-medusa-backend && rm -rf node_modules .medusa && yarn install`
2. `DROP DATABASE IF EXISTS "medusa-v2"; CREATE DATABASE "medusa-v2";` (in PostgreSQL)
3. `npx medusa db:setup && yarn seed`
4. `cd ../noemi-medusa-storefront && rm -rf node_modules .next && yarn install`