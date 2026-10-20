-- 09_category_performance.sql
-- Revenue, satisfaction and lateness by product category (top 15 by revenue).
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT oi.order_id)                                 AS orders,
    ROUND(SUM(oi.price), 0)                                     AS product_revenue,
    ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 1) AS pct_revenue,
    ROUND(AVG(oi.price), 2)                                     AS avg_item_price,
    ROUND(100.0 * AVG(f.is_late), 1)                            AS late_pct,
    ROUND(AVG(f.review_score), 2)                               AS avg_review
FROM order_items oi
JOIN order_facts f        ON f.order_id = oi.order_id
LEFT JOIN products p      ON p.product_id = oi.product_id
LEFT JOIN category_translation t ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY product_revenue DESC
LIMIT 15;
