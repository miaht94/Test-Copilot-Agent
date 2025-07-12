#!/bin/bash

# Validation script to test the pipeline
echo "🔍 Validating Trino + DBT + Iceberg Pipeline..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

success_count=0
total_tests=0

run_test() {
    local test_name="$1"
    local command="$2"
    local expected_pattern="$3"
    
    total_tests=$((total_tests + 1))
    echo -e "${YELLOW}Testing: $test_name${NC}"
    
    result=$(eval "$command" 2>&1)
    if echo "$result" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}✅ PASS: $test_name${NC}"
        success_count=$((success_count + 1))
    else
        echo -e "${RED}❌ FAIL: $test_name${NC}"
        echo "Expected pattern: $expected_pattern"
        echo "Actual result: $result"
    fi
    echo ""
}

# Test 1: Check if containers are running
run_test "All containers running" \
    "docker compose ps --services --filter 'status=running' | wc -l" \
    "6"

# Test 2: Postgres source data
run_test "Postgres source data available" \
    "docker exec postgres psql -U postgres -d sourcedb -t -c 'SELECT COUNT(*) FROM sales.customers;'" \
    "10"

# Test 3: Trino connectivity
run_test "Trino is accessible" \
    "curl -s http://localhost:8080/v1/info | jq -r '.starting'" \
    "false"

# Test 4: Trino can query Postgres
run_test "Trino can query Postgres source" \
    "docker exec trino trino --execute 'SELECT COUNT(*) FROM postgres.sales.customers;' --output-format TSV_HEADER" \
    "10"

# Test 5: Iceberg schemas exist
run_test "Iceberg schemas created" \
    "docker exec trino trino --execute 'SHOW SCHEMAS FROM iceberg;' --output-format TSV_HEADER" \
    "staging"

# Test 6: DBT models compiled
run_test "DBT can compile models" \
    "docker exec dbt dbt compile --quiet" \
    "Completed successfully"

# Test 7: DBT staging models run
run_test "DBT staging models exist" \
    "docker exec trino trino --execute 'SHOW TABLES FROM iceberg.staging;' --output-format TSV_HEADER" \
    "stg_customers"

# Test 8: DBT mart models run
run_test "DBT mart models exist" \
    "docker exec trino trino --execute 'SHOW TABLES FROM iceberg.marts;' --output-format TSV_HEADER" \
    "fact_sales"

# Test 9: Data in fact table
run_test "Fact table has data" \
    "docker exec trino trino --execute 'SELECT COUNT(*) FROM iceberg.marts.fact_sales;' --output-format TSV_HEADER" \
    "13"

# Test 10: Analytics data available
run_test "Customer analytics has data" \
    "docker exec trino trino --execute 'SELECT COUNT(*) FROM iceberg.marts.customer_analytics;' --output-format TSV_HEADER" \
    "10"

# Summary
echo "=============================="
echo -e "${YELLOW}Validation Summary${NC}"
echo "=============================="
echo -e "Passed: ${GREEN}$success_count${NC} / $total_tests tests"

if [ $success_count -eq $total_tests ]; then
    echo -e "${GREEN}🎉 All tests passed! Pipeline is working correctly.${NC}"
    exit 0
else
    failed_count=$((total_tests - success_count))
    echo -e "${RED}❌ $failed_count test(s) failed. Please check the configuration.${NC}"
    exit 1
fi