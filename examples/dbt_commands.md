# Running Manual DBT Commands

This guide shows how to run DBT commands manually in the containerized environment.

## Connect to DBT Container

```bash
docker exec -it dbt bash
```

## DBT Commands

### Check DBT Configuration
```bash
dbt debug
```

### Install Dependencies
```bash
dbt deps
```

### Run Staging Models Only
```bash
dbt run --models staging
```

### Run Marts Models Only
```bash
dbt run --models marts
```

### Run a Specific Model
```bash
dbt run --models dim_customers
dbt run --models fact_sales
```

### Run Models with Downstream Dependencies
```bash
dbt run --models +fact_sales
```

### Run Tests
```bash
dbt test
```

### Run Tests for Specific Models
```bash
dbt test --models staging
```

### Generate Documentation
```bash
dbt docs generate
dbt docs serve --host 0.0.0.0 --port 8081
```

### Seed Data (if you have seed files)
```bash
dbt seed
```

### Full Refresh (rebuild incremental models)
```bash
dbt run --full-refresh
```

### Run with Specific Profile/Target
```bash
dbt run --profile trino_pipeline --target dev
```

### Compile Models (without running)
```bash
dbt compile
```

### Parse Models
```bash
dbt parse
```

### Clean Generated Files
```bash
dbt clean
```

## DBT Logs

View DBT logs:
```bash
cat logs/dbt.log
```

## Environment Variables

You can set environment variables for DBT:
```bash
export DBT_PROFILES_DIR=/root/.dbt
export DBT_PROJECT_DIR=/usr/app
```

## Troubleshooting

### Connection Issues
- Check if Trino is running: `curl http://trino:8080/v1/info`
- Verify catalog access: `dbt run-operation show_catalogs`

### Model Issues
- Check compiled SQL: `dbt compile --models <model_name>`
- View model dependencies: `dbt list --models <model_name> --resource-type model`