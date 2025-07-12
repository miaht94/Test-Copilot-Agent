# Architecture Documentation

## System Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │    │      Trino      │    │      Minio      │
│  (Source DB)    │◄──►│ (Query Engine)  │◄──►│  (S3 Storage)   │
│                 │    │                 │    │                 │
│ - sales.customers│    │ Catalogs:      │    │ - warehouse/    │
│ - sales.products │    │ - postgres     │    │   bucket        │
│ - sales.orders   │    │ - iceberg      │    │                 │
│ - sales.order_items   │                │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      DBT        │    │ Hive Metastore  │    │   Iceberg       │
│ (Transformation)│    │  (Metadata)     │    │   Tables        │
│                 │    │                 │    │                 │
│ Models:         │    │ - Table schemas │    │ - staging.*     │
│ - staging/      │    │ - Partitions    │    │ - marts.*       │
│ - marts/        │    │ - Statistics    │    │                 │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Data Flow

1. **Source Data**: PostgreSQL contains sample e-commerce data (customers, products, orders, order_items)

2. **Data Ingestion**: Trino connects to PostgreSQL using the `postgres` catalog

3. **Data Transformation**: 
   - DBT reads from PostgreSQL through Trino
   - Creates staging views for data cleaning
   - Builds mart tables with business logic
   - Writes transformed data to Iceberg tables

4. **Data Storage**: 
   - Iceberg tables stored in Minio (S3A protocol)
   - Metadata managed by Hive Metastore
   - Parquet format for efficient querying

5. **Data Access**: Trino provides unified SQL interface to query both source and transformed data

## Component Details

### PostgreSQL (Source Database)
- **Purpose**: Simulates operational database
- **Schema**: `sales` schema with normalized tables
- **Data**: Sample e-commerce transactions
- **Access**: Via Trino postgres catalog

### Trino (Query Engine)
- **Purpose**: Distributed SQL query engine
- **Catalogs**: 
  - `postgres`: Connects to source PostgreSQL
  - `iceberg`: Connects to Iceberg tables via Hive Metastore
- **Features**: Cross-catalog joins, federated queries

### DBT (Data Transformation)
- **Purpose**: SQL-based data transformation
- **Models**:
  - Staging: Clean, standardized views of source data
  - Marts: Business-focused dimensional and fact tables
- **Features**: Testing, documentation, lineage

### Apache Iceberg (Table Format)
- **Purpose**: High-performance table format for analytics
- **Features**: 
  - Schema evolution
  - Time travel
  - ACID transactions
  - Efficient metadata handling

### Minio (Object Storage)
- **Purpose**: S3-compatible object storage
- **Protocol**: S3A for Hadoop ecosystem compatibility
- **Buckets**: `warehouse` bucket for all Iceberg data

### Hive Metastore (Metadata Catalog)
- **Purpose**: Centralized metadata repository
- **Storage**: PostgreSQL backend
- **Manages**: Table schemas, partitions, statistics

## Data Models

### Staging Layer
Raw data cleaning and standardization:
- `stg_customers`: Cleaned customer data
- `stg_products`: Cleaned product data  
- `stg_orders`: Cleaned order data
- `stg_order_items`: Cleaned order item data

### Marts Layer
Business-focused analytics tables:
- `dim_customers`: Customer dimension
- `dim_products`: Product dimension with calculations
- `fact_sales`: Sales fact table with metrics
- `customer_analytics`: Customer aggregations
- `product_analytics`: Product performance metrics

## Performance Considerations

### Trino Optimizations
- Connector-specific optimizations
- Predicate pushdown to source systems
- Columnar storage format (Parquet)

### Iceberg Optimizations
- Partition pruning
- File-level metadata
- Vectorized reads
- Compaction strategies

### DBT Optimizations
- Incremental models for large datasets
- Materialization strategies
- Model dependencies optimization

## Security

### Access Control
- Trino authentication (basic setup)
- Catalog-level permissions
- Schema-level permissions

### Data Encryption
- Transport encryption (HTTPS/TLS)
- Storage encryption (Minio SSE)

## Monitoring and Observability

### Trino Monitoring
- Web UI at http://localhost:8080
- Query execution metrics
- Resource utilization

### DBT Monitoring
- Model execution logs
- Test results
- Documentation generation

### Infrastructure Monitoring
- Container health checks
- Service dependencies
- Resource usage

## Scalability

### Horizontal Scaling
- Trino worker nodes (not configured in this demo)
- Minio distributed mode
- Multiple DBT environments

### Vertical Scaling
- Memory allocation per service
- CPU resource limits
- Storage capacity planning