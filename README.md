# Trino + DBT + Iceberg Data Pipeline

A complete end-to-end data pipeline template that demonstrates modern data lake architecture using Trino, DBT, and Apache Iceberg with S3-compatible storage (Minio).

## 🏗️ Architecture Overview

This pipeline demonstrates:

1. **Data Ingestion**: From PostgreSQL source database
2. **Data Transformation**: Using DBT models with SQL-based transformations
3. **Query Engine**: Trino for distributed SQL queries across multiple data sources
4. **Data Storage**: Apache Iceberg tables stored on Minio (S3A protocol)
5. **Data Catalog**: Hive Metastore for table metadata management

## 🔧 Components

- **PostgreSQL**: Source database with sample e-commerce data
- **Trino**: Distributed SQL query engine
- **DBT**: Data transformation tool with SQL models
- **Apache Iceberg**: Table format for large analytic datasets
- **Minio**: S3-compatible object storage
- **Hive Metastore**: Metadata management for Iceberg tables

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- At least 8GB RAM available for containers
- Ports 5432, 5433, 8080, 9000, 9001, 9083 available

### Setup

1. Clone this repository:
```bash
git clone <repository-url>
cd Test-Copilot-Agent
```

2. Run the setup script:
```bash
./setup.sh
```

This script will:
- Start all required services using Docker Compose
- Initialize sample data in PostgreSQL
- Set up Iceberg schemas in Trino
- Run DBT transformations
- Verify the pipeline is working

### Manual Setup (Alternative)

If you prefer manual setup:

```bash
# Start services
docker-compose up -d

# Wait for services to be ready (about 60 seconds)
sleep 60

# Create Iceberg schemas
docker exec trino trino --execute "CREATE SCHEMA IF NOT EXISTS iceberg.staging"
docker exec trino trino --execute "CREATE SCHEMA IF NOT EXISTS iceberg.marts"

# Run DBT transformations
docker exec dbt dbt run
docker exec dbt dbt test
```

## 📊 Sample Data

The pipeline includes sample e-commerce data:

- **Customers**: 10 sample customers with contact information
- **Products**: 10 sample products across electronics and accessories
- **Orders**: 10 sample orders with various statuses
- **Order Items**: Detailed line items for each order

## 🔍 Data Models

### Staging Models (`staging/`)
- `stg_customers`: Clean customer data from source
- `stg_products`: Clean product data from source  
- `stg_orders`: Clean order data from source
- `stg_order_items`: Clean order item data from source

### Mart Models (`marts/`)
- `dim_customers`: Customer dimension table
- `dim_products`: Product dimension table with calculated metrics
- `fact_sales`: Sales fact table with order and profit calculations
- `customer_analytics`: Customer aggregated analytics
- `product_analytics`: Product performance analytics

## 🌐 Access Points

After running setup:

- **Trino UI**: http://localhost:8080
- **Minio Console**: http://localhost:9001 (login: minioadmin/minioadmin)
- **PostgreSQL**: localhost:5432 (postgres/postgres)

## 📝 Usage Examples

### Connect to Trino CLI
```bash
docker exec -it trino trino
```

### Query Cross-Catalog Data
```sql
-- Query source data
SELECT * FROM postgres.sales.customers LIMIT 5;

-- Query transformed data
SELECT * FROM iceberg.marts.customer_analytics LIMIT 5;

-- Cross-catalog join
SELECT 
    p.product_name,
    pa.total_revenue
FROM postgres.sales.products p
JOIN iceberg.marts.product_analytics pa ON p.product_id = pa.product_id;
```

### Run DBT Commands
```bash
# Connect to DBT container
docker exec -it dbt bash

# Run all models
dbt run

# Run specific model
dbt run --models fact_sales

# Run tests
dbt test

# Generate documentation
dbt docs generate
```

## 📁 Project Structure

```
├── docker-compose.yml          # Container orchestration
├── setup.sh                    # Automated setup script
├── stop.sh                     # Clean shutdown script
├── init-scripts/               # PostgreSQL initialization
│   └── 01-init-sample-data.sql
├── trino-config/               # Trino configuration
│   ├── config.properties
│   ├── node.properties
│   └── catalog/
│       ├── postgres.properties
│       └── iceberg.properties
├── hive-config/                # Hive Metastore configuration
│   └── hive-site.xml
├── dbt/                        # DBT project
│   ├── dbt_project.yml
│   ├── profiles.yml
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   └── Dockerfile
└── examples/                   # Usage examples
    ├── sample_queries.sql
    └── dbt_commands.md
```

## 🧪 Testing the Pipeline

### Verify Source Data
```bash
docker exec postgres psql -U postgres -d sourcedb -c "SELECT COUNT(*) FROM sales.customers;"
```

### Verify Transformed Data
```bash
docker exec trino trino --execute "SELECT COUNT(*) FROM iceberg.marts.fact_sales;"
```

### Run Analytics Queries
```bash
docker exec trino trino --execute "SELECT customer_name, total_revenue FROM iceberg.marts.customer_analytics ORDER BY total_revenue DESC LIMIT 5;"
```

## 🛠️ Customization

### Adding New Source Tables
1. Add tables to PostgreSQL init script
2. Create staging models in `dbt/models/staging/`
3. Update `_sources.yml` with new table definitions
4. Create or update mart models as needed

### Adding New Transformations
1. Create new DBT models in appropriate folder
2. Update `dbt_project.yml` if needed
3. Run `dbt run` to execute

### Configuring Storage
- Modify Minio settings in `docker-compose.yml`
- Update S3 credentials in `hive-config/hive-site.xml`
- Adjust Trino catalog properties as needed

## 🐛 Troubleshooting

### Services Not Starting
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs trino
docker-compose logs dbt
```

### Connection Issues
```bash
# Test Trino connectivity
curl http://localhost:8080/v1/info

# Test PostgreSQL connectivity
docker exec postgres pg_isready -U postgres
```

### DBT Issues
```bash
# Debug DBT configuration
docker exec dbt dbt debug

# Check compiled SQL
docker exec dbt dbt compile
```

## 📚 Additional Resources

- [Trino Documentation](https://trino.io/docs/)
- [DBT Documentation](https://docs.getdbt.com/)
- [Apache Iceberg Documentation](https://iceberg.apache.org/docs/)
- [Minio Documentation](https://docs.min.io/)

## 🛑 Cleanup

To stop all services and clean up:

```bash
./stop.sh

# Or manually:
docker-compose down

# To remove all data volumes:
docker-compose down -v
```

## 📄 License

This project is provided as-is for educational and demonstration purposes.
