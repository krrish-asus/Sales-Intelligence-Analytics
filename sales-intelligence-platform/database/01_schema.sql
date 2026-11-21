CREATE DATABASE IF NOT EXISTS sales_intelligence;
USE sales_intelligence;

CREATE TABLE regions (
  region_id INT PRIMARY KEY,
  region_name VARCHAR(50) NOT NULL,
  city VARCHAR(80) NOT NULL,
  zone VARCHAR(30) NOT NULL
);

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL UNIQUE,
  segment ENUM('Consumer','Corporate','Small Business') NOT NULL,
  signup_date DATE NOT NULL,
  region_id INT NOT NULL,
  CONSTRAINT fk_customer_region FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(120) NOT NULL,
  category VARCHAR(60) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
  unit_cost DECIMAL(12,2) NOT NULL CHECK (unit_cost >= 0),
  INDEX idx_products_category(category)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  status ENUM('Delivered','Shipped','Processing','Cancelled','Returned') NOT NULL,
  sales_channel ENUM('Website','Mobile App','Marketplace','Retail Store') NOT NULL,
  CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  INDEX idx_orders_date(order_date),
  INDEX idx_orders_customer(customer_id),
  INDEX idx_orders_status(status)
);

CREATE TABLE order_items (
  order_item_id INT PRIMARY KEY,
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12,2) NOT NULL,
  discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (discount_pct BETWEEN 0 AND 1),
  CONSTRAINT fk_item_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products(product_id),
  INDEX idx_items_order(order_id),
  INDEX idx_items_product(product_id)
);
