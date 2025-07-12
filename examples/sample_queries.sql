-- Example queries for the Trino + DBT + Iceberg pipeline

-- 1. Query source data from Postgres through Trino
SELECT 
    c.customer_name,
    c.city,
    c.state,
    COUNT(o.order_id) as order_count
FROM postgres.sales.customers c
JOIN postgres.sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_name, c.city, c.state
ORDER BY order_count DESC;

-- 2. Query staging views in Iceberg
SELECT * FROM iceberg.staging.stg_customers LIMIT 10;
SELECT * FROM iceberg.staging.stg_products WHERE category = 'Electronics';
SELECT * FROM iceberg.staging.stg_orders WHERE order_status = 'completed';

-- 3. Query transformed data in marts
SELECT 
    customer_name,
    total_orders,
    total_revenue,
    avg_order_value
FROM iceberg.marts.customer_analytics
ORDER BY total_revenue DESC
LIMIT 10;

-- 4. Product performance analysis
SELECT 
    product_name,
    category,
    total_quantity_sold,
    total_revenue,
    total_profit,
    profit_margin_pct
FROM iceberg.marts.product_analytics
ORDER BY total_profit DESC;

-- 5. Sales fact table analysis
SELECT 
    order_date,
    COUNT(DISTINCT order_id) as orders,
    SUM(quantity) as items_sold,
    SUM(total_price) as revenue,
    SUM(profit) as profit
FROM iceberg.marts.fact_sales
GROUP BY order_date
ORDER BY order_date;

-- 6. Cross-catalog join (Postgres source + Iceberg analytics)
SELECT 
    p.product_name,
    p.price as current_price,
    pa.total_quantity_sold,
    pa.total_revenue
FROM postgres.sales.products p
JOIN iceberg.marts.product_analytics pa ON p.product_id = pa.product_id
WHERE pa.total_revenue > 200;

-- 7. Time-based analysis
SELECT 
    EXTRACT(MONTH FROM order_date) as month,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(total_price) as monthly_revenue
FROM iceberg.marts.fact_sales
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

-- 8. Customer segmentation
SELECT 
    CASE 
        WHEN total_revenue >= 1000 THEN 'High Value'
        WHEN total_revenue >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(total_revenue) as avg_revenue_per_customer
FROM iceberg.marts.customer_analytics
GROUP BY 
    CASE 
        WHEN total_revenue >= 1000 THEN 'High Value'
        WHEN total_revenue >= 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END;