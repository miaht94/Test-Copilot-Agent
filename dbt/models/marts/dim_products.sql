-- Dimension table for products
{{
  config(
    materialized='table',
    schema='marts'
  )
}}

SELECT 
    product_id,
    product_name,
    category,
    brand,
    price,
    cost,
    ROUND(price - cost, 2) as profit_margin,
    ROUND(((price - cost) / price) * 100, 2) as profit_margin_pct,
    description,
    created_at,
    CURRENT_TIMESTAMP as updated_at
FROM {{ ref('stg_products') }}