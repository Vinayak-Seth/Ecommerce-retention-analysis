-- 10_seller_late_delivery.sql
-- Which sellers cause the most late deliveries? (sellers with 50+ delivered orders)
-- Shows whether lateness is spread out or concentrated in a few sellers.
WITH seller_orders AS (
    SELECT DISTINCT oi.seller_id, f.order_id, f.is_late, f.review_score
    FROM order_items oi
    JOIN order_facts f ON f.order_id = oi.order_id
)
SELECT
    so.seller_id,
    s.seller_state,
    COUNT(*)                          AS orders,
    SUM(so.is_late)                   AS late_orders,
    ROUND(100.0 * AVG(so.is_late), 1) AS late_pct,
    ROUND(AVG(so.review_score), 2)    AS avg_review,
    ROUND(100.0 * SUM(so.is_late) / SUM(SUM(so.is_late)) OVER (), 2) AS pct_of_all_late_orders
FROM seller_orders so
JOIN sellers s ON s.seller_id = so.seller_id
GROUP BY so.seller_id, s.seller_state
HAVING COUNT(*) >= 50
ORDER BY late_orders DESC;
