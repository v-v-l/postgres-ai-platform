# 🐘 Shared PostgreSQL Docker Instance

A secure, reusable PostgreSQL Docker setup with **pgvector extension** for AI/ML applications. Perfect for microservices, full-stack applications, vector databases, embeddings storage, and similarity search.

## 🔒 SECURITY FIRST!

**BEFORE STARTING:** You MUST secure this setup:

1. **Generate a strong password:**
   ```bash
   # Generate a secure password
   openssl rand -base64 32
   ```

2. **Update `.env` file:**
   - Replace `CHANGE_ME_TO_STRONG_PASSWORD` with your generated password
   - Keep `POSTGRES_HOST=127.0.0.1` to bind to localhost only

3. **Never commit `.env` to git** - it's already in `.gitignore`

## 🚀 Quick Start

### Option 1: Clone this repository
```bash
git clone https://github.com/v-v-l/postgres.git postgres-shared
cd postgres-shared
```

### Option 2: Use in existing project directory
```bash
# Download files to your desired location
wget <raw-files-urls>
# or copy files from another project
```

### Setup and Run

#### **Development Mode** (Quick & Easy)
```bash
# 1. FIRST: Set up your environment
cp .env.example .env

# 2. Generate a secure password
openssl rand -base64 32

# 3. Edit .env file with the generated password
# Replace CHANGE_ME_TO_STRONG_PASSWORD with your secure password

# 4. Start PostgreSQL (Development)
docker-compose -f docker-compose.dev.yml up -d

# 5. Verify it's running
docker-compose -f docker-compose.dev.yml ps
```

#### **Production Mode** (Enhanced Security)
```bash
# 1-3. Same setup as development

# 4. Start PostgreSQL (Production with SSL, logging, limits)
docker-compose -f docker-compose.prod.yml up -d

# 5. Verify it's running
docker-compose -f docker-compose.prod.yml ps

# 6. Test SSL connection
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres?sslmode=require" -c "SELECT version();"
```

#### **Legacy Mode** (Default docker-compose.yml)
```bash
# Uses the standard docker-compose.yml for backward compatibility
docker-compose up -d
```

### Stop and Cleanup
```bash
# Development mode
docker-compose -f docker-compose.dev.yml down

# Production mode  
docker-compose -f docker-compose.prod.yml down

# Legacy mode
docker-compose down

# Remove all data (DESTRUCTIVE!)
docker-compose -f docker-compose.dev.yml down -v  # or .prod.yml
```

## 🧮 Vector Extensions & Features

This setup includes **pgvector** and additional useful extensions:

- **pgvector**: Store and query vector embeddings (AI/ML)
- **uuid-ossp**: Generate UUIDs
- **pg_trgm**: Trigram text search and similarity
- **btree_gin/btree_gist**: Advanced indexing

### Vector Usage Examples

**Store OpenAI embeddings:**
```sql
-- Create table for embeddings
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536)  -- OpenAI ada-002 dimensions
);

-- Insert embedding
INSERT INTO documents (content, embedding) 
VALUES ('Hello world', '[0.1, 0.2, 0.3, ...]');

-- Find similar documents (cosine similarity)
SELECT content, 1 - (embedding <=> '[0.1, 0.2, 0.3, ...]') as similarity
FROM documents
ORDER BY embedding <=> '[0.1, 0.2, 0.3, ...]'
LIMIT 5;
```

**Create optimized vector index:**
```sql
-- HNSW index for fast similarity search
CREATE INDEX ON documents USING hnsw (embedding vector_cosine_ops);
```

## Configuration

Edit `.env` file to customize:
- `POSTGRES_DB`: Default database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password  
- `POSTGRES_PORT`: Host port (default: 5432)

## Connection Details

- **Host**: localhost
- **Port**: 5432 (or your custom port)
- **Database**: postgres (or your custom database)
- **Connection URL**: `postgresql://postgres:postgres123@localhost:5432/postgres`

## 🏗️ Multi-Project Database Architecture

### **Best Practice: Isolated Databases per Project**

#### **Why Separate Databases?**
✅ **Security isolation** - projects can't access each other's data  
✅ **Schema independence** - no table name conflicts  
✅ **Performance isolation** - heavy queries don't affect other projects  
✅ **Backup granularity** - backup/restore individual projects  
✅ **Migration safety** - test schema changes without risk  
✅ **Team permissions** - grant access per project  

#### **Recommended Architecture:**
```
One PostgreSQL Instance:
├── casa_connect_db    (Real estate project)
├── portfolio_db       (Personal portfolio)
├── analytics_db       (Data analytics)
├── vector_search_db   (AI/ML with pgvector)
└── shared_utils_db    (Common utilities)
```

### **Adding Project-Specific Databases**

1. **Edit the initialization script:**
   ```bash
   nano init/01-create-databases.sql
   ```

2. **Add your databases and users:**
   ```sql
   -- Casa Connect Project
   CREATE DATABASE casa_connect_db;
   CREATE USER casa_connect_user WITH PASSWORD 'casa_secure_2024!';
   GRANT ALL PRIVILEGES ON DATABASE casa_connect_db TO casa_connect_user;
   
   -- Portfolio Project
   CREATE DATABASE portfolio_db;
   CREATE USER portfolio_user WITH PASSWORD 'portfolio_secure_2024!';
   GRANT ALL PRIVILEGES ON DATABASE portfolio_db TO portfolio_user;
   
   -- Analytics Project (with pgvector)
   CREATE DATABASE analytics_db;
   CREATE USER analytics_user WITH PASSWORD 'analytics_secure_2024!';
   GRANT ALL PRIVILEGES ON DATABASE analytics_db TO analytics_user;
   ```

3. **Enable pgvector in specific databases:**
   ```sql
   -- Connect to each database and enable pgvector
   \c casa_connect_db;
   CREATE EXTENSION IF NOT EXISTS vector;
   
   \c analytics_db;
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

4. **Apply changes:**
   ```bash
   # Development
   docker-compose -f docker-compose.dev.yml down -v  # Removes existing data!
   docker-compose -f docker-compose.dev.yml up -d    # Recreates with new databases
   
   # Production
   docker-compose -f docker-compose.prod.yml down -v
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Connecting from Different Projects

**Node.js/JavaScript Examples:**
```javascript
import { Pool } from 'pg';

// Casa Connect Database
const casaPool = new Pool({
  connectionString: 'postgresql://casa_connect_user:casa_secure_2024!@localhost:5432/casa_connect_db'
});

// Portfolio Database  
const portfolioPool = new Pool({
  connectionString: 'postgresql://portfolio_user:portfolio_secure_2024!@localhost:5432/portfolio_db'
});

// Analytics Database (with vectors)
const analyticsPool = new Pool({
  connectionString: 'postgresql://analytics_user:analytics_secure_2024!@localhost:5432/analytics_db'
});

// Vector operations in analytics
await analyticsPool.query(`
  SELECT content, 1 - (embedding <=> $1) as similarity
  FROM embeddings
  ORDER BY embedding <=> $1
  LIMIT 5
`, ['[0.1, 0.2, 0.3, ...]']);
```

**Python with pgvector:**
```python
import psycopg2
import numpy as np
from pgvector.psycopg2 import register_vector

conn = psycopg2.connect("postgresql://casa_connect_user:secure_password_here@localhost:5432/casa_connect")
register_vector(conn)

# Insert vector
embedding = np.array([0.1, 0.2, 0.3])
cur.execute("INSERT INTO embeddings (content, embedding) VALUES (%s, %s)", 
           ("Hello world", embedding))

# Similarity search
cur.execute("SELECT content FROM embeddings ORDER BY embedding <=> %s LIMIT 5", (embedding,))
```

**Go with pgvector:**
```go
import (
    "github.com/pgvector/pgvector-go"
    "github.com/jackc/pgx/v5"
)

conn, _ := pgx.Connect(ctx, "postgres://casa_connect_user:secure_password_here@localhost:5432/casa_connect")

// Insert vector
embedding := pgvector.NewVector([]float32{0.1, 0.2, 0.3})
conn.Exec(ctx, "INSERT INTO embeddings (content, embedding) VALUES ($1, $2)", "Hello world", embedding)
```

**Docker Compose Integration:**
```yaml
# In your project's docker-compose.yml
services:
  app:
    # ... your app config
    environment:
      DATABASE_URL: postgresql://casa_connect_user:secure_password_here@host.docker.internal:5432/casa_connect
    depends_on:
      - postgres
    external_links:
      - postgres-shared:postgres
```

## Data Persistence

Database data is persisted in the `postgres_data` Docker volume. To reset:

```bash
docker-compose down -v  # Removes volumes
docker-compose up -d
```

## Network Access

The PostgreSQL instance is available on the `postgres-network` Docker network for container-to-container communication.

## 🔒 Security Features

### **Built-in Security**
- **Strong authentication**: Uses SCRAM-SHA-256 instead of MD5
- **Localhost binding**: Only accessible from localhost by default  
- **No trust authentication**: Passwords required for all connections
- **Environment isolation**: Credentials in `.env` (gitignored)
- **Data persistence**: Uses Docker volumes, not host mounts

### **Enhanced Security (Optional)**
The setup includes optional enhanced security configurations:

- **SSL/TLS encryption**: Self-signed certificates for encrypted connections
- **Connection logging**: Track all database connections and disconnections
- **Query logging**: Log all data modifications (INSERT, UPDATE, DELETE)
- **Failed login monitoring**: Log failed authentication attempts
- **Connection limits**: Prevent connection exhaustion attacks
- **Slow query detection**: Log queries taking longer than 1 second

### **Enable Enhanced Security**
```bash
# The enhanced security configs are pre-configured but commented
# To enable, restart with the security configs:
docker-compose down
docker-compose up -d

# Test SSL connection
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres?sslmode=require" -c "SELECT version();"

# View security logs
docker-compose exec postgres tail -f /var/lib/postgresql/data/pgdata/log/postgresql-*.log
```

### **Security Monitoring**
```bash
# Check active connections
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres" -c "SELECT usename, application_name, client_addr, state FROM pg_stat_activity WHERE state = 'active';"

# Check failed login attempts (from logs)
docker-compose exec postgres grep "FATAL" /var/lib/postgresql/data/pgdata/log/postgresql-*.log
```

## Security Checklist

- [ ] Generated strong password with `openssl rand -base64 32`
- [ ] Updated `.env` file with secure credentials
- [ ] Verified `POSTGRES_HOST=127.0.0.1` for localhost-only access
- [ ] Never committed `.env` to version control
- [ ] Consider using Docker secrets for production
- [ ] Regularly update Docker image: `docker-compose pull`

## 🖥️ GUI Database Clients

For a better visual experience, connect using local database clients:

### **Recommended GUI Tools**

**TablePlus (macOS Native)**
```bash
brew install --cask tableplus
```
- Modern, fast interface
- Great for browsing tables and data
- Native macOS experience

**pgAdmin (Cross-platform)**
```bash
brew install --cask pgadmin4
```
- Full-featured PostgreSQL administration
- Web-based interface (runs locally)
- Advanced query tools

**Postico (macOS Only)**
```bash
brew install --cask postico
```
- Clean, simple interface
- Perfect for data browsing
- macOS design principles

**DBeaver (Free, Cross-platform)**
```bash
brew install --cask dbeaver-community
```
- Supports many databases
- Advanced features
- Good for complex queries

### **Connection Settings for Any GUI Tool**

- **Host**: `localhost`
- **Port**: `5432`
- **Database**: `postgres`
- **Username**: `postgres`
- **Password**: `CHANGE_ME_TO_STRONG_PASSWORD`
- **SSL Mode**: `prefer` (or disable for local development)

### **Quick Test Connection**
```bash
# Test connection from command line
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres" -c "SELECT version();"

# Test pgvector extension
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres" -c "SELECT extname FROM pg_extension WHERE extname = 'vector';"
```

## 🔧 Troubleshooting

### Common Issues

**Port Already in Use:**
```bash
# Check what's using port 5432
sudo lsof -i :5432
# Or change port in .env file
POSTGRES_PORT=5433
```

**Permission Denied:**
```bash
# Make sure Docker daemon is running
sudo systemctl start docker
# Or add your user to docker group
sudo usermod -aG docker $USER
```

**Container Won't Start:**
```bash
# Check logs for errors
docker-compose logs postgres
# Remove corrupted volumes
docker-compose down -v
```

**Can't Connect from Application:**
```bash
# Verify container is running
docker-compose ps
# Test connection
docker-compose exec postgres psql -U postgres -d postgres -c "SELECT version();"
```

### Useful Commands

```bash
# Connect to PostgreSQL CLI
docker-compose exec postgres psql -U postgres -d postgres

# Backup database
docker-compose exec postgres pg_dump -U postgres database_name > backup.sql

# Restore database
docker-compose exec -T postgres psql -U postgres database_name < backup.sql

# View container resources
docker stats postgres-shared

# Update PostgreSQL image
docker-compose pull postgres
docker-compose up -d --force-recreate
```

## 📋 File Structure

```
postgres-shared/
├── docker-compose.yml           # Legacy configuration (backward compatibility)
├── docker-compose.dev.yml       # Development: Fast, simple setup
├── docker-compose.prod.yml      # Production: Security, SSL, logging, limits
├── .env.example                 # Environment template
├── .env                         # Your environment (gitignored)
├── .gitignore                   # Git ignore rules
├── init/                        # Database initialization scripts
│   ├── 00-enable-extensions.sql # Enable pgvector and other extensions
│   └── 01-create-databases.sql  # Create project databases
├── postgres-config/             # Security configurations (production)
│   ├── postgresql.conf          # Enhanced PostgreSQL settings
│   ├── pg_hba.conf             # Authentication rules
│   ├── server.crt              # SSL certificate
│   ├── server.key              # SSL private key
│   └── generate-ssl.sh         # SSL certificate generator
└── README.md                    # This file
```

## 🔄 Configuration Comparison

| Feature | Development | Production | Legacy |
|---------|-------------|------------|--------|
| **SSL/TLS** | ❌ Disabled | ✅ Required | ❌ Disabled |
| **Logging** | ❌ Minimal | ✅ Full logging | ❌ Minimal |
| **Resource Limits** | ❌ Unlimited | ✅ CPU/Memory limits | ❌ Unlimited |
| **Container Name** | postgres-dev | postgres-prod | postgres-shared |
| **Data Volume** | postgres_dev_data | postgres_prod_data | postgres_data |
| **Setup Speed** | ⚡ Fast | 🐌 Slower (security) | ⚡ Fast |
| **Use Case** | Local development | Production/Staging | Backward compatibility |

## 🚀 Production Recommendations

- Use Docker secrets instead of environment variables
- Enable SSL/TLS connections
- Set up connection limits and timeouts
- Use a non-default port
- Implement connection pooling (PgBouncer)
- Regular security audits and updates
- Monitor with tools like pgAdmin or Grafana
- Set up automated backups

## 📝 License

This project is provided as-is for development purposes. Use at your own risk.

## 🤝 Contributing

Feel free to submit issues and enhancement requests!