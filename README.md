# Amazon Sales Analytics — SQL Project

A complete end-to-end SQL project analyzing 1,00,000+ Amazon sales transactions across 5 countries, 6 product categories, and 5 years (2020–2024). Built entirely in MySQL Workbench.

---

## 🗂️ Project Structure

```
amazon-sales-sql/
├── schema.sql        # Database creation, normalization, CSV import logic
├── queries.sql       # All 15 business queries (3 difficulty levels)
├── screenshots/      # Query result screenshots
└── README.md
```

---

## 🗃️ Database Schema

The raw flat CSV was normalized into **5 relational tables (3NF)**:

```
customers     → CustomerID (PK), CustomerName, City, State, Country
sellers       → SellerID (PK)
products      → ProductID (PK), ProductName, Category, Brand, UnitPrice
orders        → OrderID (PK), OrderDate, CustomerID (FK), SellerID (FK), PaymentMethod, OrderStatus
order_items   → ItemID (PK), OrderID (FK), ProductID (FK), Quantity, UnitPrice, Discount, Tax, ShippingCost, TotalAmount
```

### Relationships
- One **customer** places many **orders**
- One **seller** fulfills many **orders**
- One **order** contains one **order_items** record
- One **product** appears in many **order_items**

---

## 📊 Business Questions Answered

### 🔰 Level 1 — Basic
| # | Business Question | Concepts Used |
|---|---|---|
| Q1 | What is the total revenue by category? | JOIN, SUM, GROUP BY |
| Q2 | What are the top 10 best selling products by quantity? | JOIN, SUM, LIMIT |
| Q3 | How many orders and revenue came from each country? | Multi-table JOIN, COUNT DISTINCT |
| Q4 | What is the monthly revenue trend (2020–2024)? | YEAR(), MONTH(), GROUP BY |

### 🔶 Level 2 — Intermediate
| # | Business Question | Concepts Used |
|---|---|---|
| Q5 | Which payment method generates the highest revenue? | GROUP BY, ORDER BY |
| Q6 | What is the revenue breakdown by order status? | COUNT DISTINCT, SUM |
| Q7 | Which categories have average discount > 15%? | AVG, HAVING |
| Q8 | Who are the top 5 sellers by revenue? | GROUP BY, LIMIT |
| Q9 | Which customers placed more than 5 orders? | HAVING, COUNT DISTINCT |
| Q10 | What is the return rate (%) by category? | CASE WHEN, conditional aggregation |

### 🔴 Level 3 — Advanced
| # | Business Question | Concepts Used |
|---|---|---|
| Q11 | Rank customers by total lifetime spend | RANK(), Window Function |
| Q12 | What is the month-over-month revenue growth? | CTE, LAG() |
| Q13 | What is the running total of revenue over time? | CTE, SUM() OVER |
| Q14 | What is the best selling product per country? | PARTITION BY, RANK() |
| Q15 | Which products beat their category average revenue? | CTE, AVG() OVER, PARTITION BY |

---

## 🔍 Key Findings

- **Electronics** is the highest revenue-generating category
- **India** and **United States** account for the majority of orders
- **UPI and Credit Card** are the most popular payment methods
- Return rates are highest in **Clothing** and **Electronics**
- Revenue shows consistent **year-over-year growth** from 2020 to 2024

---

## ⚙️ How to Run This Project

### Prerequisites
- MySQL Server 8.0+
- MySQL Workbench

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/amazon-sales-sql.git
   ```

2. **Download the dataset**  
   Place the CSV file in your MySQL secure upload directory:
   ```sql
   SHOW VARIABLES LIKE 'secure_file_priv';
   ```

3. **Run the schema file**  
   Open `schema.sql` in MySQL Workbench and run it top to bottom.  
   This will create the database, tables, load the CSV, and add indexes.

4. **Run the queries**  
   Open `queries.sql` and run any query individually or all at once.

---

## 🛠️ Technical Highlights

- Normalized flat CSV (1,00,000 rows) into 5 tables following **3NF principles**
- Implemented **foreign key constraints** to enforce referential integrity
- Added **5 indexes** on frequently queried columns for performance optimization
- Used `INSERT IGNORE` with `DISTINCT` for safe, duplicate-free data loading
- Advanced SQL: **CTEs, Window Functions, LAG(), RANK(), PARTITION BY**

---

## 📁 Dataset

- **Source:** Amazon Sales Dataset (synthetic)
- **Rows:** 1,00,000 orders
- **Period:** January 2020 – December 2024
- **Countries:** India, United States, Canada, Australia, United Kingdom
- **Categories:** Electronics, Clothing, Books, Toys & Games, Sports & Outdoors, Home & Kitchen

---

## 👤 Author

Atchudan
https://www.linkedin.com/in/atchudan-sreeram-609b46169/  
https://github.com/atchudan
