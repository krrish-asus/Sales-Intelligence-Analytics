USE sales_intelligence;

DROP PROCEDURE IF EXISTS sp_sales_summary;

DELIMITER //

CREATE PROCEDURE sp_sales_summary(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT
        SUM(net_revenue) AS revenue,
        SUM(gross_profit) AS profit,
        COUNT(DISTINCT order_id) AS orders,
        ROUND(
            SUM(gross_profit) /
            NULLIF(SUM(net_revenue), 0) * 100,
            2
        ) AS margin_pct
    FROM vw_sales_detail
    WHERE order_date BETWEEN p_start_date AND p_end_date;
END //

DELIMITER ;

-- Example:
-- CALL sp_sales_summary('2025-01-01', '2025-12-31');
