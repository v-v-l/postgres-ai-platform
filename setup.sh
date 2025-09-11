#!/bin/bash

# PostgreSQL AI/ML Platform with Observability - Automated Setup
# This script sets up a complete PostgreSQL 17 + pgvector + Grafana + Prometheus + Jaeger stack

set -e  # Exit on any error

echo "🐘 PostgreSQL AI/ML Platform Setup"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker first.${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Generating secure passwords...${NC}"

# Generate secure passwords
DB_PASSWORD=$(openssl rand -base64 32)
GRAFANA_PASSWORD=$(openssl rand -base64 32)

echo -e "${GREEN}✅ Passwords generated${NC}"

# Create .env file
echo -e "${BLUE}📝 Creating .env configuration...${NC}"

cat > .env << EOF
# PostgreSQL Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=${DB_PASSWORD}
# Non-default port for security and conflict avoidance
POSTGRES_PORT=5433

# Network binding - localhost only for security
POSTGRES_HOST=127.0.0.1

# Observability Stack Ports (non-default for security)
GRAFANA_PORT=3005
GRAFANA_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
JAEGER_UI_PORT=16687
JAEGER_COLLECTOR_PORT=14251
PROMETHEUS_PORT=9091

# Connection URL for applications
DATABASE_URL=postgresql://postgres:${DB_PASSWORD}@localhost:5433/postgres
EOF

echo -e "${GREEN}✅ Environment configuration created${NC}"

# Configure network access
echo -e "${BLUE}🔧 Configuring network access...${NC}"
if [ -f "configure-network.sh" ]; then
    ./configure-network.sh >/dev/null 2>&1 || true
fi

# Clean up any old data (PostgreSQL version upgrade)
echo -e "${BLUE}🧹 Cleaning up old data directories...${NC}"
rm -rf ./data/prod ./data/dev 2>/dev/null || true

# Stop any existing containers
echo -e "${BLUE}🛑 Stopping existing containers...${NC}"
if [ -f "docker-compose.override.yml" ]; then
    docker-compose -f docker-compose.prod.yml -f docker-compose.override.yml down >/dev/null 2>&1 || true
else
    docker-compose -f docker-compose.prod.yml down >/dev/null 2>&1 || true
fi

# Start the production stack
echo -e "${BLUE}🚀 Starting PostgreSQL AI/ML + Observability Stack...${NC}"
if [ -f "docker-compose.override.yml" ]; then
    docker-compose -f docker-compose.prod.yml -f docker-compose.override.yml up -d
else
    docker-compose -f docker-compose.prod.yml up -d
fi

# Wait for services to start
echo -e "${BLUE}⏳ Waiting for services to initialize...${NC}"
sleep 15

# Check service health
echo -e "${BLUE}🔍 Checking service health...${NC}"

# Check PostgreSQL
echo -n "  PostgreSQL 17: "
if psql "postgresql://postgres:${DB_PASSWORD}@localhost:5433/postgres" -c "SELECT version();" >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Running${NC}"
    
    # Check pgvector extension
    echo -n "  pgvector extension: "
    if psql "postgresql://postgres:${DB_PASSWORD}@localhost:5433/postgres" -c "SELECT extname FROM pg_extension WHERE extname = 'vector';" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Enabled${NC}"
    else
        echo -e "${RED}❌ Not found${NC}"
    fi
else
    echo -e "${RED}❌ Failed to connect${NC}"
fi

# Check Grafana
echo -n "  Grafana: "
if curl -s http://localhost:3005 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Running on port 3005${NC}"
else
    echo -e "${RED}❌ Not accessible${NC}"
fi

# Check Prometheus
echo -n "  Prometheus: "
if curl -s http://localhost:9091 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Running on port 9091${NC}"
else
    echo -e "${RED}❌ Not accessible${NC}"
fi

# Check Jaeger
echo -n "  Jaeger: "
if curl -s http://localhost:16687 >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Running on port 16687${NC}"
else
    echo -e "${RED}❌ Not accessible${NC}"
fi

# Display connection information
echo ""
echo -e "${GREEN}🎉 Setup Complete!${NC}"
echo "=================================="
echo ""
echo -e "${YELLOW}📊 Access Your Services:${NC}"
echo "  🗄️  PostgreSQL: localhost:5433"
echo "  📈 Grafana:     http://localhost:3005"
echo "  📊 Prometheus:  http://localhost:9091"
echo "  🔍 Jaeger:      http://localhost:16687"
echo ""
echo -e "${YELLOW}🔐 Login Credentials:${NC}"
echo "  PostgreSQL:"
echo "    User: postgres"
echo "    Password: ${DB_PASSWORD}"
echo ""
echo "  Grafana:"
echo "    User: admin"
echo "    Password: ${GRAFANA_PASSWORD}"
echo ""
echo -e "${YELLOW}🔗 Connection Strings:${NC}"
echo "  Database URL: postgresql://postgres:${DB_PASSWORD}@localhost:5433/postgres"
echo ""
echo -e "${BLUE}💡 Quick Commands:${NC}"
echo "  # Connect to database"
echo "  psql \"postgresql://postgres:${DB_PASSWORD}@localhost:5433/postgres\""
echo ""
echo "  # View running services"
echo "  docker-compose -f docker-compose.prod.yml ps"
echo ""
echo "  # View logs"
echo "  docker-compose -f docker-compose.prod.yml logs -f"
echo ""
echo "  # Stop services"
echo "  docker-compose -f docker-compose.prod.yml down"
echo ""
echo -e "${GREEN}✨ Your PostgreSQL AI/ML platform with observability is ready!${NC}"