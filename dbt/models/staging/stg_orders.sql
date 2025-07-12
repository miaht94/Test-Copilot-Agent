-- Staging model for orders from Postgres
{{
  config(
    materialized='view',
    schema='staging'
  )
}}

SELECT 
    order_id,
    customer_id,
    order_date,
    order_status,
    total_amount,
    shipping_address,
    created_at
FROM {{ source('postgres', 'orders') }}