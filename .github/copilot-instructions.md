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
- Install dependencies: `yarn install` -- takes 4 minutes. NEVER CANCEL. Set timeout to 8+ minutes.
- Configure environment:
  - `cp .env.template .env`
  - `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'your_secure_password';"`
    > **Important:** Replace `'your_secure_password'` with a strong, unique password. Do not use `'password'` as your actual password.

### Backend Setup (noemi-medusa-backend)
- Install dependencies: `yarn install` -- takes 4 minutes. NEVER CANCEL. Set timeout to 8+ minutes.
- Configure environment:
  - Update `.env` with: `DATABASE_URL=postgres://postgres:your_secure_password@localhost/medusa-v2`
    > **Important:** Use the same strong password you set for the PostgreSQL user above.
- Run database migrations: `npx medusa db:migrate` -- takes 7 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- Seed the database: `yarn seed` -- takes 3.5 seconds. NEVER CANCEL. Set timeout to 1+ minutes.
- Build: `yarn build` -- takes 25 seconds. NEVER CANCEL. Set timeout to 2+ minutes.
- Dev server: `yarn dev` -- starts on port 9000 with admin at http://localhost:9000/app

### Storefront Setup (noemi-medusa-storefront)
- Enable Yarn 3: `corepack enable`
- Install dependencies: `yarn install` -- takes 2.5 minutes. NEVER CANCEL. Set timeout to 5+ minutes.
- Configure environment:
  - Create `.env.local` with:
    ```
    NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=apk_01K2G4WPKQWD7T8J1N4Y71BAVT
    MEDUSA_BACKEND_URL=http://localhost:9000
    ```
  - Get actual publishable key from: `sudo -u postgres psql medusa-v2 -c "SELECT id FROM public.api_key WHERE type = 'publishable';"`
- Build: `yarn build` -- may require backend running. NEVER CANCEL. Set timeout to 5+ minutes.
- Dev server: `yarn dev` -- starts on port 8000

### Complete Setup Sequence
1. `sudo apt update && sudo apt install -y postgresql postgresql-client`
2. `sudo service postgresql start`
3. `sudo -u postgres createdb medusa-v2`
4. `sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'password';"`
5. `cd noemi-medusa-backend`
6. `yarn install` (4 minutes)
7. `cp .env.template .env`
8. `echo 'DATABASE_URL=postgres://postgres:your_secure_password@localhost/medusa-v2' >> .env`
   > **Important:** Replace `your_secure_password` with the strong password you set for the PostgreSQL user above.
9. `npx medusa db:migrate` (7 seconds)
10. `yarn seed` (3.5 seconds)
11. `yarn dev &` (starts backend on port 9000)
12. `cd ../noemi-medusa-storefront`
13. `corepack enable`
14. `yarn install` (2.5 minutes)
15. Create `.env.local` with backend URL and publishable key
16. `yarn dev` (starts storefront on port 8000)

## Validation

### Manual Testing Steps
- ALWAYS run through the complete setup sequence after making changes
- Test backend health: `curl http://localhost:9000/health` should return "OK"
- Test admin interface: navigate to http://localhost:9000/app
- Test storefront: navigate to http://localhost:8000
- NEVER test builds by stopping them early - wait for completion

### Known Limitations
- API key authentication between backend and storefront requires manual configuration
- Build process for storefront requires backend to be running and properly configured API keys
- Unit tests require additional database setup not covered in standard workflow
- Integration tests may fail due to database authentication requirements
- Storefront linting has configuration issues but runs quickly (~2 seconds)

## Common Tasks

### Build Both Applications
```bash
# Backend (25 seconds)
cd noemi-medusa-backend && yarn build

# Storefront (timing varies, requires backend running)
cd noemi-medusa-storefront && yarn build
```

### Run Tests
```bash
# Backend unit tests (no tests found)
cd noemi-medusa-backend && yarn test:unit

# Backend integration tests (requires database auth setup)
cd noemi-medusa-backend && yarn test:integration:http

# Storefront linting (has config issues, ~2 seconds)
cd noemi-medusa-storefront && yarn lint
```

### Troubleshooting
- If PostgreSQL connection fails: verify service is running and password is set
- If storefront build fails: ensure backend is running and publishable key is correct
- If API key errors occur: regenerate publishable key using admin interface or database
- Always check port availability (9000 for backend, 8000 for storefront)

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
- **Backend install**: 4 minutes - NEVER CANCEL, set 8+ minute timeout
- **Backend build**: 25 seconds - set 2+ minute timeout
- **Backend migration**: 7 seconds - set 2+ minute timeout  
- **Backend seed**: 3.5 seconds - set 1+ minute timeout
- **Storefront install**: 2.5 minutes - NEVER CANCEL, set 5+ minute timeout
- **Storefront build**: Variable timing - NEVER CANCEL, set 5+ minute timeout

### Environment Variables Reference
**Backend (.env):**
```
DATABASE_URL=postgres://postgres:password@localhost/medusa-v2
STORE_CORS=http://localhost:8000,https://docs.medusajs.com
ADMIN_CORS=http://localhost:5173,http://localhost:9000,https://docs.medusajs.com
AUTH_CORS=http://localhost:5173,http://localhost:9000,https://docs.medusajs.com
JWT_SECRET=supersecret
COOKIE_SECRET=supersecret
```

**Storefront (.env.local):**
```
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_XXXXXXXXXXXXXXXXXXXXXXX
MEDUSA_BACKEND_URL=http://localhost:9000
```