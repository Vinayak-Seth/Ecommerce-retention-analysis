-- 12_retention_scenarios.sql
-- Sizing the BIG lever: getting one-time buyers to place a 2nd order.
-- Scenario: what if the repeat-customer rate rose by +1, +2 or +3 percentage points?
-- Extra revenue = customers x extra repeat rate x avg revenue a repeater brings after order 1.
WITH base AS (
    SELECT COUNT(*) AS customers, AVG(is_repeat) AS repeat_rate FROM customer_facts
),
repeat_value AS (
    SELECT AVG(v) AS avg_repeat_revenue_per_repeater
    FROM (SELECT customer_id, SUM(order_value) AS v
          FROM order_facts WHERE order_seq > 1 GROUP BY customer_id)
),
scenarios(uplift_pp) AS (VALUES (1), (2), (3))
SELECT
    s.uplift_pp                                                   AS repeat_rate_uplift_pp,
    ROUND(100.0 * b.repeat_rate, 2)                               AS current_repeat_rate_pct,
    ROUND(100.0 * b.repeat_rate + s.uplift_pp, 2)                 AS new_repeat_rate_pct,
    ROUND(b.customers * s.uplift_pp / 100.0, 0)                   AS extra_repeat_customers,
    ROUND(b.customers * s.uplift_pp / 100.0 * v.avg_repeat_revenue_per_repeater, 0) AS extra_revenue,
    ROUND(100.0 * b.customers * s.uplift_pp / 100.0 * v.avg_repeat_revenue_per_repeater
          / (SELECT SUM(order_value) FROM order_facts), 1)        AS extra_revenue_pct_of_total
FROM scenarios s CROSS JOIN base b CROSS JOIN repeat_value v
ORDER BY s.uplift_pp;
