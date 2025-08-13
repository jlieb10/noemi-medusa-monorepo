# Medusa E-commerce Monorepo

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites
- Install PostgreSQL and start the service:
  - `sudo apt update && sudo apt install -y postgresql postgresql-client`
  - `sudo service postgresql start`
  - `sudo -u postgres createdb medusa-v2`
  - `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"`

### Backend Setup (noemi-medusa-backend)
- Install dependencies: `yarn install` -- takes 7+ minutes. NEVER CANCEL. Set timeout to 10+ minutes.
- Configure environment:
  - `cp .env.template .env`
  - Update `.env` with: `DATABASE_URL=postgres://postgres:password@localhost/medusa-v2`
  - Also update: `POSTGRES_URL=postgres://postgres:password@localhost/medusa-v2`
- Run database migrations: `npx medusa db:migrate` -- takes 7-8 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- Seed the database: `yarn seed` -- takes 3.5 seconds. NEVER CANCEL. Set timeout to 1+ minutes.
- Build: `yarn build` -- takes 20 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- Dev server: `yarn dev` -- starts on port 9000 with admin at http://localhost:9000/app

### Storefront Setup (noemi-medusa-storefront)
- Enable Yarn 3: `corepack enable`
- Install dependencies: `yarn install --mode=update-lockfile && yarn install` -- takes 7+ minutes total. NEVER CANCEL. Set timeout to 10+ minutes.
- Configure environment:
  - Create `.env.local` from `.env.example`
  - Get publishable key token (not id): `sudo -u postgres psql -d medusa-v2 -c "SELECT token FROM public.api_key WHERE type = 'publishable';" | grep pk_`
  - Update `.env.local` with:
    ```
    NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
    MEDUSA_BACKEND_URL=http://localhost:9000
    NEXT_PUBLIC_BASE_URL=http://localhost:3000
    NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_[full_token_from_database]
    ```
- Build: `yarn build` -- takes 40+ seconds and requires backend running. NEVER CANCEL. Set timeout to 5+ minutes.
- Dev server: `yarn dev` -- starts on port 3000 (not 8000)

### Complete Setup Sequence
1. `sudo apt update && sudo apt install -y postgresql postgresql-client`
2. `sudo service postgresql start`
3. `sudo -u postgres createdb medusa-v2`
4. `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"`
5. `cd noemi-medusa-backend`
6. `yarn install` (7+ minutes)
7. `cp .env.template .env`
8. Edit `.env` to set `DATABASE_URL=postgres://postgres:password@localhost/medusa-v2` and `POSTGRES_URL=postgres://postgres:password@localhost/medusa-v2`
9. `npx medusa db:migrate` (7-8 seconds)
10. `yarn seed` (3.5 seconds)
11. `yarn build` (20 seconds)
12. `yarn dev &` (starts backend on port 9000)
13. `cd ../noemi-medusa-storefront`
14. `corepack enable`
15. `yarn install --mode=update-lockfile && yarn install` (7+ minutes)
16. Copy `.env.example` to `.env.local` and configure with backend URL and correct publishable key token
17. `yarn build` (40+ seconds, requires backend running)
18. `yarn dev` (starts storefront on port 3000)

## Validation

### Manual Testing Steps
- ALWAYS run through the complete setup sequence after making changes
- Test backend health: `curl http://localhost:9000/health` should return "OK"
- Test admin interface: navigate to http://localhost:9000/app
- Create admin user: `npx medusa user -e admin@test.com -p password123`
- Login to admin with created credentials and verify products are visible
- Test storefront: navigate to http://localhost:3000 (redirects to /dk)
- Test storefront store page: navigate to http://localhost:3000/dk/store
- NEVER test builds by stopping them early - wait for completion

### Known Limitations
- API key authentication requires the token value from database, not the id
- Build process for storefront requires backend to be running and properly configured API keys
- Unit tests: no tests found in backend (`yarn test:unit` passes but finds no tests)
- Integration tests: fail due to SWC configuration issue (`jest` expects es2022 target, not es2023)
- Storefront linting: has ESLint configuration issues but runs quickly (~2 seconds)

## Common Tasks

### Build Both Applications
```bash
# Backend (20 seconds)
cd noemi-medusa-backend && yarn build

# Storefront (40+ seconds, requires backend running)
cd noemi-medusa-storefront && yarn build
```

### Run Tests
```bash
# Backend unit tests (no tests found, passes)
cd noemi-medusa-backend && yarn test:unit

# Backend integration tests (fails due to SWC config issue)
cd noemi-medusa-backend && yarn test:integration:http

# Storefront linting (has config issues, ~2 seconds)
cd noemi-medusa-storefront && yarn lint
```

### User Management
```bash
# Create admin user
cd noemi-medusa-backend && npx medusa user -e admin@test.com -p password123

# Get publishable key token for storefront
sudo -u postgres psql -d medusa-v2 -c "SELECT token FROM public.api_key WHERE type = 'publishable';" | grep pk_
```

### Troubleshooting
- If PostgreSQL connection fails: verify service is running and password is set
- If storefront build fails: ensure backend is running and publishable key is correct token (not id)
- If API key errors occur: get token from database, not the api_key.id field
- If storefront shows 500 errors: verify both NEXT_PUBLIC_MEDUSA_BACKEND_URL and MEDUSA_BACKEND_URL are set
- Always check port availability (9000 for backend, 3000 for storefront)

### Repository Structure
```
.
├── noemi-medusa-backend/     # Medusa v2 backend server
│   ├── src/                  # Source code
│   ├── package.json          # Uses Yarn 1.x
│   ├── medusa-config.ts      # Backend configuration
│   └── .env.template         # Environment template
└── noemi-medusa-storefront/  # Next.js 15 storefront
    ├── src/                  # Source code
    ├── package.json          # Uses Yarn 3.x (via Corepack)
    └── .env.local            # Environment file (create manually)
```

### Critical Timing Information
- **Backend install**: 7+ minutes - NEVER CANCEL, set 10+ minute timeout
- **Backend build**: 20 seconds - set 2+ minute timeout
- **Backend migration**: 7-8 seconds - set 2+ minute timeout  
- **Backend seed**: 3.5 seconds - set 1+ minute timeout
- **Storefront install**: 7+ minutes total - NEVER CANCEL, set 10+ minute timeout
- **Storefront build**: 40+ seconds - NEVER CANCEL, set 5+ minute timeout

### Environment Variables Reference
**Backend (.env):**
```
DATABASE_URL=postgres://postgres:password@localhost/medusa-v2
DATABASE_URL=postgres://postgres:<YOUR_PASSWORD>@localhost/medusa-v2
POSTGRES_URL=postgres://postgres:<YOUR_PASSWORD>@localhost/medusa-v2
STORE_CORS=http://localhost:3000,http://localhost:1337,https://docs.medusajs.com
ADMIN_CORS=http://localhost:9000,http://localhost:3000,https://docs.medusajs.com
AUTH_CORS=http://localhost:9000,http://localhost:3000,https://docs.medusajs.com
REDIS_URL=redis://localhost:6379
JWT_SECRET=supersecret
COOKIE_SECRET=supersecret
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=masterkey
```

**Storefront (.env.local):**
```
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_BASE_URL=http://localhost:3000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_[full_token_from_database]
NODE_ENV=development
NEXT_PUBLIC_DEFAULT_REGION=us
```