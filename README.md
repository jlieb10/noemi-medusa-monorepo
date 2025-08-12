# NOEMI Luxury Supplements E-commerce Platform

A modern, high-performance e-commerce platform for luxury supplements built with Medusa v2, Next.js 15, and Supabase.

## 🏗️ Architecture

This is a monorepo containing:

- **Backend** (`noemi-medusa-backend`): Medusa v2 e-commerce engine with PostgreSQL/Supabase
- **Frontend** (`noemi-medusa-storefront`): Next.js 15 storefront with React 18 and Tailwind CSS

## 🚀 Quick Start

### Prerequisites

- Node.js 20+ 
- npm or yarn
- PostgreSQL database (or Supabase account)
- Redis (for session storage)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd noemi-medusa-monorepo
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:

**Backend** (`noemi-medusa-backend/.env`):
```env
DATABASE_URL=postgres://username:password@localhost:5432/noemi_medusa_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-jwt-secret
COOKIE_SECRET=your-cookie-secret
```

**Frontend** (`noemi-medusa-storefront/.env.local`):
```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=your-publishable-key
```

4. Start development servers:
```bash
# Start both backend and frontend
npm run dev

# Or start individually
npm run dev:backend   # Backend on http://localhost:9000
npm run dev:frontend  # Frontend on http://localhost:8000
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

## 🛠️ Development Workflow

### Backend Development (Medusa)

The backend runs on `http://localhost:9000` with:
- Admin panel at `http://localhost:9000/app`
- Store API at `http://localhost:9000/store`
- Admin API at `http://localhost:9000/admin`

Key directories:
- `src/api/` - Custom API routes
- `src/modules/` - Custom business logic modules
- `src/workflows/` - Business workflow definitions
- `src/subscribers/` - Event subscribers

### Frontend Development (Next.js)

The storefront runs on `http://localhost:8000` with:
- Modern Next.js 15 App Router
- React 18 with Suspense and Server Components
- Tailwind CSS for styling
- TypeScript for type safety

Key directories:
- `src/app/` - Next.js app router pages
- `src/modules/` - Reusable UI components
- `src/lib/` - Utilities and data fetching
- `src/styles/` - Global styles and Tailwind config

## 🎨 Design System

The frontend is based on the [Essential Framer template](https://essential.framer.media/) adapted for luxury supplements branding:

- Clean, minimalist design
- Premium typography (Inter font family)
- Sophisticated color palette
- Mobile-first responsive design
- Accessibility-compliant (WCAG standards)

## 🔌 Features

### E-commerce Core
- ✅ Product catalog with variants and inventory
- ✅ Shopping cart and checkout flow
- ✅ Customer accounts and authentication
- ✅ Order management
- 🚧 Multi-currency support
- 🚧 Multi-region shipping
- 🚧 Tax calculation

### Supplements-Specific
- 🚧 Subscription management for recurring orders
- 🚧 Ingredient and nutrition information
- 🚧 Health claims and regulatory compliance
- 🚧 Dosage and usage instructions
- 🚧 Customer health profiles

### Performance & SEO
- ✅ Server-side rendering (SSR)
- ✅ Static generation where appropriate
- ✅ Image optimization
- 🚧 Structured data (JSON-LD)
- 🚧 Sitemap generation
- 🚧 Meta tags optimization
- 🚧 Core Web Vitals optimization

### Developer Experience
- ✅ TypeScript throughout
- ✅ ESLint and Prettier
- ✅ Hot module replacement
- 🚧 Component documentation
- 🚧 API documentation

## 🧪 Testing

### Test Setup
- Backend: Jest for unit and integration tests
- Frontend: Jest + Testing Library for components
- E2E: Playwright for full user flows

### Running Tests
```bash
# All tests
npm run test

# Backend only
npm run test:integration --workspace=noemi-medusa-backend

# Frontend only  
npm run test --workspace=noemi-medusa-storefront

# E2E tests
npm run test:e2e
```

## 📦 Deployment

### Staging Environment
- Backend: Railway/Fly.io
- Frontend: Vercel
- Database: Supabase

### Production Environment
- Backend: Railway/Fly.io with auto-scaling
- Frontend: Vercel with Edge Functions
- Database: Supabase with connection pooling
- CDN: Vercel Edge Network

### Environment Variables

**Production Backend:**
```env
DATABASE_URL=postgres://...
REDIS_URL=redis://...
JWT_SECRET=prod-secret
COOKIE_SECRET=prod-secret
STORE_CORS=https://your-domain.com
ADMIN_CORS=https://admin.your-domain.com
```

**Production Frontend:**
```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.your-domain.com
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_live_...
NEXT_PUBLIC_STRIPE_KEY=pk_live_...
```

## 🚧 Roadmap

### Phase 1: Foundation ✅
- [x] Monorepo setup
- [x] Basic Medusa backend
- [x] Next.js storefront  
- [x] Environment configuration

### Phase 2: Backend Features 🚧
- [ ] Supabase database integration
- [ ] Subscription management module
- [ ] Enhanced product models for supplements
- [ ] Custom API endpoints
- [ ] Email notifications

### Phase 3: Frontend Features 🚧
- [ ] Essential template integration
- [ ] Core e-commerce pages
- [ ] Subscription management UI
- [ ] Customer account features
- [ ] Search and filtering

### Phase 4: Optimization 🚧
- [ ] SEO implementation
- [ ] Performance optimization
- [ ] Accessibility compliance
- [ ] Security hardening

### Phase 5: Testing & QA 🚧
- [ ] Comprehensive test suite
- [ ] E2E automation
- [ ] Performance testing
- [ ] Security testing

### Phase 6: Deployment 🚧
- [ ] CI/CD pipeline
- [ ] Staging environment
- [ ] Production deployment
- [ ] Monitoring and analytics

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

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For development questions and support:
- Check the [Medusa documentation](https://docs.medusajs.com)
- Review [Next.js documentation](https://nextjs.org/docs)
- Open an issue in this repository

## 🎯 Goals

- **Performance**: Lighthouse score ≥ 95
- **Accessibility**: WCAG 2.1 AA compliance
- **SEO**: Rich snippets and structured data
- **Conversion**: Optimized checkout and subscription flows
- **Maintainability**: Clean, documented, tested code