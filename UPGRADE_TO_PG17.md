# PostgreSQL 15 → 17 Upgrade Guide

## ✅ Upgrade Complete

**Status**: Successfully upgraded from PostgreSQL 15.14 to PostgreSQL 17.6
**Date**: September 4, 2025

## What Was Upgraded

### Docker Images
- **Before**: `pgvector/pgvector:pg15`  
- **After**: `pgvector/pgvector:pg17`

### Files Modified
- `docker-compose.yml`
- `docker-compose.dev.yml`
- `docker-compose.prod.yml`

### Backup Files Created
- `docker-compose.yml.pg15.backup`
- `docker-compose.dev.yml.pg15.backup`  
- `docker-compose.prod.yml.pg15.backup`

## ✅ Verified Working Features

### Core Extensions
- ✅ **pgvector** - vector similarity search
- ✅ **pg_trgm** - fuzzy text matching (0.5 similarity score)
- ✅ **fuzzystrmatch** - string similarity functions
- ✅ **unaccent** - accent removal
- ✅ **ltree** - hierarchical data (`AI.Machine_Learning.Deep_Learning`)
- ✅ **hstore** - key-value storage
- ✅ **cube** - multi-dimensional data
- ✅ **earthdistance** - geographic calculations

### AI/ML Tables
- ✅ **ai_embeddings** - multi-modal vector storage
- ✅ **smart_documents** - hybrid text + vector search
- ✅ **ai_taxonomy** - hierarchical AI classifications
- ✅ **ai_metrics** - time-series ML data

### Vector Operations Tested
```sql
-- Vector distance calculation works ✅
SELECT embedding <-> '[1,2,3]' as distance FROM test_vectors;
-- Result: 0 (exact match), 1.732 (different vector)
```

## 🚨 Important Notes

### Data Compatibility
- **PostgreSQL 17 cannot read PG15 data files**
- **Solution**: Fresh initialization (development data was recreated)
- **Impact**: All initialization scripts ran successfully, tables recreated

### Production Considerations
- **Production data**: `./data/prod/` still contains PG15 data
- **Migration needed**: Use pg_dump/pg_restore for production upgrade
- **Downtime required**: Data migration process needed

## 🔄 Rollback Process (If Needed)

### Quick Rollback (Development)
```bash
# 1. Stop current containers
docker-compose -f docker-compose.dev.yml down

# 2. Restore PG15 configuration
cp docker-compose.dev.yml.pg15.backup docker-compose.dev.yml
cp docker-compose.yml.pg15.backup docker-compose.yml
cp docker-compose.prod.yml.pg15.backup docker-compose.prod.yml

# 3. Start PG15
docker-compose -f docker-compose.dev.yml up -d
```

### Production Data Migration (When Ready)
```bash
# 1. Backup PG15 data
docker run --rm -v postgres_data:/source -v $(pwd):/backup alpine tar czf /backup/pg15-backup.tar.gz /source

# 2. Export data from PG15
docker run --rm pgvector/pgvector:pg15 pg_dump -U postgres > pg15-data.sql

# 3. Start PG17 and import
docker-compose -f docker-compose.prod.yml up -d
# Wait for healthy status, then:
cat pg15-data.sql | docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres
```

## 🆕 PostgreSQL 17 New Features

### Available in Your Setup
- **JSON_TABLE** - SQL/JSON standard support
- **MERGE improvements** - better upsert performance  
- **Parallel vacuum** - faster maintenance operations
- **Logical replication enhancements**
- **Performance improvements** across the board
- **Enhanced security features**

### Test New Features
```sql
-- JSON_TABLE (new in PG17)
SELECT * FROM JSON_TABLE('[{"name":"AI"},{"name":"ML"}]', '$[*]' COLUMNS (name TEXT PATH '$.name'));

-- Improved MERGE operations
MERGE INTO ai_embeddings t USING (VALUES (1, '[1,2,3]')) s(id, vec) 
ON t.id = s.id 
WHEN MATCHED THEN UPDATE SET embedding = s.vec::vector
WHEN NOT MATCHED THEN INSERT (id, text_embedding) VALUES (s.id, s.vec::vector);
```

## 🎯 Next Steps

1. **✅ Development**: Fully working on PG17
2. **🔄 Production**: Migrate when ready using pg_dump/restore
3. **📊 Monitor**: Watch for performance improvements
4. **🔧 Optimize**: Leverage new PG17 features in applications

## Support

If issues arise:
1. Check container logs: `docker-compose -f docker-compose.dev.yml logs postgres`
2. Test connection: `psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres"`
3. Rollback using steps above if needed