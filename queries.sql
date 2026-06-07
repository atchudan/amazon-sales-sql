-- ============================================================
--  Amazon Sales Analytics — Business Queries
--  Database: amazon_sales
--  Tool: MySQL Workbench
--  Author: [Your Name]
-- ============================================================

USE amazon_sales;

-- ============================================================
-- 🔰 LEVEL 1 — BASIC
-- ============================================================

-- Q1. What is the total revenue by category?
SELECT 
    p.Category,
    ROUND(SUM(oi.TotalAmount), 2) AS total_revenue
FROM order_items oi
JOIN products p ON oi.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY total_revenue DESC;


-- Q2. What are the top 10 best selling products by quantity?
SELECT 
    p.ProductName,
    p.Category,
    SUM(oi.Quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName, p.Category
ORDER BY total_units_sold DESC
LIMIT 10;


-- Q3. How many orders and how much revenue came from each country?
SELECT 
    c.Country,
    COUNT(DISTINCT o.OrderID)     AS total_orders,
    ROUND(SUM(oi.TotalAmount), 2) AS total_revenue
FROM orders o
JOIN customers c   ON o.CustomerID  = c.CustomerID
JOIN order_items oi ON o.OrderID    = oi.OrderID
GROUP BY c.Country
ORDER BY total_revenue DESC;


-- Q4. What is the monthly revenue trend from 2020 to 2024?
SELECT 
    YEAR(o.OrderDate)             AS yr,
    MONTH(o.OrderDate)            AS mo,
    ROUND(SUM(oi.TotalAmount), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.OrderID = oi.OrderID
GROUP BY yr, mo
ORDER BY yr, mo;


-- ============================================================
-- 🔶 LEVEL 2 — INTERMEDIATE
-- ============================================================

-- Q5. Which payment method generates the highest revenue?
SELECT 
    o.PaymentMethod,
    COUNT(DISTINCT o.OrderID)     AS total_orders,
    ROUND(SUM(oi.TotalAmount), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.OrderID = oi.OrderID
GROUP BY o.PaymentMethod
ORDER BY total_revenue DESC;


-- Q6. What is the revenue and order count by order status?
SELECT 
    o.OrderStatus,
    COUNT(DISTINCT o.OrderID)     AS total_orders,
    ROUND(SUM(oi.TotalAmount), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.OrderID = oi.OrderID
GROUP BY o.OrderStatus
ORDER BY total_orders DESC;


-- Q7. Which categories have an average discount greater than 15%?
SELECT 
    p.Category,
    ROUND(AVG(oi.Discount), 2) AS avg_discount
FROM order_items oi
JOIN products p ON oi.ProductID = p.ProductID
GROUP BY p.Category
HAVING avg_discount > 15
ORDER BY avg_discount DESC;


-- Q8. Who are the top 5 sellers by total revenue?
SELECT 
    o.SellerID,
    COUNT(DISTINCT o.OrderID)     AS total_orders,
    ROUND(SUM(oi.TotalAmount), 2) AS total_revenue
FROM orders o
JOIN order_items oi ON o.OrderID = oi.OrderID
GROUP BY o.SellerID
ORDER BY total_revenue DESC
LIMIT 5;


-- Q9. Which customers have placed more than 5 orders? (Repeat buyers)
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Country,
    COUNT(DISTINCT o.OrderID) AS total_orders
FROM customers c
JOIN orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.CustomerName, c.Country
HAVING total_orders > 5
ORDER BY total_orders DESC;


-- Q10. What is the return rate (%) by category?
SELECT 
    p.Category,
    COUNT(DISTINCT o.OrderID)                                         AS total_orders,
    COUNT(DISTINCT CASE WHEN o.OrderStatus = 'Returned' 
                        THEN o.OrderID END)                           AS returned_orders,
    ROUND(COUNT(DISTINCT CASE WHEN o.OrderStatus = 'Returned'
                              THEN o.OrderID END) * 100.0
          / COUNT(DISTINCT o.OrderID), 2)                             AS return_rate_pct
FROM orders o
JOIN order_items oi ON o.OrderID    = oi.OrderID
JOIN products p     ON oi.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY return_rate_pct DESC;


-- ============================================================
-- 🔴 LEVEL 3 — ADVANCED (Window Functions & CTEs)
-- ============================================================

-- Q11. Rank customers by total spend using RANK()
SELECT 
    c.CustomerName,
    c.Country,
    ROUND(SUM(oi.TotalAmount), 2)                        AS total_spend,
    RANK() OVER (ORDER BY SUM(oi.TotalAmount) DESC)      AS spend_rank
FROM customers c
JOIN orders o       ON c.CustomerID  = o.CustomerID
JOIN order_items oi ON o.OrderID     = oi.OrderID
GROUP BY c.CustomerID, c.CustomerName, c.Country
ORDER BY spend_rank;


-- Q12. Month over month revenue growth using LAG()
WITH monthly AS (
    SELECT 
        YEAR(o.OrderDate)             AS yr,
        MONTH(o.OrderDate)            AS mo,
        ROUND(SUM(oi.TotalAmount), 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.OrderID = oi.OrderID
    GROUP BY yr, mo
)
SELECT 
    yr,
    mo,
    monthly_revenue,
    LAG(monthly_revenue) OVER (ORDER BY yr, mo)             AS prev_month_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue)
          OVER (ORDER BY yr, mo), 2)                        AS revenue_change,
    ROUND((monthly_revenue - LAG(monthly_revenue)
          OVER (ORDER BY yr, mo)) * 100.0
          / LAG(monthly_revenue) OVER (ORDER BY yr, mo), 2) AS growth_pct
FROM monthly
ORDER BY yr, mo;


-- Q13. Running total of revenue over time using SUM() OVER
WITH monthly AS (
    SELECT 
        YEAR(o.OrderDate)             AS yr,
        MONTH(o.OrderDate)            AS mo,
        ROUND(SUM(oi.TotalAmount), 2) AS monthly_revenue
    FROM orders o
    JOIN order_items oi ON o.OrderID = oi.OrderID
    GROUP BY yr, mo
)
SELECT 
    yr,
    mo,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (ORDER BY yr, mo), 2) AS running_total
FROM monthly
ORDER BY yr, mo;


-- Q14. Best selling product per country using PARTITION BY
WITH product_sales AS (
    SELECT 
        c.Country,
        p.ProductName,
        SUM(oi.Quantity)                                          AS total_units,
        RANK() OVER (PARTITION BY c.Country
                     ORDER BY SUM(oi.Quantity) DESC)              AS rnk
    FROM customers c
    JOIN orders o       ON c.CustomerID  = o.CustomerID
    JOIN order_items oi ON o.OrderID     = oi.OrderID
    JOIN products p     ON oi.ProductID  = p.ProductID
    GROUP BY c.Country, p.ProductID, p.ProductName
)
SELECT Country, ProductName, total_units
FROM product_sales
WHERE rnk = 1
ORDER BY Country;


-- Q15. Products with above average revenue in their category
WITH category_avg AS (
    SELECT 
        p.Category,
        p.ProductID,
        p.ProductName,
        ROUND(SUM(oi.TotalAmount), 2)                     AS product_revenue,
        ROUND(AVG(SUM(oi.TotalAmount))
              OVER (PARTITION BY p.Category), 2)           AS category_avg_revenue
    FROM order_items oi
    JOIN products p ON oi.ProductID = p.ProductID
    GROUP BY p.Category, p.ProductID, p.ProductName
)
SELECT 
    Category,
    ProductName,
    product_revenue,
    category_avg_revenue,
    ROUND(product_revenue - category_avg_revenue, 2) AS above_avg_by
FROM category_avg
WHERE product_revenue > category_avg_revenue
ORDER BY Category, above_avg_by DESC;
