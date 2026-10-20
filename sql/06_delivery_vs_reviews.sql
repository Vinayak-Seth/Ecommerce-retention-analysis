-- 06_delivery_vs_reviews.sql
-- How does delivery timing (vs the date promised to the customer) affect review score?
SELECT
    CASE
        WHEN delay_days <= -14 THEN '1. 14+ days early'
        WHEN delay_days <= -7  THEN '2. 7-13 days early'
        WHEN delay_days <= 0   THEN '3. 0-6 days early / on time'
        WHEN delay_days <= 3   THEN '4. 1-3 days late'
        WHEN delay_days <= 7   THEN '5. 4-7 days late'
        WHEN delay_days <= 14  THEN '6. 8-14 days late'
        ELSE                        '7. 15+ days late'
    END                                                         AS delivery_bucket,
    COUNT(*)                                                    AS orders,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_orders,
    ROUND(AVG(review_score), 2)                                 AS avg_review,
    ROUND(100.0 * AVG(CASE WHEN review_score <= 2 THEN 1.0 ELSE 0 END), 1) AS pct_1_2_star
FROM order_facts
WHERE review_score IS NOT NULL
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
