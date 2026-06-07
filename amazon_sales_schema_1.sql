-- ============================================================
--  Amazon Sales Analytics — MySQL Workbench Setup
--  Step 1: Run this entire file to create the database & schema
--  Step 2: See the LOAD DATA section at the bottom to import CSV
-- ============================================================

CREATE DATABASE IF NOT EXISTS amazon_sales;
USE amazon_sales;

-- ============================================================
--  TABLE 1: customers
-- ============================================================
CREATE TABLE IF NOT EXISTS customers (
    CustomerID   VARCHAR(20)  NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    City         VARCHAR(100),
    State        VARCHAR(50),
    Country      VARCHAR(50),
    PRIMARY KEY (CustomerID)
);

-- ============================================================
--  TABLE 2: sellers
-- ============================================================
CREATE TABLE IF NOT EXISTS sellers (
    SellerID VARCHAR(20) NOT NULL,
    PRIMARY KEY (SellerID)
);

-- ============================================================
--  TABLE 3: products
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    ProductID   VARCHAR(20)    NOT NULL,
    ProductName VARCHAR(200)   NOT NULL,
    Category    VARCHAR(100),
    Brand       VARCHAR(100),
    UnitPrice   DECIMAL(10, 2),
    PRIMARY KEY (ProductID)
);

-- ============================================================
--  TABLE 4: orders
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    OrderID       VARCHAR(20) NOT NULL,
    OrderDate     DATE        NOT NULL,
    CustomerID    VARCHAR(20) NOT NULL,
    SellerID      VARCHAR(20) NOT NULL,
    PaymentMethod VARCHAR(50),
    OrderStatus   VARCHAR(30),
    PRIMARY KEY (OrderID),
    FOREIGN KEY (CustomerID) REFERENCES customers(CustomerID),
    FOREIGN KEY (SellerID)   REFERENCES sellers(SellerID)
);

-- ============================================================
--  TABLE 5: order_items
-- ============================================================
CREATE TABLE IF NOT EXISTS order_items (
    ItemID       INT            NOT NULL AUTO_INCREMENT,
    OrderID      VARCHAR(20)    NOT NULL,
    ProductID    VARCHAR(20)    NOT NULL,
    Quantity     INT,
    UnitPrice    DECIMAL(10, 2),
    Discount     DECIMAL(5, 2),
    Tax          DECIMAL(10, 2),
    ShippingCost DECIMAL(10, 2),
    TotalAmount  DECIMAL(10, 2),
    PRIMARY KEY (ItemID),
    FOREIGN KEY (OrderID)   REFERENCES orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES products(ProductID)
);


-- ============================================================
--  LOAD DATA FROM CSV
--  Instructions:
--  1. Place your CSV file at: C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
--     (or check your secure_file_priv path using: SHOW VARIABLES LIKE 'secure_file_priv';)
--  2. Run the steps below ONE BY ONE in order
-- ============================================================

-- STEP A: Create a staging table (mirrors the raw CSV exactly)
CREATE TABLE IF NOT EXISTS raw_staging (
    OrderID       VARCHAR(20),
    OrderDate     VARCHAR(20),
    CustomerID    VARCHAR(20),
    CustomerName  VARCHAR(100),
    ProductID     VARCHAR(20),
    ProductName   VARCHAR(200),
    Category      VARCHAR(100),
    Brand         VARCHAR(100),
    Quantity      INT,
    UnitPrice     DECIMAL(10,2),
    Discount      DECIMAL(5,2),
    Tax           DECIMAL(10,2),
    ShippingCost  DECIMAL(10,2),
    TotalAmount   DECIMAL(10,2),
    PaymentMethod VARCHAR(50),
    OrderStatus   VARCHAR(30),
    City          VARCHAR(100),
    State         VARCHAR(50),
    Country       VARCHAR(50),
    SellerID      VARCHAR(20)
);

-- STEP B: Load the CSV into staging
--  Update the file path below to match where your CSV is saved.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Amazon_sales_data.csv'
INTO TABLE raw_staging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- STEP C: Populate normalized tables FROM staging (run in this order)

-- customers
INSERT IGNORE INTO customers (CustomerID, CustomerName, City, State, Country)
SELECT DISTINCT CustomerID, CustomerName, City, State, Country
FROM raw_staging;

-- sellers
INSERT IGNORE INTO sellers (SellerID)
SELECT DISTINCT SellerID FROM raw_staging;

-- products  (UnitPrice is the modal price for that product)
INSERT IGNORE INTO products (ProductID, ProductName, Category, Brand, UnitPrice)
SELECT DISTINCT ProductID, ProductName, Category, Brand, UnitPrice
FROM raw_staging;

-- orders
INSERT IGNORE INTO orders (OrderID, OrderDate, CustomerID, SellerID, PaymentMethod, OrderStatus)
SELECT DISTINCT
    OrderID,
    STR_TO_DATE(OrderDate, '%Y-%m-%d'),
    CustomerID,
    SellerID,
    PaymentMethod,
    OrderStatus
FROM raw_staging;

-- order_items
INSERT INTO order_items (OrderID, ProductID, Quantity, UnitPrice, Discount, Tax, ShippingCost, TotalAmount)
SELECT OrderID, ProductID, Quantity, UnitPrice, Discount, Tax, ShippingCost, TotalAmount
FROM raw_staging;

-- STEP D: Verify row counts
SELECT 'customers'   AS tbl, COUNT(*) AS rows FROM customers
UNION ALL
SELECT 'sellers',    COUNT(*) FROM sellers
UNION ALL
SELECT 'products',   COUNT(*) FROM products
UNION ALL
SELECT 'orders',     COUNT(*) FROM orders
UNION ALL
SELECT 'order_items',COUNT(*) FROM order_items;

-- STEP E: Clean up staging table (optional, run after verifying counts)
-- DROP TABLE raw_staging;


-- ============================================================
--  INDEXES — add after loading for faster query performance
-- ============================================================
CREATE INDEX idx_orders_date       ON orders(OrderDate);
CREATE INDEX idx_orders_status     ON orders(OrderStatus);
CREATE INDEX idx_orders_customer   ON orders(CustomerID);
CREATE INDEX idx_items_product     ON order_items(ProductID);
CREATE INDEX idx_products_category ON products(Category);
