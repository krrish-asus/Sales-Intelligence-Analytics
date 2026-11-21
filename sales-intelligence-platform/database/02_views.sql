USE sales_intelligence;

CREATE OR REPLACE VIEW vw_sales_detail AS
SELECT
  o.order_id, o.order_date, YEAR(o.order_date) AS sales_year,
  MONTH(o.order_date) AS sales_month, DATE_FORMAT(o.order_date,'%Y-%m') AS year_month,
  o.status, o.sales_channel, c.customer_id, c.customer_name, c.segment,
  r.region_name, r.city, p.product_id, p.product_name, p.category,
  oi.quantity, oi.unit_price, oi.discount_pct,
  ROUND(oi.quantity * oi.unit_price * (1-oi.discount_pct),2) AS net_revenue,
  ROUND(oi.quantity * p.unit_cost,2) AS total_cost,
  ROUND((oi.quantity * oi.unit_price * (1-oi.discount_pct))-(oi.quantity*p.unit_cost),2) AS gross_profit
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
JOIN regions r ON c.region_id=r.region_id
JOIN order_items oi ON o.order_id=oi.order_id
JOIN products p ON oi.product_id=p.product_id
WHERE o.status NOT IN ('Cancelled','Returned');

CREATE OR REPLACE VIEW vw_monthly_performance AS
SELECT year_month, SUM(net_revenue) revenue, SUM(gross_profit) profit,
       COUNT(DISTINCT order_id) orders, COUNT(DISTINCT customer_id) customers,
       ROUND(SUM(gross_profit)/NULLIF(SUM(net_revenue),0)*100,2) profit_margin_pct
FROM vw_sales_detail
GROUP BY year_month;
