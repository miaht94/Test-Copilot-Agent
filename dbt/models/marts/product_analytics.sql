-- Product analytics aggregation
{{
  config(
    materialized='table',
    schema='marts'
  )
}}

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    p.cost,
    p.profit_margin,
    p.profit_margin_pct,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.quantity) as total_quantity_sold,
    SUM(fs.total_price) as total_revenue,
    SUM(fs.profit) as total_profit,
    AVG(fs.quantity) as avg_quantity_per_order,
    COUNT(DISTINCT fs.customer_id) as unique_customers,
    CURRENT_TIMESTAMP as updated_at
FROM {{ ref('dim_products') }} p
JOIN {{ ref('fact_sales') }} fs ON p.product_id = fs.product_id
GROUP BY 
    p.product_id,
    p.product_name,
    p.category,
    p.brand,
    p.price,
    p.cost,
    p.profit_margin,
    p.profit_margin_pct