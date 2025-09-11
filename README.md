# 🐘 PostgreSQL AI/ML Docker Setup

A comprehensive, production-ready PostgreSQL Docker setup with **advanced AI/ML capabilities** that rivals dedicated vector databases. Transform PostgreSQL into a powerful AI/ML platform with vector search, hybrid search, multi-modal embeddings, and enterprise-grade security.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15.14-blue.svg)](https://www.postgresql.org/)
[![pgvector](https://img.shields.io/badge/pgvector-0.8.0-green.svg)](https://github.com/pgvector/pgvector)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)

**Perfect for**: AI/ML applications, vector databases, semantic search, recommendation systems, knowledge management, multi-modal AI, and enterprise applications requiring both relational data and AI capabilities.

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

#### **Option 1: Automated Setup (Recommended)**
```bash
# One-command setup with secure password generation
./setup.sh
```

#### **Option 2: Manual Setup**
```bash
# 1. Set up your environment
cp .env.example .env

# 2. Generate secure passwords
openssl rand -base64 32  # For POSTGRES_PASSWORD
openssl rand -base64 32  # For GRAFANA_ADMIN_PASSWORD

# 3. Edit .env file with the generated passwords

# 4. Start PostgreSQL + Observability Stack
docker-compose -f docker-compose.prod.yml up -d

# 5. Verify all services are running
docker-compose -f docker-compose.prod.yml ps

# 6. Test connection
psql "postgresql://postgres:YOUR_PASSWORD@localhost:5433/postgres" -c "SELECT version();"

# 7. Access observability tools
echo "Grafana: http://localhost:3005"
echo "Prometheus: http://localhost:9091"  
echo "Jaeger: http://localhost:16687"
```

### Stop and Cleanup
```bash
# Stop all services
docker-compose -f docker-compose.prod.yml down

# Remove all data (DESTRUCTIVE!)
docker-compose -f docker-compose.prod.yml down -v
```

## 🤖 Advanced AI/ML Capabilities

This setup transforms PostgreSQL into a **comprehensive AI/ML platform** that rivals dedicated vector databases like ChromaDB.

### **High-Level Overview: Why These AI/ML Features Matter**

**Traditional Problem**: Most AI applications need multiple databases:
- Vector database (ChromaDB, Pinecone) for embeddings
- SQL database (PostgreSQL) for business data  
- Search engine (Elasticsearch) for text search
- Graph database for relationships

**Our Solution**: One PostgreSQL instance that handles everything:

#### **🎯 Vector Search & Embeddings**
Store and search AI embeddings (OpenAI, Hugging Face, custom models) with sub-millisecond performance using HNSW indexing. Perfect for:
- **Semantic search** - Find similar documents by meaning, not keywords
- **Recommendation systems** - "Users who liked X also liked Y"  
- **Image/audio search** - Find similar media using neural network embeddings
- **Question answering** - Match user questions to knowledge base

#### **🔗 Hybrid Search**
Combine multiple search methods for better results:
- **Vector similarity** - Semantic understanding ("car" matches "automobile")
- **Full-text search** - Exact keyword matching with ranking
- **Metadata filtering** - Filter by tags, dates, categories
- **Example**: Search "red sports car" and get results ranked by semantic similarity + exact text matches + metadata (color=red, type=sports)

#### **🌳 Hierarchical AI Data**
Organize AI concepts in tree structures:
- **AI taxonomies** - AI → Machine Learning → Deep Learning → Computer Vision
- **Product categories** - Electronics → Computers → Laptops → Gaming
- **Knowledge graphs** - Relationships between concepts
- **Example**: Find all subcategories under "Machine Learning" or similar concepts at the same hierarchy level

#### **🔄 Multi-modal AI**
Handle different types of AI data in one system:
- **Text embeddings** - Document similarity, sentiment analysis
- **Image embeddings** - Visual similarity, object recognition  
- **Audio embeddings** - Music recommendation, speech similarity
- **Combined search** - Find images similar to text descriptions

#### **📊 Time-series AI**
Track AI metrics and patterns over time:
- **Model performance** - Accuracy, loss, inference time
- **Embedding drift** - How data patterns change over time
- **A/B testing** - Compare different AI model versions
- **Usage analytics** - User interaction patterns with AI features

#### **🔍 Fuzzy Matching**
Handle imperfect real-world data:
- **Typo tolerance** - "machien learning" matches "machine learning"
- **Similar names** - "John Smith" matches "Jon Smyth"  
- **Product matching** - "iPhone 14" matches "Apple iPhone 14 Pro"
- **Data cleaning** - Find and merge duplicate records

### **Core Vector & AI Extensions**
- **pgvector**: Store and query vector embeddings with HNSW indexing
- **pg_trgm**: Trigram matching for fuzzy text search
- **fuzzystrmatch**: Advanced string similarity (Levenshtein, etc.)
- **unaccent**: Accent-insensitive text processing
- **ltree**: Hierarchical data for AI taxonomies
- **hstore**: Key-value metadata storage
- **cube**: Multi-dimensional data types
- **earthdistance**: Geographic AI applications

### **Real-World Use Cases**

#### **🛒 E-commerce AI**
```sql
-- Find products similar to user's browsing history
-- Combine visual similarity + text description + price range + user preferences
SELECT * FROM hybrid_search('red winter jacket', user_embedding, 0.3, 0.7, 10)
WHERE metadata->>'price' < '200' AND metadata->>'brand' = ANY(user_preferred_brands);
```

#### **📚 Knowledge Management**
```sql
-- Intelligent document search across company knowledge base
-- Find documents by meaning, not just keywords
SELECT title, similarity_score FROM cross_modal_search(
    question_embedding, 'text', 0.8, 5
) WHERE metadata->>'department' = 'engineering';
```

#### **🎵 Content Recommendation**
```sql
-- Music recommendation based on listening history + mood + time of day
SELECT track_name FROM ai_embeddings 
WHERE content_type = 'audio'
  AND metadata->>'mood' = 'energetic'
  AND audio_embedding <=> user_taste_embedding < 0.7;
```

#### **🏥 Medical AI**
```sql
-- Find similar patient cases based on symptoms + medical history
-- Hierarchical disease classification with fuzzy symptom matching
SELECT patient_id, similarity(symptoms, 'chest pain shortness breath') as symptom_match
FROM medical_cases 
WHERE disease_path <@ 'Medical.Cardiology'
  AND embedding <=> current_case_embedding < 0.8;
```

### **AI/ML Advantages over Dedicated Vector Databases**
✅ **All-in-one solution** - No need for multiple databases  
✅ **ACID transactions** - Reliable AI data operations  
✅ **Complex joins** - Combine AI results with business data  
✅ **Multi-modal support** - Text, image, audio in one system  
✅ **Hybrid search** - Vector + full-text + metadata filtering  
✅ **Time-series AI** - Track model performance over time  
✅ **Hierarchical data** - AI taxonomies and relationships  
✅ **Enterprise features** - Security, backup, monitoring, scaling  
✅ **Cost effective** - One database license vs multiple services  
✅ **Familiar tools** - Use existing PostgreSQL knowledge and tools  

### **Pre-built AI/ML Tables & Functions**
The setup includes production-ready examples:
- **Multi-modal embeddings table** - text, image, multimodal vectors
- **Smart documents** - hybrid text + vector search  
- **AI taxonomy** - hierarchical classification trees
- **AI metrics** - time-series ML data
- **Hybrid search function** - combines text and semantic similarity
- **Cross-modal search** - find similar items across modalities

### **AI/ML Usage Examples**

**1. Multi-modal AI Search:**
```sql
-- Search across text, image, and multimodal embeddings
SELECT * FROM cross_modal_search(
    '[0.1, 0.2, 0.3, ...]'::vector,
    'text',
    0.8,  -- similarity threshold
    5     -- limit results
);
```

**2. Hybrid Text + Vector Search:**
```sql
-- Combine full-text search with semantic similarity
SELECT * FROM hybrid_search(
    'machine learning basics',        -- text query
    '[0.1, 0.2, 0.3, ...]'::vector,  -- embedding query
    0.3,  -- text weight
    0.7,  -- vector weight  
    10    -- limit
);
```

**3. Hierarchical AI Taxonomy:**
```sql
-- Find all AI subcategories under Machine Learning
SELECT name, path, embedding 
FROM ai_taxonomy 
WHERE path <@ 'AI.ML';

-- Find similar concepts in taxonomy
SELECT name, 1 - (embedding <=> '[0.1, 0.2, 0.3]'::vector) as similarity
FROM ai_taxonomy
ORDER BY embedding <=> '[0.1, 0.2, 0.3]'::vector
LIMIT 5;
```

**4. Advanced Vector Operations:**
```sql
-- Store multi-dimensional embeddings with metadata
INSERT INTO ai_embeddings (content_type, original_content, text_embedding, metadata) 
VALUES (
    'multimodal',
    'A photo of a cat with description',
    '[0.1, 0.2, 0.3, ...]'::vector,
    '{"tags": ["animal", "pet"], "confidence": 0.95}'::jsonb
);

-- Complex metadata + vector filtering
SELECT * FROM ai_embeddings 
WHERE metadata->>'tags' ? 'animal'
  AND text_embedding <=> '[0.1, 0.2, 0.3]'::vector < 0.8
ORDER BY text_embedding <=> '[0.1, 0.2, 0.3]'::vector;
```

**5. Fuzzy Text Matching for AI:**
```sql
-- Find similar text using multiple algorithms
SELECT 
    content,
    levenshtein(content, 'machine lerning') as edit_distance,
    similarity(content, 'machine lerning') as trigram_similarity
FROM smart_documents
WHERE similarity(content, 'machine lerning') > 0.3
ORDER BY trigram_similarity DESC;
```

## 📊 Observability Stack

This setup includes production-ready observability with **Grafana + Prometheus + Jaeger** for comprehensive monitoring and tracing.

### **What You Get**
- **PostgreSQL Metrics**: Connection counts, query rates, cache hit ratios
- **AI/ML Monitoring**: Vector operation performance, embedding query latency  
- **Application Tracing**: End-to-end request tracing with Jaeger
- **Custom Dashboards**: Pre-built PostgreSQL AI/ML dashboard

### **Access URLs** (Production Mode)
- **Grafana**: http://localhost:3005 (admin/admin - change in .env)
- **Prometheus**: http://localhost:9091  
- **Jaeger**: http://localhost:16687

### **Key Metrics Tracked**
- Database connections and transaction rates
- Vector similarity search performance
- pgvector extension usage patterns
- Query execution times and slow queries
- Resource utilization (CPU, memory, I/O)

## Configuration

Edit `.env` file to customize:
- `POSTGRES_DB`: Default database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password  
- `POSTGRES_PORT`: Host port (default: 5433 - non-default for security)
- `GRAFANA_PORT`: Grafana UI port (default: 3005)
- `GRAFANA_ADMIN_PASSWORD`: Grafana admin password
- `JAEGER_UI_PORT`: Jaeger UI port (default: 16687)
- `PROMETHEUS_PORT`: Prometheus port (default: 9091)

### Data Persistence Configuration

- `DATA_PATH`: Base path for all data storage (default: `~/postgres-ai-data`)
- `POSTGRES_DATA_PATH`: PostgreSQL data directory (default: `${DATA_PATH}/postgres`)
- `PROMETHEUS_DATA_PATH`: Prometheus metrics storage (default: `${DATA_PATH}/prometheus`) 
- `GRAFANA_DATA_PATH`: Grafana dashboards and config (default: `${DATA_PATH}/grafana`)

## Connection Details

- **Host**: localhost (or configured IPs)
- **Port**: 5433 (non-default for security)
- **Database**: postgres (or your custom database)
- **Connection URL**: `postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5433/postgres`

## 🌐 Network Access Configuration

### Allowing Access from Other Machines

By default, services are only accessible from localhost. To allow access from specific machines:

1. **Edit `allowed-ips.txt`:**
   ```bash
   # Add allowed IP addresses (one per line)
   127.0.0.1          # Localhost (always included)
   192.168.1.100      # Your development machine
   10.0.0.50          # Another team member's machine
   ```

2. **Run network configuration:**
   ```bash
   ./configure-network.sh
   ```

3. **Restart services:**
   ```bash
   # Stop current services
   docker-compose -f docker-compose.prod.yml down
   
   # Start with new network configuration
   docker-compose -f docker-compose.prod.yml -f docker-compose.override.yml up -d
   ```

### Automatic Configuration

The `setup.sh` script automatically calls `configure-network.sh`, so new setups will use your `allowed-ips.txt` configuration.

### Access from Remote Machines

Once configured, remote machines can connect using:

```bash
# Replace YOUR_HOST_IP with the server's IP address

# PostgreSQL
psql "postgresql://postgres:PASSWORD@YOUR_HOST_IP:5433/postgres"

# Web Interfaces
open http://YOUR_HOST_IP:3005  # Grafana
open http://YOUR_HOST_IP:9091  # Prometheus  
open http://YOUR_HOST_IP:16687 # Jaeger
```

### Security Best Practices

- ✅ **Use specific IPs** instead of `0.0.0.0` (all interfaces)
- ✅ **Strong passwords** (automatically generated by setup.sh)
- ✅ **VPN/private networks** for remote access
- ✅ **Firewall rules** to limit access
- ✅ **SSL/TLS encryption** (enabled by default)

## 💾 Data Persistence Configuration

### Custom Storage Locations

You can customize where your data is stored by configuring paths in your `.env` file:

```bash
# Example configurations in .env

# Store in user home directory (default)
DATA_PATH=~/postgres-ai-data

# Store everything in current directory (relative)
DATA_PATH=./data

# Store on external storage
DATA_PATH=/mnt/storage/postgres-platform

# Store in system directory (requires permissions)
DATA_PATH=/opt/postgres-ai-platform/data

# Individual service paths (advanced)
POSTGRES_DATA_PATH=/var/lib/postgresql/data
PROMETHEUS_DATA_PATH=/var/lib/prometheus  
GRAFANA_DATA_PATH=/var/lib/grafana
```

### Storage Requirements

- **PostgreSQL**: ~100MB minimum, grows with data
- **Prometheus**: ~10MB per day for metrics retention
- **Grafana**: ~10MB for dashboards and settings

### Backup and Migration

```bash
# Backup all data
tar -czf postgres-ai-backup.tar.gz data/

# Migrate to new location
mv data/ /new/storage/location/
# Update DATA_PATH in .env
# Restart services

# Restore from backup  
tar -xzf postgres-ai-backup.tar.gz
```

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
├── docker-compose.prod.yml      # Complete setup: Security, SSL, logging, limits + observability
├── setup.sh                     # Automated one-command setup script
├── configure-network.sh         # Network access configuration script
├── allowed-ips.txt              # Allowed IP addresses for network access
├── .env.example                 # Environment template (includes observability ports)
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
├── observability/               # Monitoring and observability stack
│   ├── prometheus.yml           # Prometheus configuration
│   └── grafana/                 # Grafana dashboards and provisioning
│       ├── dashboards/          # Pre-built PostgreSQL AI/ML dashboard
│       └── provisioning/        # Auto-configure datasources
└── README.md                    # This file
```

## ⚙️ Configuration Features

This setup provides a single, comprehensive configuration with:

- ✅ **SSL/TLS**: Required for encrypted connections
- ✅ **Full logging**: Complete audit trail and debugging
- ✅ **Resource limits**: CPU/Memory constraints for stability  
- ✅ **Full observability**: Grafana + Prometheus + Jaeger monitoring
- ✅ **PostgreSQL + AI/ML metrics**: Complete performance visibility
- ✅ **Non-default ports**: Enhanced security (PostgreSQL: 5433)
- ✅ **Production-ready**: Suitable for both development and production
- ✅ **One-command setup**: Automated via `setup.sh`

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

We welcome contributions! This project aims to make PostgreSQL the best platform for AI/ML applications.

- 🐛 **Bug reports**: Use our [bug report template](.github/ISSUE_TEMPLATE/bug_report.md)
- 💡 **Feature requests**: Use our [feature request template](.github/ISSUE_TEMPLATE/feature_request.md)  
- 🔧 **Code contributions**: Read our [Contributing Guide](CONTRIBUTING.md)
- 📚 **Documentation**: Help improve examples and use cases
- 🧪 **Testing**: Test with different AI/ML workloads and report results

### Quick Contribution Guide
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-ai-feature`
3. Test with both dev and prod configurations
4. Submit a Pull Request with our [PR template](.github/pull_request_template.md)

## 🌟 Contributors

Thanks to all the amazing people who have contributed to this project! 

<!-- If you contribute, please add yourself here -->
- [@v-v-l](https://github.com/v-v-l) - Original creator and maintainer

## 🚀 Star History

If this project helps you build better AI/ML applications, please consider giving it a ⭐!

## 📢 Community

- 💬 **Discussions**: Share your AI/ML use cases and ask questions
- 🐦 **Updates**: Follow for updates on new AI/ML features
- 📖 **Blog**: Read about PostgreSQL AI/ML best practices

## 🔗 Related Projects

- [pgvector](https://github.com/pgvector/pgvector) - Vector similarity search for PostgreSQL
- [PostgreSQL](https://www.postgresql.org/) - The world's most advanced open source database
- [OpenAI](https://openai.com/) - For AI embeddings and models
- [Hugging Face](https://huggingface.co/) - For open source AI models and embeddings