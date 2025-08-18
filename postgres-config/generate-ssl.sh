#!/bin/bash
# Generate self-signed SSL certificates for PostgreSQL

echo "Generating self-signed SSL certificates for PostgreSQL..."

# Generate private key
openssl genrsa -out server.key 2048

# Generate certificate signing request
openssl req -new -key server.key -out server.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Generate self-signed certificate
openssl x509 -req -in server.csr -signkey server.key -out server.crt -days 365

# Set correct permissions
chmod 600 server.key
chmod 644 server.crt

# Clean up
rm server.csr

echo "SSL certificates generated successfully!"
echo "Files created: server.key, server.crt"