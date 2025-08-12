# AI Agent Instructions for NOEMI E-commerce Platform

This document provides comprehensive instructions for AI agents working on the NOEMI luxury supplements e-commerce platform.

## 🎯 Project Overview

**Mission**: Build a high-end e-commerce platform for luxury supplements that rivals Shopify stores while maintaining complete developer control and extensibility.

**Tech Stack**:
- Backend: Medusa v2 + PostgreSQL/Supabase
- Frontend: Next.js 15 + React 18 + Tailwind CSS
- Database: Supabase (PostgreSQL)
- Deployment: Vercel (Frontend) + Railway/Fly.io (Backend)

## 🏗️ Architecture Decisions

### Monorepo Structure
```
noemi-medusa-monorepo/
├── noemi-medusa-backend/     # Medusa v2 e-commerce engine
├── noemi-medusa-storefront/  # Next.js 15 storefront
├── docs/                     # Documentation
└── .github/                  # CI/CD workflows
```

### Key Design Principles
1. **Modularity**: Each feature should be self-contained
2. **Performance**: Target Lighthouse score ≥ 95
3. **Accessibility**: WCAG 2.1 AA compliance
4. **SEO**: Rich snippets and structured data
5. **Developer Experience**: TypeScript, testing, documentation

## 🛠️ Development Guidelines

### Code Standards
- **TypeScript**: Strict mode enabled, no `any` types
- **Formatting**: ESLint + Prettier with auto-fix
- **Testing**: Jest (unit/integration) + Playwright (E2E)
- **Commits**: Conventional commits format
- **Documentation**: JSDoc for public APIs

### File Organization
```
Backend (Medusa):
├── src/api/          # Custom API routes
├── src/modules/      # Business logic modules
├── src/workflows/    # Business workflows
├── src/subscribers/  # Event subscribers
└── src/scripts/      # Utility scripts

Frontend (Next.js):
├── src/app/          # App router pages
├── src/modules/      # UI components
├── src/lib/          # Utilities and data fetching
└── src/styles/       # Global styles
```

### Environment Setup
Always ensure these environment variables are set:

**Backend (.env)**:
```env
DATABASE_URL=postgresql://username:password@host:port/database
REDIS_URL=redis://localhost:6379
JWT_SECRET=development-secret
COOKIE_SECRET=development-secret
```

**Frontend (.env.local)**:
```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_dev_placeholder
```

## 📋 Task Execution Guidelines

### Before Starting Any Task
1. **Read the current state**: Check existing code and documentation
2. **Understand dependencies**: Review package.json and imports
3. **Test current functionality**: Ensure builds and tests pass
4. **Plan minimal changes**: Scope work to smallest necessary changes

### Common Task Types

#### Backend Development
```bash
# Start backend development
cd noemi-medusa-backend
npm run dev  # Starts on localhost:9000

# Test backend
npm run test:unit
npm run test:integration:http

# Build backend
npm run build
```

Key backend patterns:
- API routes in `src/api/[area]/[endpoint]/route.ts`
- Business logic in `src/modules/`
- Database models follow Medusa conventions
- Use dependency injection with Awilix

#### Frontend Development
```bash
# Start frontend development
cd noemi-medusa-storefront
npm run dev  # Starts on localhost:8000

# Test frontend
npm run test
npm run lint

# Build frontend
npm run build
```

Key frontend patterns:
- Pages in `src/app/[...]/page.tsx` (App Router)
- Components in `src/modules/[feature]/`
- Data fetching in `src/lib/data/`
- Styling with Tailwind CSS classes

### Testing Strategy
1. **Unit Tests**: Individual functions and components
2. **Integration Tests**: API endpoints and data flows
3. **E2E Tests**: Complete user journeys
4. **Performance Tests**: Core Web Vitals and load times

## 🎨 Design Implementation

### Essential Template Integration
The frontend should follow the [Essential Framer template](https://essential.framer.media/) design principles:

**Colors** (Luxury Supplements Theme):
```css
:root {
  --primary: #1a1a1a;      /* Deep black */
  --secondary: #f5f5f5;    /* Soft white */
  --accent: #c9a96e;       /* Luxury gold */
  --text: #333333;         /* Dark gray text */
  --muted: #6b7280;        /* Muted gray */
}
```

**Typography**:
- Primary: Inter (clean, modern)
- Headings: Inter SemiBold/Bold
- Body: Inter Regular
- Size scale: 14px, 16px, 18px, 24px, 32px, 48px

**Layout Principles**:
- 8px grid system
- Generous whitespace
- Mobile-first responsive design
- Maximum content width: 1200px

### Component Development
Follow this pattern for new components:

```typescript
// Example: ProductCard component
interface ProductCardProps {
  product: Product
  variant?: 'default' | 'featured'
  className?: string
}

export function ProductCard({ 
  product, 
  variant = 'default', 
  className 
}: ProductCardProps) {
  return (
    <div className={cn(
      "group relative rounded-lg bg-white shadow-sm",
      "hover:shadow-md transition-shadow duration-200",
      className
    )}>
      {/* Implementation */}
    </div>
  )
}
```

## 🔌 Feature Implementation Priorities

### Phase 1: Core E-commerce ✅
- [x] Product catalog
- [x] Shopping cart
- [x] Checkout flow
- [x] User authentication
- [x] Order management

### Phase 2: Supplements-Specific 🚧
- [ ] Subscription management
- [ ] Ingredient information
- [ ] Dosage instructions
- [ ] Health compliance features
- [ ] Customer health profiles

### Phase 3: Performance & SEO 🚧
- [ ] Structured data implementation
- [ ] Sitemap generation
- [ ] Image optimization
- [ ] Core Web Vitals optimization
- [ ] Accessibility improvements

### Phase 4: Advanced Features 🚧
- [ ] Search and filtering
- [ ] Recommendations engine
- [ ] Email marketing integration
- [ ] Analytics and reporting
- [ ] Multi-language support

## 🚀 Deployment Instructions

### Development Deployment
1. **Backend**: Railway or Fly.io
2. **Frontend**: Vercel
3. **Database**: Supabase
4. **Redis**: Upstash or Railway

### Production Deployment
1. **Domain Setup**: Configure custom domains
2. **SSL**: Automatic via Vercel and Railway
3. **CDN**: Vercel Edge Network
4. **Monitoring**: Sentry for error tracking
5. **Analytics**: Vercel Analytics + Custom events

### Environment Configuration

**Staging**:
```env
# Backend
DATABASE_URL=postgres://staging-db-url
REDIS_URL=redis://staging-redis-url
NODE_ENV=staging

# Frontend  
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://staging-api.noemi.com
NODE_ENV=staging
```

**Production**:
```env
# Backend
DATABASE_URL=postgres://prod-db-url
REDIS_URL=redis://prod-redis-url
NODE_ENV=production

# Frontend
NEXT_PUBLIC_MEDUSA_BACKEND_URL=https://api.noemi.com
NODE_ENV=production
```

## 🧪 Testing Protocols

### Pre-commit Checklist
- [ ] All TypeScript compiles without errors
- [ ] ESLint passes without warnings
- [ ] Prettier formatting applied
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] No console errors in development

### Pre-deployment Checklist
- [ ] Build completes successfully
- [ ] E2E tests pass
- [ ] Lighthouse score ≥ 90
- [ ] No accessibility violations
- [ ] Environment variables configured
- [ ] Database migrations run

### Performance Benchmarks
- **Lighthouse Performance**: ≥ 95
- **Lighthouse SEO**: ≥ 95
- **Lighthouse Accessibility**: ≥ 95
- **First Contentful Paint**: < 1.5s
- **Largest Contentful Paint**: < 2.5s
- **Time to Interactive**: < 3.0s

## 🔧 Troubleshooting Guide

### Common Issues

**Build Failures**:
1. Check environment variables are set
2. Verify all dependencies are installed
3. Clear build cache: `rm -rf .next/ dist/`
4. Check TypeScript errors

**API Connection Issues**:
1. Verify backend is running on correct port
2. Check CORS configuration
3. Validate environment variables
4. Test API endpoints directly

**Database Issues**:
1. Check database connection string
2. Verify database is accessible
3. Run migrations: `npm run migration:run`
4. Check database permissions

### Performance Issues
1. Run Lighthouse audit
2. Check bundle size with `npm run analyze`
3. Optimize images and assets
4. Review database queries
5. Implement caching strategies

## 📞 Support Resources

- **Medusa Docs**: https://docs.medusajs.com
- **Next.js Docs**: https://nextjs.org/docs
- **Supabase Docs**: https://supabase.com/docs
- **Essential Template**: https://essential.framer.media/

## 🎯 Success Criteria

### Technical Excellence
- Zero runtime errors in production
- Lighthouse scores ≥ 95 across all categories
- 100% TypeScript coverage
- Comprehensive test coverage (≥ 80%)

### Business Goals
- Shopify feature parity
- Sub-3s page load times
- Mobile conversion optimization
- SEO rankings in top 3 for target keywords

### Maintainability
- Clear documentation for all features
- Modular, extensible architecture
- Automated deployment pipeline
- Monitoring and alerting setup