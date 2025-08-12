#!/bin/bash

# Noemi Medusa Monorepo Development Script
# This script helps manage the entire development stack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Function to display service status
show_services() {
    cat << EOF

${GREEN}🚀 Noemi Medusa Monorepo Service Map${NC}
═══════════════════════════════════════════════════════════

${BLUE}Core Services:${NC}
├── 🏪 Frontend (Next.js)     → http://localhost:3000/
├── ⚡ Medusa Backend         → http://localhost:9000/
└── 📊 Medusa Admin          → http://localhost:9000/app/

${BLUE}Third-party Services:${NC}
├── 📝 Strapi CMS            → http://localhost:1337/
├── 🔍 MeiliSearch            → http://localhost:7700/
├── 📈 GrowthBook             → http://localhost:3100/
├── 📊 PostHog                → http://localhost:8000/
└── 🔄 n8n                    → http://localhost:5678/

${BLUE}Infrastructure:${NC}
├── 🐘 PostgreSQL             → localhost:5432
├── 🗄️  Redis                 → localhost:6379
└── 🍃 MongoDB                → localhost:27017

${YELLOW}Default Credentials:${NC}
├── n8n: admin / admin
├── Strapi: Set up on first run
├── GrowthBook: Set up on first run
└── MeiliSearch: masterkey

═══════════════════════════════════════════════════════════
EOF
}

# Function to start all services
start_services() {
    print_status "Starting Noemi Medusa Monorepo services..."
    check_docker
    
    docker compose up -d --build
    
    print_success "Services are starting up!"
    print_warning "Initial startup may take several minutes for all services to be ready."
    
    show_services
    
    print_status "Use './dev.sh logs' to view real-time logs"
    print_status "Use './dev.sh status' to check service health"
}

# Function to stop all services
stop_services() {
    print_status "Stopping all services..."
    docker compose down
    print_success "All services stopped."
}

# Function to restart services
restart_services() {
    print_status "Restarting all services..."
    docker compose restart
    print_success "All services restarted."
}

# Function to show logs
show_logs() {
    if [ -n "$2" ]; then
        print_status "Showing logs for service: $2"
        docker compose logs -f "$2"
    else
        print_status "Showing logs for all services (use Ctrl+C to exit)"
        docker compose logs -f
    fi
}

# Function to show service status
show_status() {
    print_status "Service Status:"
    docker compose ps
    
    echo ""
    print_status "Health Check Status:"
    docker compose ps --format "table {{.Service}}\t{{.Status}}\t{{.Ports}}"
}

# Function to clean up everything
cleanup() {
    print_warning "This will remove all containers, volumes, and data. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        print_status "Cleaning up all services and data..."
        docker compose down -v --remove-orphans
        docker system prune -f
        print_success "Cleanup completed."
    else
        print_status "Cleanup cancelled."
    fi
}

# Function to run development setup
dev_setup() {
    print_status "Setting up development environment..."
    
    # Install dependencies for backend
    print_status "Installing backend dependencies..."
    cd noemi-medusa-backend && yarn install && cd ..
    
    # Install dependencies for frontend  
    print_status "Installing frontend dependencies..."
    cd noemi-medusa-storefront && yarn install && cd ..
    
    # Create environment files if they don't exist
    if [ ! -f "noemi-medusa-backend/.env" ]; then
        print_status "Creating backend environment file..."
        cp noemi-medusa-backend/.env.template noemi-medusa-backend/.env
    fi
    
    print_success "Development setup completed!"
    print_status "You can now run './dev.sh start' to start all services."
}

# Function to show help
show_help() {
    cat << EOF
${GREEN}Noemi Medusa Monorepo Development Script${NC}

${BLUE}Usage:${NC}
  ./dev.sh <command> [options]

${BLUE}Commands:${NC}
  start         Start all services
  stop          Stop all services  
  restart       Restart all services
  logs [service] Show logs (optionally for specific service)
  status        Show service status
  services      Show service map
  setup         Initial development setup
  cleanup       Remove all containers and data
  help          Show this help message

${BLUE}Examples:${NC}
  ./dev.sh start                 # Start all services
  ./dev.sh logs medusa-backend   # Show backend logs
  ./dev.sh status                # Check service health
  ./dev.sh cleanup               # Clean everything

${BLUE}Service Names:${NC}
  medusa-backend, medusa-storefront, postgres, redis,
  meilisearch, posthog, growthbook, mongo, n8n, strapi
EOF
}

# Main script logic
case "$1" in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs "$@"
        ;;
    status)
        show_status
        ;;
    services)
        show_services
        ;;
    setup)
        dev_setup
        ;;
    cleanup)
        cleanup
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac