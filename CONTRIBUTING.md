# Contributing to PostgreSQL AI/ML Docker Setup

Thank you for your interest in contributing! This project aims to provide a comprehensive, production-ready PostgreSQL setup with advanced AI/ML capabilities.

## 🚀 How to Contribute

### Reporting Bugs
- Use GitHub Issues with the `bug` label
- Include your OS, Docker version, and steps to reproduce
- Provide logs from `docker-compose logs`

### Suggesting Features
- Use GitHub Issues with the `enhancement` label  
- Explain the use case and expected behavior
- Consider if it fits the project's AI/ML focus

### Contributing Code
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test with both dev and prod configurations
5. Update documentation as needed
6. Submit a Pull Request

## 🧪 Testing Your Changes

### Required Tests
```bash
# Test development setup
docker-compose -f docker-compose.dev.yml up -d
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres" -c "SELECT extname FROM pg_extension;"

# Test production setup  
docker-compose -f docker-compose.prod.yml up -d
psql "postgresql://postgres:CHANGE_ME_TO_STRONG_PASSWORD@localhost:5432/postgres" -c "SELECT * FROM hybrid_search('test', ARRAY(SELECT random() FROM generate_series(1, 1536))::vector, 0.5, 0.5, 1);"

# Clean up
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.prod.yml down -v
```

### Extension Testing
If adding new PostgreSQL extensions:
- Ensure they work in the pgvector Docker image
- Add proper error handling in SQL scripts
- Update the README with usage examples
- Test with both ARM64 and x86_64 architectures

## 📋 Code Standards

### SQL Scripts
- Use `CREATE EXTENSION IF NOT EXISTS`
- Include proper error handling for optional extensions
- Add comments explaining AI/ML use cases
- Follow PostgreSQL naming conventions

### Docker Configuration
- Maintain compatibility with both dev and prod modes
- Use environment variables for configuration
- Include health checks for new services
- Document any new environment variables

### Documentation
- Update README.md for significant changes
- Include real-world examples for new features
- Explain the AI/ML benefits and use cases
- Keep examples practical and business-focused

## 🎯 Project Goals

This project focuses on:
- **AI/ML capabilities** - Vector search, embeddings, hybrid search
- **Production readiness** - Security, performance, monitoring
- **Developer experience** - Easy setup, clear documentation
- **Enterprise features** - Multi-project support, proper isolation

## 🔍 Areas for Contribution

### High Priority
- Additional AI/ML PostgreSQL extensions
- Performance optimizations for vector operations
- More real-world AI/ML examples
- Integration with popular ML frameworks

### Medium Priority  
- Additional database initialization examples
- Monitoring and observability improvements
- Backup and recovery procedures
- Cloud deployment guides

### Documentation
- Video tutorials or demos
- Integration guides for popular AI/ML libraries
- Performance benchmarking results
- Best practices documentation

## 📝 Pull Request Guidelines

### PR Title Format
- `feat: add new AI/ML feature`
- `fix: resolve extension loading issue`
- `docs: update hybrid search examples`
- `perf: optimize vector indexing`

### PR Description
- Explain the problem being solved
- Describe your solution approach
- Include testing steps
- Mention any breaking changes
- Add screenshots for UI changes

### Review Process
1. Automated tests must pass
2. Manual testing on both dev/prod configurations
3. Documentation review
4. Code review by maintainers
5. Final approval and merge

## 🤝 Community Guidelines

- Be respectful and constructive
- Focus on technical merit
- Help newcomers learn PostgreSQL and AI/ML concepts
- Share real-world use cases and experiences
- Collaborate on complex features

## 📞 Getting Help

- GitHub Discussions for questions
- GitHub Issues for bugs and feature requests
- Check existing issues before creating new ones
- Provide detailed context and examples

## 🏆 Recognition

Contributors will be:
- Listed in the README contributors section
- Mentioned in release notes
- Invited to join the maintainers team for significant contributions

Thank you for helping make PostgreSQL a world-class AI/ML platform! 🚀