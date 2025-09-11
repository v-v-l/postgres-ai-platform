#!/bin/bash

# Network Configuration Script for PostgreSQL AI/ML Platform
# Automatically configures Docker port bindings based on allowed-ips.txt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Configuring Network Access${NC}"

# Check if allowed-ips.txt exists
if [ ! -f "allowed-ips.txt" ]; then
    echo -e "${RED}❌ allowed-ips.txt not found${NC}"
    echo "Creating default configuration..."
    cat > allowed-ips.txt << 'EOF'
# Allowed IP addresses for PostgreSQL access
# Add one IP address per line
127.0.0.1
EOF
fi

# Read allowed IPs (ignore comments and empty lines)
ALLOWED_IPS=($(grep -v '^#' allowed-ips.txt | grep -v '^$' | tr -d '\r'))

if [ ${#ALLOWED_IPS[@]} -eq 0 ]; then
    echo -e "${YELLOW}⚠️  No IPs found in allowed-ips.txt, using localhost only${NC}"
    ALLOWED_IPS=("127.0.0.1")
fi

echo -e "${BLUE}📋 Configured IP addresses:${NC}"
for ip in "${ALLOWED_IPS[@]}"; do
    echo "  - $ip"
done

# Generate docker-compose override file
echo -e "${BLUE}🐳 Generating docker-compose override...${NC}"

cat > docker-compose.override.yml << 'EOF'
version: '3.8'

services:
  postgres:
    ports:
EOF

# Add PostgreSQL port bindings
# For remote access, we bind to 0.0.0.0 and rely on firewall/network security
if [ ${#ALLOWED_IPS[@]} -eq 1 ] && [ "${ALLOWED_IPS[0]}" = "127.0.0.1" ]; then
    # Only localhost - bind to localhost only
    echo "      - \"127.0.0.1:\${POSTGRES_PORT:-5433}:5432\"" >> docker-compose.override.yml
else
    # Multiple IPs or remote access - bind to all interfaces
    echo "      - \"0.0.0.0:\${POSTGRES_PORT:-5433}:5432\"" >> docker-compose.override.yml
fi

cat >> docker-compose.override.yml << 'EOF'

  grafana:
    ports:
EOF

# Add Grafana port bindings
if [ ${#ALLOWED_IPS[@]} -eq 1 ] && [ "${ALLOWED_IPS[0]}" = "127.0.0.1" ]; then
    # Only localhost - bind to localhost only
    echo "      - \"127.0.0.1:\${GRAFANA_PORT:-3005}:3000\"" >> docker-compose.override.yml
else
    # Multiple IPs or remote access - bind to all interfaces
    echo "      - \"0.0.0.0:\${GRAFANA_PORT:-3005}:3000\"" >> docker-compose.override.yml
fi

cat >> docker-compose.override.yml << 'EOF'

  prometheus:
    ports:
EOF

# Add Prometheus port bindings
if [ ${#ALLOWED_IPS[@]} -eq 1 ] && [ "${ALLOWED_IPS[0]}" = "127.0.0.1" ]; then
    # Only localhost - bind to localhost only
    echo "      - \"127.0.0.1:\${PROMETHEUS_PORT:-9091}:9090\"" >> docker-compose.override.yml
else
    # Multiple IPs or remote access - bind to all interfaces
    echo "      - \"0.0.0.0:\${PROMETHEUS_PORT:-9091}:9090\"" >> docker-compose.override.yml
fi

cat >> docker-compose.override.yml << 'EOF'

  jaeger:
    ports:
      - "${JAEGER_COLLECTOR_PORT:-14251}:14250"
EOF

# Add Jaeger UI port bindings
if [ ${#ALLOWED_IPS[@]} -eq 1 ] && [ "${ALLOWED_IPS[0]}" = "127.0.0.1" ]; then
    # Only localhost - bind to localhost only
    echo "      - \"127.0.0.1:\${JAEGER_UI_PORT:-16687}:16686\"" >> docker-compose.override.yml
else
    # Multiple IPs or remote access - bind to all interfaces
    echo "      - \"0.0.0.0:\${JAEGER_UI_PORT:-16687}:16686\"" >> docker-compose.override.yml
fi

echo -e "${GREEN}✅ Network configuration complete!${NC}"
echo ""
echo -e "${YELLOW}🔗 Access URLs:${NC}"

# Get this machine's IP for display
THIS_MACHINE_IP=$(ifconfig | grep -E "inet [0-9]" | grep -v 127.0.0.1 | head -1 | awk '{print $2}')

if [ ${#ALLOWED_IPS[@]} -eq 1 ] && [ "${ALLOWED_IPS[0]}" = "127.0.0.1" ]; then
    echo "  Localhost only:"
    echo "    🗄️  PostgreSQL: localhost:5433"
    echo "    📈 Grafana:     http://localhost:3005"
    echo "    📊 Prometheus:  http://localhost:9091"
    echo "    🔍 Jaeger:      http://localhost:16687"
else
    echo "  Local access:"
    echo "    🗄️  PostgreSQL: localhost:5433"
    echo "    📈 Grafana:     http://localhost:3005"
    echo "    📊 Prometheus:  http://localhost:9091"
    echo "    🔍 Jaeger:      http://localhost:16687"
    echo ""
    echo "  Remote access (from allowed IPs):"
    echo "    🗄️  PostgreSQL: ${THIS_MACHINE_IP}:5433"
    echo "    📈 Grafana:     http://${THIS_MACHINE_IP}:3005"
    echo "    📊 Prometheus:  http://${THIS_MACHINE_IP}:9091"
    echo "    🔍 Jaeger:      http://${THIS_MACHINE_IP}:16687"
    echo ""
    echo "  Allowed client IPs:"
    for ip in "${ALLOWED_IPS[@]}"; do
        echo "    - $ip"
    done
fi
echo ""

# Detect Docker Compose command
if command -v docker-compose >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
elif docker compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker compose"  # Default to v2 syntax
fi

echo -e "${BLUE}💡 To apply changes:${NC}"
echo "  $COMPOSE_CMD -f docker-compose.prod.yml -f docker-compose.override.yml down"
echo "  $COMPOSE_CMD -f docker-compose.prod.yml -f docker-compose.override.yml up -d"