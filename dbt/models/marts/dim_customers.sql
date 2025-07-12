-- Dimension table for customers
{{
  config(
    materialized='table',
    schema='marts'
  )
}}

SELECT 
    customer_id,
    customer_name,
    email,
    phone,
    address,
    city,
    state,
    country,
    created_at,
    CURRENT_TIMESTAMP as updated_at
FROM {{ ref('stg_customers') }}