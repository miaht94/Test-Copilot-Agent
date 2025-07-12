-- Staging model for products from Postgres
{{
  config(
    materialized='view',
    schema='staging'
  )
}}

SELECT 
    product_id,
    product_name,
    category,
    brand,
    price,
    cost,
    description,
    created_at
FROM {{ source('postgres', 'products') }}