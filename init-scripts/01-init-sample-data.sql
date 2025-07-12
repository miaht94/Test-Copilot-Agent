-- Sample data for the source database
-- This creates tables and sample data for the pipeline demonstration

-- Create schema for source data
CREATE SCHEMA IF NOT EXISTS sales;

-- Create customers table
CREATE TABLE sales.customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create products table
CREATE TABLE sales.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    brand VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create orders table
CREATE TABLE sales.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES sales.customers(customer_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(10,2),
    shipping_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create order_items table
CREATE TABLE sales.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES sales.orders(order_id),
    product_id INTEGER REFERENCES sales.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED
);

-- Insert sample customers
INSERT INTO sales.customers (customer_name, email, phone, address, city, state, country) VALUES
('John Smith', 'john.smith@email.com', '+1-555-0101', '123 Main St', 'New York', 'NY', 'USA'),
('Sarah Johnson', 'sarah.johnson@email.com', '+1-555-0102', '456 Oak Ave', 'Los Angeles', 'CA', 'USA'),
('Michael Brown', 'michael.brown@email.com', '+1-555-0103', '789 Pine St', 'Chicago', 'IL', 'USA'),
('Emily Davis', 'emily.davis@email.com', '+1-555-0104', '321 Elm St', 'Houston', 'TX', 'USA'),
('David Wilson', 'david.wilson@email.com', '+1-555-0105', '654 Maple Dr', 'Phoenix', 'AZ', 'USA'),
('Lisa Anderson', 'lisa.anderson@email.com', '+1-555-0106', '987 Cedar Ln', 'Philadelphia', 'PA', 'USA'),
('Robert Taylor', 'robert.taylor@email.com', '+1-555-0107', '147 Birch Rd', 'San Antonio', 'TX', 'USA'),
('Jennifer Martinez', 'jennifer.martinez@email.com', '+1-555-0108', '258 Spruce Ave', 'San Diego', 'CA', 'USA'),
('Christopher Lee', 'christopher.lee@email.com', '+1-555-0109', '369 Willow St', 'Dallas', 'TX', 'USA'),
('Amanda Clark', 'amanda.clark@email.com', '+1-555-0110', '741 Poplar Dr', 'San Jose', 'CA', 'USA');

-- Insert sample products
INSERT INTO sales.products (product_name, category, brand, price, cost, description) VALUES
('Laptop Pro 15"', 'Electronics', 'TechBrand', 1299.99, 800.00, 'High-performance laptop for professionals'),
('Wireless Mouse', 'Electronics', 'TechBrand', 29.99, 15.00, 'Ergonomic wireless mouse with long battery life'),
('Mechanical Keyboard', 'Electronics', 'TechBrand', 89.99, 45.00, 'RGB backlit mechanical keyboard'),
('USB-C Hub', 'Electronics', 'TechBrand', 49.99, 25.00, '7-in-1 USB-C hub with multiple ports'),
('Portable Monitor', 'Electronics', 'TechBrand', 249.99, 150.00, '15.6" portable USB-C monitor'),
('Noise Cancelling Headphones', 'Electronics', 'AudioBrand', 199.99, 120.00, 'Premium noise cancelling over-ear headphones'),
('Bluetooth Speaker', 'Electronics', 'AudioBrand', 79.99, 40.00, 'Waterproof portable Bluetooth speaker'),
('Smartphone Case', 'Accessories', 'ProtectBrand', 24.99, 8.00, 'Shockproof case for latest smartphones'),
('Phone Charger Cable', 'Accessories', 'TechBrand', 19.99, 5.00, 'Fast charging USB-C cable 6ft'),
('Tablet Stand', 'Accessories', 'TechBrand', 34.99, 18.00, 'Adjustable aluminum tablet stand');

-- Insert sample orders
INSERT INTO sales.orders (customer_id, order_date, order_status, total_amount, shipping_address) VALUES
(1, '2024-01-15', 'completed', 1419.97, '123 Main St, New York, NY, USA'),
(2, '2024-01-16', 'completed', 339.97, '456 Oak Ave, Los Angeles, CA, USA'),
(3, '2024-01-17', 'shipped', 109.98, '789 Pine St, Chicago, IL, USA'),
(4, '2024-01-18', 'completed', 274.97, '321 Elm St, Houston, TX, USA'),
(5, '2024-01-19', 'processing', 1549.98, '654 Maple Dr, Phoenix, AZ, USA'),
(6, '2024-01-20', 'completed', 199.99, '987 Cedar Ln, Philadelphia, PA, USA'),
(7, '2024-01-21', 'shipped', 154.97, '147 Birch Rd, San Antonio, TX, USA'),
(8, '2024-01-22', 'completed', 44.98, '258 Spruce Ave, San Diego, CA, USA'),
(9, '2024-01-23', 'processing', 289.98, '369 Willow St, Dallas, TX, USA'),
(10, '2024-01-24', 'completed', 79.99, '741 Poplar Dr, San Jose, CA, USA');

-- Insert sample order items
INSERT INTO sales.order_items (order_id, product_id, quantity, unit_price) VALUES
-- Order 1: Customer 1
(1, 1, 1, 1299.99), -- Laptop Pro 15"
(1, 2, 1, 29.99),   -- Wireless Mouse
(1, 3, 1, 89.99),   -- Mechanical Keyboard

-- Order 2: Customer 2
(2, 5, 1, 249.99),  -- Portable Monitor
(2, 4, 1, 49.99),   -- USB-C Hub
(2, 9, 2, 19.99),   -- Phone Charger Cable x2

-- Order 3: Customer 3
(3, 2, 1, 29.99),   -- Wireless Mouse
(3, 7, 1, 79.99),   -- Bluetooth Speaker

-- Order 4: Customer 4
(4, 5, 1, 249.99),  -- Portable Monitor
(4, 8, 1, 24.99),   -- Smartphone Case

-- Order 5: Customer 5
(5, 1, 1, 1299.99), -- Laptop Pro 15"
(5, 5, 1, 249.99),  -- Portable Monitor

-- Order 6: Customer 6
(6, 6, 1, 199.99),  -- Noise Cancelling Headphones

-- Order 7: Customer 7
(7, 7, 1, 79.99),   -- Bluetooth Speaker
(7, 4, 1, 49.99),   -- USB-C Hub
(7, 8, 1, 24.99),   -- Smartphone Case

-- Order 8: Customer 8
(8, 8, 1, 24.99),   -- Smartphone Case
(8, 9, 1, 19.99),   -- Phone Charger Cable

-- Order 9: Customer 9
(9, 1, 1, 1299.99), -- Laptop Pro 15" (discounted)
(9, 10, 1, 34.99),  -- Tablet Stand

-- Order 10: Customer 10
(10, 7, 1, 79.99);  -- Bluetooth Speaker

-- Create indexes for better performance
CREATE INDEX idx_orders_customer_id ON sales.orders(customer_id);
CREATE INDEX idx_orders_order_date ON sales.orders(order_date);
CREATE INDEX idx_order_items_order_id ON sales.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON sales.order_items(product_id);
CREATE INDEX idx_customers_email ON sales.customers(email);
CREATE INDEX idx_products_category ON sales.products(category);