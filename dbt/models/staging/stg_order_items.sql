-- Staging model for order items from Postgres
{{
  config(
    materialized='view',
    schema='staging'
  )
}}

SELECT 
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    total_price
FROM {{ source('postgres', 'order_items') }}