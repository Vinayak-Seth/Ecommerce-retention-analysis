-- 03_cohort_retention.sql
-- Cohort = month of a customer's first order.
-- For each cohort: what % of customers ordered again N months later?
WITH activity AS (
    SELECT DISTINCT
        c.cohort_month,
        f.customer_id,
        (CAST(strftime('%Y', f.purchase_date) AS INTEGER) * 12 + CAST(strftime('%m', f.purchase_date) AS INTEGER))
      - (CAST(substr(c.cohort_month, 1, 4) AS INTEGER) * 12 + CAST(substr(c.cohort_month, 6, 2) AS INTEGER))
            AS months_since_first
    FROM order_facts f
    JOIN customer_facts c ON c.customer_id = f.customer_id
    WHERE c.cohort_month BETWEEN '2017-01' AND '2018-08'
),
cohort_size AS (
    SELECT cohort_month, COUNT(*) AS cohort_customers
    FROM customer_facts
    WHERE cohort_month BETWEEN '2017-01' AND '2018-08'
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    s.cohort_customers,
    a.months_since_first,
    COUNT(DISTINCT a.customer_id)                                   AS active_customers,
    ROUND(100.0 * COUNT(DISTINCT a.customer_id) / s.cohort_customers, 2) AS retention_pct
FROM activity a
JOIN cohort_size s ON s.cohort_month = a.cohort_month
WHERE a.months_since_first BETWEEN 0 AND 12
GROUP BY a.cohort_month, s.cohort_customers, a.months_since_first
ORDER BY a.cohort_month, a.months_since_first;
