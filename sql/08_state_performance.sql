-- 08_state_performance.sql
-- Revenue and delivery performance by customer state (top 15 by revenue).
SELECT
    state,
    COUNT(*)                                                 AS orders,
    ROUND(SUM(order_value), 0)                               AS revenue,
    ROUND(100.0 * SUM(order_value) / (SELECT SUM(order_value) FROM order_facts), 1) AS pct_revenue,
    ROUND(AVG(delivery_days), 1)                             AS avg_delivery_days,
    ROUND(100.0 * AVG(is_late), 1)                           AS late_pct,
    ROUND(AVG(review_score), 2)                              AS avg_review,
    SUM(is_late)                                             AS late_orders
FROM order_facts
GROUP BY state
ORDER BY revenue DESC
LIMIT 15;
