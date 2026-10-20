-- 05_segment_summary.sql
-- Size and value of each RFM segment (same logic as 04_rfm_segments.sql).
WITH scored AS (
    SELECT customer_id, n_orders, total_value, recency_days,
           5 - NTILE(4) OVER (ORDER BY recency_days) AS r_score,
           NTILE(4) OVER (ORDER BY total_value)      AS m_score
    FROM customer_facts
),
seg AS (
    SELECT *,
        CASE
            WHEN n_orders >= 2 AND m_score >= 3 THEN '1. Loyal high-value'
            WHEN n_orders >= 2                  THEN '2. Loyal'
            WHEN r_score >= 3 AND m_score >= 3  THEN '3. New high-value (win 2nd order)'
            WHEN r_score >= 3                   THEN '4. New low-value'
            WHEN m_score >= 3                   THEN '5. Lapsed high-value'
            ELSE                                     '6. Lapsed low-value'
        END AS segment
    FROM scored
)
SELECT
    segment,
    COUNT(*)                                                      AS customers,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)            AS pct_customers,
    ROUND(SUM(total_value), 0)                                    AS revenue,
    ROUND(100.0 * SUM(total_value) / SUM(SUM(total_value)) OVER (), 1) AS pct_revenue,
    ROUND(AVG(total_value), 2)                                    AS avg_value_per_customer,
    ROUND(AVG(recency_days), 0)                                   AS avg_recency_days
FROM seg
GROUP BY segment
ORDER BY segment;
