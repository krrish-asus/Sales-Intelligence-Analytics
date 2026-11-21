
USE sales_intelligence;

-- 1. Executive KPI Dashboard
SELECT
    ROUND(SUM(net_revenue),2) AS total_revenue,
    ROUND(SUM(gross_profit),2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(gross_profit)/SUM(net_revenue)*100,2) AS profit_margin
FROM vw_sales_detail;

-- 2. Monthly Sales Growth
SELECT
    sales_period,
    ROUND(SUM(net_revenue),2) AS revenue,
    ROUND(SUM(gross_profit),2) AS profit
FROM vw_sales_detail
GROUP BY sales_period
ORDER BY sales_period;

-- 3. Top 10 Products by Revenue
SELECT
    product_name,
    category,
    ROUND(SUM(net_revenue),2) AS revenue
FROM vw_sales_detail
GROUP BY product_id, product_name, category
ORDER BY revenue DESC
LIMIT 10;

-- 4. Category Profitability
SELECT
    category,
    SUM(net_revenue) AS revenue,
    SUM(gross_profit) AS profit,
    ROUND(SUM(gross_profit)/NULLIF(SUM(net_revenue),0)*100,2) AS margin
FROM vw_sales_detail
GROUP BY category
ORDER BY profit DESC;

-- 5. Regional Sales Analysis
SELECT
    region_name,
    SUM(net_revenue) AS revenue,
    SUM(gross_profit) AS profit
FROM vw_sales_detail
GROUP BY region_name
ORDER BY revenue DESC;


USE sales_intelligence;

-- 6. Customer Segment Performance
SELECT
    segment,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(net_revenue),2) AS revenue
FROM vw_sales_detail
GROUP BY segment
ORDER BY revenue DESC;

-- 7. Top 20 High-Value Customers
SELECT
    customer_id,
    customer_name,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(net_revenue),2) AS lifetime_value
FROM vw_sales_detail
GROUP BY customer_id, customer_name
ORDER BY lifetime_value DESC
LIMIT 20;

-- 8. Month-over-Month Revenue Growth (LAG)
WITH monthly AS (
    SELECT sales_period, SUM(net_revenue) AS revenue
    FROM vw_sales_detail
    GROUP BY sales_period
),
growth AS (
    SELECT sales_period, revenue,
        LAG(revenue) OVER (ORDER BY sales_period) AS previous_revenue
    FROM monthly
)
SELECT sales_period, revenue, previous_revenue,
    ROUND(
        (revenue - previous_revenue) /
        NULLIF(previous_revenue,0) * 100, 2
    ) AS growth_percentage
FROM growth
ORDER BY sales_period;

-- 9. Product Ranking by Category
WITH product_sales AS (
    SELECT category, product_id, product_name,
        SUM(net_revenue) AS revenue
    FROM vw_sales_detail
    GROUP BY category, product_id, product_name
)
SELECT category, product_name, revenue,
    DENSE_RANK() OVER (
        PARTITION BY category ORDER BY revenue DESC
    ) AS product_rank
FROM product_sales
ORDER BY category, product_rank;

-- 10. Running Cumulative Revenue
WITH daily_sales AS (
    SELECT order_date, SUM(net_revenue) AS revenue
    FROM vw_sales_detail
    GROUP BY order_date
)
SELECT order_date, revenue,
    SUM(revenue) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_revenue
FROM daily_sales
ORDER BY order_date;

-- 11. Repeat Customer Analysis
SELECT COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM vw_sales_detail
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) > 1
) AS repeat_list;

-- 12. New vs Returning Customer Revenue
WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order
    FROM vw_sales_detail
    GROUP BY customer_id
)
SELECT
    s.sales_period,
    ROUND(SUM(
        CASE WHEN DATE_FORMAT(f.first_order,'%Y-%m') = s.sales_period
        THEN s.net_revenue ELSE 0 END
    ),2) AS new_customer_revenue,
    ROUND(SUM(
        CASE WHEN DATE_FORMAT(f.first_order,'%Y-%m') < s.sales_period
        THEN s.net_revenue ELSE 0 END
    ),2) AS returning_customer_revenue
FROM vw_sales_detail s
JOIN first_orders f ON s.customer_id = f.customer_id
GROUP BY s.sales_period
ORDER BY s.sales_period;

-- 13. Sales Channel Analysis
SELECT
    sales_channel,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(net_revenue),2) AS revenue,
    ROUND(SUM(gross_profit),2) AS profit
FROM vw_sales_detail
GROUP BY sales_channel
ORDER BY revenue DESC;

-- 14. Average Order Value
SELECT
    ROUND(
        SUM(net_revenue) /
        NULLIF(COUNT(DISTINCT order_id),0), 2
    ) AS average_order_value
FROM vw_sales_detail;

-- 15. High Discount Orders
SELECT
    order_id,
    ROUND(AVG(discount_pct)*100,2) AS average_discount,
    ROUND(SUM(net_revenue),2) AS revenue
FROM vw_sales_detail
GROUP BY order_id
HAVING AVG(discount_pct) >= 0.15
ORDER BY average_discount DESC;

-- 16. Quarterly Sales Performance
SELECT
    YEAR(order_date) AS sales_year,
    QUARTER(order_date) AS sales_quarter,
    ROUND(SUM(net_revenue),2) AS revenue,
    ROUND(SUM(gross_profit),2) AS profit
FROM vw_sales_detail
GROUP BY YEAR(order_date), QUARTER(order_date)
ORDER BY sales_year, sales_quarter;

-- 17. Customer RFM Analysis
SELECT
    customer_id,
    customer_name,
    DATEDIFF(CURDATE(),MAX(order_date)) AS recency_days,
    COUNT(DISTINCT order_id) AS frequency,
    ROUND(SUM(net_revenue),2) AS monetary_value
FROM vw_sales_detail
GROUP BY customer_id, customer_name
ORDER BY monetary_value DESC;

-- 18. Product Profitability Ranking (Lowest Margin First)
SELECT
    product_id,
    product_name,
    COUNT(*) AS order_lines,
    ROUND(SUM(net_revenue), 2) AS revenue,
    ROUND(
        SUM(gross_profit) /
        NULLIF(SUM(net_revenue), 0) * 100,
        2
    ) AS profit_margin
FROM vw_sales_detail
GROUP BY product_id, product_name
HAVING COUNT(*) >= 5
ORDER BY profit_margin ASC;

-- 19. Best Performing Month in Each Region
WITH regional_monthly AS (
    SELECT region_name, sales_period,
        SUM(net_revenue) AS revenue
    FROM vw_sales_detail
    GROUP BY region_name, sales_period
),
ranked AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY region_name
            ORDER BY revenue DESC
        ) AS ranking
    FROM regional_monthly
)
SELECT region_name, sales_period, ROUND(revenue,2) AS revenue
FROM ranked
WHERE ranking = 1
ORDER BY region_name;

-- 20. Data Quality Checks
SELECT
    'Orders without items' AS check_name,
    COUNT(*) AS issue_count
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL

UNION ALL

SELECT
    'Products with cost above selling price',
    COUNT(*)
FROM products
WHERE unit_cost > unit_price;
