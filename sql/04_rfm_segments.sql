-- 04_rfm_segments.sql
-- RFM segmentation. Recency and Monetary are scored 1-4 with NTILE.
-- Frequency is NOT scored with NTILE: almost every customer has 1 order,
-- so quartiles would be meaningless. We use 1 order vs 2+ orders instead.
WITH scored AS (
    SELECT
        customer_id, state, n_orders, total_value, recency_days,
        5 - NTILE(4) OVER (ORDER BY recency_days)  AS r_score,   -- 4 = bought most recently
        NTILE(4) OVER (ORDER BY total_value)       AS m_score    -- 4 = spent the most
    FROM customer_facts
)
SELECT
    customer_id, state, n_orders, total_value, recency_days, r_score, m_score,
    CASE
        WHEN n_orders >= 2 AND m_score >= 3 THEN '1. Loyal high-value'
        WHEN n_orders >= 2                  THEN '2. Loyal'
        WHEN r_score >= 3 AND m_score >= 3  THEN '3. New high-value (win 2nd order)'
        WHEN r_score >= 3                   THEN '4. New low-value'
        WHEN m_score >= 3                   THEN '5. Lapsed high-value'
        ELSE                                     '6. Lapsed low-value'
    END AS segment
FROM scored;
