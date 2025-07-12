-- Customer analytics aggregation
{{
  config(
    materialized='table',
    schema='marts'
  )
}}

SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.state,
    c.country,
    COUNT(DISTINCT fs.order_id) as total_orders,
    SUM(fs.quantity) as total_items_purchased,
    SUM(fs.total_price) as total_revenue,
    SUM(fs.profit) as total_profit,
    AVG(fs.total_price) as avg_order_value,
    MIN(fs.order_date) as first_order_date,
    MAX(fs.order_date) as last_order_date,
    CURRENT_TIMESTAMP as updated_at
FROM {{ ref('dim_customers') }} c
JOIN {{ ref('fact_sales') }} fs ON c.customer_id = fs.customer_id
GROUP BY 
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    c.state,
    c.country