-- 07_first_order_experience_vs_repeat.sql
-- Does a bad FIRST order (late, or low review) make a customer less likely to come back?
-- Only customers whose first order was at least 6 months before the data ends,
-- so everyone had a fair chance to repeat.
WITH eligible AS (
    SELECT *
    FROM customer_facts
    WHERE first_purchase_date <= DATE((SELECT MAX(purchase_date) FROM order_facts), '-6 months')
)
SELECT 'First order on time' AS first_order_experience, COUNT(*) AS customers,
       ROUND(100.0 * AVG(is_repeat), 2) AS repeat_rate_pct
FROM eligible WHERE first_order_late = 0
UNION ALL
SELECT 'First order late', COUNT(*), ROUND(100.0 * AVG(is_repeat), 2)
FROM eligible WHERE first_order_late = 1
UNION ALL
SELECT 'First review 4-5 stars', COUNT(*), ROUND(100.0 * AVG(is_repeat), 2)
FROM eligible WHERE first_order_review >= 4
UNION ALL
SELECT 'First review 1-2 stars', COUNT(*), ROUND(100.0 * AVG(is_repeat), 2)
FROM eligible WHERE first_order_review <= 2;
