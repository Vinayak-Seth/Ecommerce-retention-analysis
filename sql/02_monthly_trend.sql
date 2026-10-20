-- 02_monthly_trend.sql
-- Monthly orders, revenue, AOV and new-vs-returning split.
-- 2016 and Sep-Oct 2018 are excluded: those months are incomplete in the dataset.
SELECT
    purchase_month,
    COUNT(*)                                        AS orders,
    ROUND(SUM(order_value), 0)                      AS revenue,
    ROUND(AVG(order_value), 2)                      AS avg_order_value,
    SUM(CASE WHEN order_seq = 1 THEN 1 ELSE 0 END)  AS first_time_orders,
    SUM(CASE WHEN order_seq > 1 THEN 1 ELSE 0 END)  AS repeat_orders,
    ROUND(100.0 * AVG(is_late), 1)                  AS late_pct,
    ROUND(AVG(review_score), 2)                     AS avg_review
FROM order_facts
WHERE purchase_month BETWEEN '2017-01' AND '2018-08'
GROUP BY purchase_month
ORDER BY purchase_month;
