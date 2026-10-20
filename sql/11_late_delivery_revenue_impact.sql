-- 11_late_delivery_revenue_impact.sql
-- Hypothesis test: is late delivery a big driver of lost repeat revenue?
-- If customers whose first order was LATE came back at the same rate as
-- customers whose first order was ON TIME, how much extra revenue would we get?
-- Uses the same 6-month eligibility window as query 07.
WITH eligible AS (
    SELECT *
    FROM customer_facts
    WHERE first_purchase_date <= DATE((SELECT MAX(purchase_date) FROM order_facts), '-6 months')
),
rates AS (
    SELECT
        AVG(CASE WHEN first_order_late = 0 THEN is_repeat END) AS ontime_repeat_rate,
        AVG(CASE WHEN first_order_late = 1 THEN is_repeat END) AS late_repeat_rate,
        SUM(CASE WHEN first_order_late = 1 THEN 1 ELSE 0 END)  AS late_first_customers
    FROM eligible
),
repeat_value AS (   -- average value of all orders after the first, per repeat customer
    SELECT AVG(v) AS avg_repeat_revenue_per_repeater
    FROM (SELECT customer_id, SUM(order_value) AS v
          FROM order_facts WHERE order_seq > 1 GROUP BY customer_id)
)
SELECT
    r.late_first_customers,
    ROUND(100.0 * r.ontime_repeat_rate, 2)                       AS ontime_repeat_rate_pct,
    ROUND(100.0 * r.late_repeat_rate, 2)                         AS late_repeat_rate_pct,
    ROUND(r.late_first_customers * (r.ontime_repeat_rate - r.late_repeat_rate), 0) AS lost_repeat_customers,
    ROUND(v.avg_repeat_revenue_per_repeater, 2)                  AS avg_repeat_revenue_per_repeater,
    ROUND(r.late_first_customers * (r.ontime_repeat_rate - r.late_repeat_rate)
          * v.avg_repeat_revenue_per_repeater, 0)                AS estimated_lost_revenue
FROM rates r CROSS JOIN repeat_value v;
