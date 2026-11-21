-- =========================================
-- FILE: 05_analysis_queries.sql
-- PURPOSE: Business performance analysis
-- =========================================

USE sales_intelligence;

-- 1. Total Revenue
SELECT SUM(net_revenue) AS total_revenue
FROM vw_sales_detail;

-- 2. Total Profit
SELECT SUM(gross_profit) AS total_profit
FROM vw_sales_detail;

-- 3. Monthly Revenue
SELECT sales_period, SUM(net_revenue) AS revenue
FROM vw_sales_detail
GROUP BY sales_period
ORDER BY sales_period;

-- 4. Revenue by Category
SELECT category, SUM(net_revenue) AS revenue
FROM vw_sales_detail
GROUP BY category
ORDER BY revenue DESC;

-- 5. Revenue by Region
SELECT region_name, SUM(net_revenue) AS revenue
FROM vw_sales_detail
GROUP BY region_name
ORDER BY revenue DESC;

-- 6. Revenue by Sales Channel
SELECT sales_channel, SUM(net_revenue) AS revenue
FROM vw_sales_detail
GROUP BY sales_channel
ORDER BY revenue DESC;

-- 7. Top 10 Customers
SELECT customer_name, SUM(net_revenue) AS revenue
FROM vw_sales_detail
GROUP BY customer_name
ORDER BY revenue DESC
LIMIT 10;

-- 8. Profit by Category
SELECT category, SUM(gross_profit) AS profit
FROM vw_sales_detail
GROUP BY category
ORDER BY profit DESC;

-- 9. Average Order Value
SELECT
    SUM(net_revenue) / COUNT(DISTINCT order_id) AS average_order_value
FROM vw_sales_detail;

-- 10. Overall Profit Margin
SELECT
    ROUND(
        SUM(gross_profit) / NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin_percentage
FROM vw_sales_detail;