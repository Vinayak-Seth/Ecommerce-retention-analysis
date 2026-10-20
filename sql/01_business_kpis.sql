-- 01_business_kpis.sql
-- Headline numbers for the executive page and the first line of the memo.
SELECT
    COUNT(*)                                             AS delivered_orders,
    COUNT(DISTINCT customer_id)                          AS customers,
    ROUND(SUM(order_value), 0)                           AS total_revenue,
    ROUND(AVG(order_value), 2)                           AS avg_order_value,
    ROUND(100.0 * AVG(is_late), 1)                       AS late_delivery_pct,
    ROUND(AVG(delivery_days), 1)                         AS avg_delivery_days,
    ROUND(AVG(review_score), 2)                          AS avg_review_score,
    ROUND(100.0 * (SELECT AVG(is_repeat) FROM customer_facts), 2) AS repeat_customer_pct,
    ROUND(100.0 * (SELECT SUM(total_value) FROM customer_facts WHERE is_repeat = 1)
                / SUM(order_value), 1)                   AS revenue_from_repeat_customers_pct
FROM order_facts;
