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
git clone <your-repo-url> postgres-shared
cd postgres-shared
```

### Option 2: Use in existing project directory
```bash
# Download files to your desired location
wget <raw-files-urls>
# or copy files from another project
```

### Setup and Run
```bash
# 1. FIRST: Set up your environment
cp .env.example .env

# 2. Generate a secure password
openssl rand -base64 32

# 3. Edit .env file with the generated password
# Replace CHANGE_ME_TO_STRONG_PASSWORD with your secure password

# 4. Start PostgreSQL
docker-compose up -d

# 5. Verify it's running
docker-compose ps

# 6. View logs (optional)
docker-compose logs -f postgres
```

### Stop and Cleanup
```bash
# Stop PostgreSQL (data persists)
docker-compose down

# Stop and remove all data (DESTRUCTIVE!)
docker-compose down -v
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

## 🏗️ Multi-Project Usage

### Adding Project-Specific Databases

1. **Edit the initialization script:**
   ```bash
   nano init/01-create-databases.sql
   ```

2. **Add your databases and users:**
   ```sql
   -- Example for casa-connect project
   CREATE DATABASE casa_connect;
   CREATE USER casa_connect_user WITH PASSWORD 'secure_password_here';
   GRANT ALL PRIVILEGES ON DATABASE casa_connect TO casa_connect_user;
   
   -- Example for another project
   CREATE DATABASE my_app;
   CREATE USER my_app_user WITH PASSWORD 'another_secure_password';
   GRANT ALL PRIVILEGES ON DATABASE my_app TO my_app_user;
   ```

3. **Apply changes:**
   ```bash
   docker-compose down -v  # Removes existing data!
   docker-compose up -d    # Recreates with new databases
   ```

### Connecting from Different Projects

**Node.js/JavaScript with vectors:**
```javascript
import { Pool } from 'pg';

const pool = new Pool({
  connectionString: 'postgresql://casa_connect_user:secure_password_here@localhost:5432/casa_connect'
});

// Insert vector
await pool.query(
  'INSERT INTO embeddings (content, embedding) VALUES ($1, $2)',
  ['Hello world', '[0.1, 0.2, 0.3, ...]']
);

// Similarity search
const result = await pool.query(`
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

- **Strong authentication**: Uses SCRAM-SHA-256 instead of MD5
- **Localhost binding**: Only accessible from localhost by default  
- **No trust authentication**: Passwords required for all connections
- **Environment isolation**: Credentials in `.env` (gitignored)
- **Data persistence**: Uses Docker volumes, not host mounts

## Security Checklist

- [ ] Generated strong password with `openssl rand -base64 32`
- [ ] Updated `.env` file with secure credentials
- [ ] Verified `POSTGRES_HOST=127.0.0.1` for localhost-only access
- [ ] Never committed `.env` to version control
- [ ] Consider using Docker secrets for production
- [ ] Regularly update Docker image: `docker-compose pull`

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
├── docker-compose.yml      # Main Docker Compose configuration
├── .env.example           # Environment template
├── .env                   # Your environment (gitignored)
├── .gitignore            # Git ignore rules
├── init/                 # Database initialization scripts
│   ├── 00-enable-extensions.sql    # Enable pgvector and other extensions
│   └── 01-create-databases.sql     # Create project databases
└── README.md             # This file
```

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