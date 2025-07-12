-- Staging model for customers from Postgres
{{
  config(
    materialized='view',
    schema='staging'
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
    created_at
FROM {{ source('postgres', 'customers') }}