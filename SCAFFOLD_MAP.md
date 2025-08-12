# 🚀 Noemi Medusa Monorepo - Development Scaffold Map

This repository contains a complete development environment for a modern e-commerce stack built with Medusa v2, Next.js, and various supporting services.

## 🏗️ Architecture Overview

The monorepo consists of the following services:

### Core Services
- **Frontend (Next.js)** - `http://localhost:3000/` - Customer-facing storefront
- **Medusa Backend** - `http://localhost:9000/` - E-commerce API and admin
- **Medusa Admin** - `http://localhost:9000/app/` - Admin dashboard

### Third-party Services
- **Strapi CMS** - `http://localhost:1337/` - Content management system
- **MeiliSearch** - `http://localhost:7700/` - Search engine
- **GrowthBook** - `http://localhost:3100/` - Feature flags and A/B testing
- **PostHog** - `http://localhost:8000/` - Product analytics
- **n8n** - `http://localhost:5678/` - Workflow automation

### Infrastructure Services
- **PostgreSQL** - `localhost:5432` - Primary database
- **Redis** - `localhost:6379` - Caching and sessions
- **MongoDB** - `localhost:27017` - Document database for GrowthBook

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- Node.js 20+ (for local development)
- Yarn package manager

### 1. Initial Setup
```bash
# Clone the repository (if not already done)
git clone <repository-url>
cd noemi-medusa-monorepo

# Run initial setup
./dev.sh setup
```

### 2. Start All Services
```bash
# Start the complete development stack
./dev.sh start
```

This will:
- Start all Docker containers
- Set up databases and dependencies
- Launch all services with proper networking

### 3. Access Your Services

Once all services are running, you can access:

| Service | URL | Description |
|---------|-----|-------------|
| 🏪 **Storefront** | http://localhost:3000 | Customer shopping experience |
| ⚡ **Medusa API** | http://localhost:9000 | E-commerce backend API |
| 📊 **Admin Dashboard** | http://localhost:9000/app | Store management |
| 📝 **Strapi CMS** | http://localhost:1337 | Content management |
| 🔍 **MeiliSearch** | http://localhost:7700 | Search dashboard |
| 📈 **GrowthBook** | http://localhost:3100 | Feature flags & experiments |
| 📊 **PostHog** | http://localhost:8000 | Analytics dashboard |
| 🔄 **n8n** | http://localhost:5678 | Workflow automation |

## 🛠️ Development Commands

The `dev.sh` script provides convenient commands for managing your development environment:

```bash
# Start all services
./dev.sh start

# Stop all services
./dev.sh stop

# Restart services
./dev.sh restart

# View logs (all services)
./dev.sh logs

# View logs for specific service
./dev.sh logs medusa-backend

# Check service status
./dev.sh status

# Show service map
./dev.sh services

# Clean up everything (removes all data)
./dev.sh cleanup

# Show help
./dev.sh help
```

## 📂 Project Structure

```
noemi-medusa-monorepo/
├── 📁 noemi-medusa-backend/     # Medusa v2 backend
│   ├── 📄 Dockerfile           # Backend container config
│   ├── 📄 package.json         # Backend dependencies
│   └── 📁 src/                 # Backend source code
├── 📁 noemi-medusa-storefront/  # Next.js frontend
│   ├── 📄 Dockerfile           # Frontend container config
│   ├── 📄 package.json         # Frontend dependencies
│   └── 📁 src/                 # Frontend source code
├── 📄 docker-compose.yml       # Service orchestration
├── 📄 dev.sh                   # Development script
└── 📄 README.md                # This file
```

## 🔑 Default Credentials

### n8n Workflow Automation
- **Username:** `admin`
- **Password:** `admin`
- **URL:** http://localhost:5678

### MeiliSearch
- **Master Key:** `masterkey`
- **URL:** http://localhost:7700

### Database Access
- **PostgreSQL:** `medusa:medusa@localhost:5432`
- **Redis:** `localhost:6379` (no auth)
- **MongoDB:** `localhost:27017` (no auth)

### First-time Setup Required
- **Strapi CMS:** http://localhost:1337 - Create admin account on first visit
- **GrowthBook:** http://localhost:3100 - Set up organization on first visit
- **PostHog:** http://localhost:8000 - Configure instance on first visit

## 🔧 Configuration

### Environment Variables

The services are pre-configured with development-friendly defaults. Key configuration:

#### Backend (.env)
```env
DATABASE_URL=postgres://medusa:medusa@postgres:5432/medusa-v2
REDIS_URL=redis://redis:6379
STORE_CORS=http://localhost:3000,http://localhost:1337
ADMIN_CORS=http://localhost:9000,http://localhost:3000
```

#### Frontend
```env
NEXT_PUBLIC_MEDUSA_BACKEND_URL=http://localhost:9000
NEXT_PUBLIC_BASE_URL=http://localhost:3000
```

### Service Integration

The services are configured to work together:

1. **Medusa ↔ MeiliSearch**: Search functionality
2. **Frontend ↔ PostHog**: Analytics tracking  
3. **Strapi ↔ Frontend**: Content delivery
4. **GrowthBook ↔ Frontend**: Feature flags
5. **n8n ↔ All Services**: Workflow automation

## 🐛 Troubleshooting

### Services Not Starting
```bash
# Check Docker status
docker ps

# View service logs
./dev.sh logs

# Restart specific service
docker-compose restart <service-name>
```

### Port Conflicts
If you have services running on the required ports:
- Stop conflicting services
- Or modify ports in `docker-compose.yml`

### Database Issues
```bash
# Reset all data
./dev.sh cleanup
./dev.sh start
```

### Memory Issues
Ensure Docker has sufficient memory allocated (recommended: 4GB+)

## 🚀 Production Deployment

This setup is optimized for development. For production:

1. Use production-ready images
2. Configure proper secrets and environment variables
3. Set up SSL/TLS certificates
4. Configure proper networking and security
5. Set up monitoring and logging
6. Use managed databases instead of Docker containers

## 🤝 Contributing

1. Make changes to your local environment
2. Test with `./dev.sh start`
3. Submit pull requests with detailed descriptions

## 📚 Additional Resources

- [Medusa Documentation](https://docs.medusajs.com/)
- [Next.js Documentation](https://nextjs.org/docs)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [Strapi Documentation](https://docs.strapi.io/)
- [MeiliSearch Documentation](https://www.meilisearch.com/docs)
- [GrowthBook Documentation](https://docs.growthbook.io/)
- [PostHog Documentation](https://posthog.com/docs)
- [n8n Documentation](https://docs.n8n.io/)

---

**Happy coding! 🎉**