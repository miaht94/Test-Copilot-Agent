#!/bin/bash

# Clean shutdown script
echo "🛑 Stopping Trino + DBT + Iceberg Pipeline..."

# Stop and remove containers
docker compose down

# Optional: Remove volumes (uncomment to clean all data)
# docker compose down -v

echo "✅ Pipeline stopped successfully!"