# Quick Developer Guide

This guide covers the most common development tasks for the NOEMI e-commerce platform.

## 🚀 Quick Start

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd noemi-medusa-monorepo
   ./setup.sh
   ```

2. **Start development**:
   ```bash
   npm run dev          # Both backend and frontend
   # OR
   npm run dev:backend  # Backend only (port 9000)
   npm run dev:frontend # Frontend only (port 8000)
   ```

## 🛠️ Common Commands

### Development
```bash
# Start both services
npm run dev

# Start individually
npm run dev:backend
npm run dev:frontend

# Build both
npm run build

# Run tests
npm run test
npm run test:integration

# Lint code
npm run lint

# Type checking
npm run typecheck

# Clean build artifacts
npm run clean
```

### Database Operations
```bash
# Seed the database with sample data
npm run seed

# Run database migrations (backend only)
cd noemi-medusa-backend
npm run migration:run
```

## 📁 Project Structure

```
noemi-medusa-monorepo/
├── docs/                      # Documentation
├── noemi-medusa-backend/      # Medusa v2 backend
│   ├── src/
│   │   ├── api/              # Custom API routes
│   │   ├── modules/          # Business logic modules
│   │   ├── workflows/        # Business workflows
│   │   └── scripts/          # Utility scripts
│   ├── .env                  # Backend environment
│   └── medusa-config.ts      # Medusa configuration
├── noemi-medusa-storefront/   # Next.js frontend
│   ├── src/
│   │   ├── app/              # Next.js app router pages
│   │   ├── modules/          # UI components
│   │   ├── lib/              # Utilities and data fetching
│   │   └── styles/           # Global styles
│   ├── .env.local            # Frontend environment
│   └── next.config.js        # Next.js configuration
└── package.json               # Root workspace configuration
```

## 🔧 Environment Setup

### Backend (.env)
```env
DATABASE_URL=postgres://user:pass@localhost:5432/dbname
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-jwt-secret
COOKIE_SECRET=your-cookie-secret
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=pk_dev_your_key
```

## 🏗️ Development Workflow

### Adding a New Feature

1. **Backend** (if needed):
   ```bash
   cd noemi-medusa-backend
   # Add API route in src/api/
   # Add business logic in src/modules/
   # Add tests
   npm run test:unit
   ```

2. **Frontend**:
   ```bash
   cd noemi-medusa-storefront
   # Add components in src/modules/
   # Add pages in src/app/
   # Add data fetching in src/lib/
   npm run lint
   npm run typecheck
   ```

3. **Test & Build**:
   ```bash
   npm run build
   npm run test
   ```

### Creating a New API Endpoint

1. Create file: `noemi-medusa-backend/src/api/store/your-endpoint/route.ts`
2. Export HTTP methods:
   ```typescript
   import type { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";

   export async function GET(req: MedusaRequest, res: MedusaResponse) {
     res.json({ message: "Hello from your endpoint!" });
   }
   ```

### Creating a New Frontend Page

1. Create file: `noemi-medusa-storefront/src/app/[countryCode]/your-page/page.tsx`
2. Export default component:
   ```typescript
   export default function YourPage() {
     return <div>Your page content</div>;
   }
   ```

## 🎨 Styling Guidelines

### Using Tailwind CSS
```typescript
// Use Tailwind classes for styling
<div className="bg-white shadow-sm rounded-lg p-6 hover:shadow-md transition-shadow">
  <h2 className="text-xl font-semibold text-gray-900">Product Title</h2>
  <p className="text-gray-600 mt-2">Product description</p>
</div>
```

### Design System Colors
```typescript
// Primary colors
"bg-gray-900"     // Primary black
"bg-gray-50"      // Soft white  
"bg-amber-600"    // Luxury gold accent
"text-gray-800"   // Dark text
"text-gray-500"   // Muted text
```

## 🧪 Testing

### Backend Tests
```bash
cd noemi-medusa-backend
npm run test:unit                    # Unit tests
npm run test:integration:http        # API tests
npm run test:integration:modules     # Module tests
```

### Frontend Tests
```bash
cd noemi-medusa-storefront
npm run test                         # Component tests
npm run test:e2e                     # E2E tests (when configured)
```

## 🚀 Deployment

### Quick Deployment Checklist
- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] Build completes successfully
- [ ] Tests pass
- [ ] No TypeScript errors

### Deployment Commands
```bash
# Build for production
npm run build

# Check for TypeScript errors
npm run typecheck

# Run security audit
npm audit
```

## 🔍 Debugging

### Backend Issues
1. Check database connection
2. Verify environment variables
3. Check Medusa logs
4. Test API endpoints with curl/Postman

### Frontend Issues
1. Check browser console for errors
2. Verify API connection to backend
3. Check environment variables
4. Test with Network tab in DevTools

### Common Issues
- **Port conflicts**: Change ports in package.json scripts
- **Database connection**: Verify DATABASE_URL format
- **CORS errors**: Check CORS configuration in backend
- **Build failures**: Clear cache with `npm run clean`

## 📚 Resources

- [Medusa Documentation](https://docs.medusajs.com)
- [Next.js Documentation](https://nextjs.org/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [TypeScript Documentation](https://www.typescriptlang.org/docs)

## 🆘 Getting Help

1. Check the main README.md
2. Review docs/agents.md for AI development guidelines
3. Check docs/deployment.md for deployment issues
4. Open an issue in the repository
5. Consult the Medusa Discord community