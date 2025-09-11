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

# Add PostgreSQL port bindings for each IP
for ip in "${ALLOWED_IPS[@]}"; do
    echo "      - \"${ip}:\${POSTGRES_PORT:-5433}:5432\"" >> docker-compose.override.yml
done

cat >> docker-compose.override.yml << 'EOF'

  grafana:
    ports:
EOF

# Add Grafana port bindings for each IP
for ip in "${ALLOWED_IPS[@]}"; do
    echo "      - \"${ip}:\${GRAFANA_PORT:-3005}:3000\"" >> docker-compose.override.yml
done

cat >> docker-compose.override.yml << 'EOF'

  prometheus:
    ports:
EOF

# Add Prometheus port bindings for each IP
for ip in "${ALLOWED_IPS[@]}"; do
    echo "      - \"${ip}:\${PROMETHEUS_PORT:-9091}:9090\"" >> docker-compose.override.yml
done

cat >> docker-compose.override.yml << 'EOF'

  jaeger:
    ports:
      - "${JAEGER_COLLECTOR_PORT:-14251}:14250"
EOF

# Add Jaeger UI port bindings for each IP
for ip in "${ALLOWED_IPS[@]}"; do
    echo "      - \"${ip}:\${JAEGER_UI_PORT:-16687}:16686\"" >> docker-compose.override.yml
done

echo -e "${GREEN}✅ Network configuration complete!${NC}"
echo ""
echo -e "${YELLOW}🔗 Access URLs:${NC}"

for ip in "${ALLOWED_IPS[@]}"; do
    if [ "$ip" = "127.0.0.1" ] || [ "$ip" = "localhost" ]; then
        HOST="localhost"
    else
        HOST="$ip"
    fi
    
    echo "  From $ip:"
    echo "    🗄️  PostgreSQL: $HOST:5433"
    echo "    📈 Grafana:     http://$HOST:3005"
    echo "    📊 Prometheus:  http://$HOST:9091"
    echo "    🔍 Jaeger:      http://$HOST:16687"
    echo ""
done

echo -e "${BLUE}💡 To apply changes:${NC}"
echo "  docker-compose -f docker-compose.prod.yml -f docker-compose.override.yml down"
echo "  docker-compose -f docker-compose.prod.yml -f docker-compose.override.yml up -d"