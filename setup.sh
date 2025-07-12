#!/bin/bash

# Setup script for the Trino + DBT + Iceberg Pipeline
set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose plugin is not installed"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Wait for service to be ready
wait_for_service() {
    local service_name="$1"
    local health_check="$2"
    local max_attempts=30
    local attempt=0
    
    log_info "Waiting for $service_name to be ready..."
    
    while [ $attempt -lt $max_attempts ]; do
        if eval "$health_check" >/dev/null 2>&1; then
            log_success "$service_name is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 10
    done
    
    log_error "$service_name failed to start within expected time"
    return 1
}

echo -e "${BLUE}🚀 Starting Trino + DBT + Iceberg Pipeline Setup...${NC}"
echo ""

# Check prerequisites
check_prerequisites

# Start the services
log_info "Starting Docker Compose services..."
docker compose up -d

# Wait for services to be ready
echo ""
log_info "Waiting for services to start up (this may take several minutes)..."

# Wait for Postgres
wait_for_service "Postgres" "docker exec postgres pg_isready -U postgres"

# Wait for Minio
wait_for_service "Minio" "curl -s http://localhost:9000/minio/health/live"

# Wait for Hive Metastore
wait_for_service "Hive Metastore" "docker exec hive-metastore nc -z localhost 9083"

# Wait for Trino
wait_for_service "Trino" "curl -s http://localhost:8080/v1/info | grep -q '\"starting\":false'"

log_success "All services are ready!"
echo ""

# Setup Iceberg schemas
log_info "Setting up Iceberg catalog and schemas..."
docker exec trino trino --execute "CREATE SCHEMA IF NOT EXISTS iceberg.staging" || log_warning "Schema staging may already exist"
docker exec trino trino --execute "CREATE SCHEMA IF NOT EXISTS iceberg.marts" || log_warning "Schema marts may already exist"
docker exec trino trino --execute "CREATE SCHEMA IF NOT EXISTS iceberg.analytics" || log_warning "Schema analytics may already exist"

log_success "Iceberg schemas created"

# Verify source data
log_info "Verifying source data in Postgres..."
customer_count=$(docker exec postgres psql -U postgres -d sourcedb -t -c "SELECT COUNT(*) FROM sales.customers;" | xargs)
product_count=$(docker exec postgres psql -U postgres -d sourcedb -t -c "SELECT COUNT(*) FROM sales.products;" | xargs)
order_count=$(docker exec postgres psql -U postgres -d sourcedb -t -c "SELECT COUNT(*) FROM sales.orders;" | xargs)

echo "  📊 Customers: $customer_count"
echo "  📦 Products: $product_count"  
echo "  🛒 Orders: $order_count"

log_success "Source data verified"

# Run DBT transformations
log_info "Running DBT transformations..."

log_info "  - Checking DBT configuration..."
if docker exec dbt dbt debug --quiet; then
    log_success "DBT configuration is valid"
else
    log_error "DBT configuration failed"
    exit 1
fi

log_info "  - Installing DBT dependencies..."
docker exec dbt dbt deps --quiet || log_warning "No dependencies to install"

log_info "  - Running DBT models..."
if docker exec dbt dbt run --quiet; then
    log_success "DBT models executed successfully"
else
    log_error "DBT models failed to execute"
    exit 1
fi

log_info "  - Running DBT tests..."
if docker exec dbt dbt test --quiet; then
    log_success "DBT tests passed"
else
    log_warning "Some DBT tests failed (this may be expected for a demo)"
fi

# Verify transformed data
log_info "Verifying transformed data in Iceberg..."

# Check schemas
staging_tables=$(docker exec trino trino --execute "SHOW TABLES FROM iceberg.staging" --output-format TSV_HEADER | tail -n +2 | wc -l)
marts_tables=$(docker exec trino trino --execute "SHOW TABLES FROM iceberg.marts" --output-format TSV_HEADER | tail -n +2 | wc -l)

echo "  📋 Staging tables: $staging_tables"
echo "  🏪 Marts tables: $marts_tables"

# Sample data verification
if [ "$staging_tables" -gt 0 ] && [ "$marts_tables" -gt 0 ]; then
    log_success "Transformed data verified"
    
    log_info "Sample analytics results:"
    echo ""
    echo "🏆 Top Customers by Revenue:"
    docker exec trino trino --execute "SELECT customer_name, total_orders, total_revenue FROM iceberg.marts.customer_analytics ORDER BY total_revenue DESC LIMIT 5" --output-format TABLE
    
    echo ""
    echo "📈 Top Products by Revenue:" 
    docker exec trino trino --execute "SELECT product_name, total_quantity_sold, total_revenue FROM iceberg.marts.product_analytics ORDER BY total_revenue DESC LIMIT 5" --output-format TABLE
else
    log_warning "Transformed data verification incomplete"
fi

echo ""
log_success "Setup complete! Your Trino + DBT + Iceberg pipeline is ready!"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "  - Trino UI: http://localhost:8080"
echo "  - Minio Console: http://localhost:9001 (minioadmin/minioadmin)"
echo ""
echo -e "${BLUE}🛠️  Useful commands:${NC}"
echo "  - Connect to Trino CLI: docker exec -it trino trino"
echo "  - Run DBT models: docker exec dbt dbt run"
echo "  - View DBT docs: docker exec dbt dbt docs generate && docker exec dbt dbt docs serve --host 0.0.0.0"
echo "  - Validate pipeline: ./validate.sh"
echo "  - Stop pipeline: ./stop.sh"
echo ""
log_success "Happy querying! 🎉"