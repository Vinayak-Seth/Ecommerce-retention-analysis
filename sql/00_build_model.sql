-- 00_build_model.sql
-- Builds two clean tables that every other query uses.
--   order_facts    : one row per DELIVERED order
--   customer_facts : one row per real customer (customer_unique_id)
--
-- Why: Olist gives a new customer_id for every order. The real person is
-- customer_unique_id. Using customer_id would make repeat rate look like 0%.

DROP TABLE IF EXISTS order_facts;
CREATE TABLE order_facts AS
WITH items AS (
    SELECT order_id,
           COUNT(*)           AS n_items,
           SUM(price)         AS product_revenue,
           SUM(freight_value) AS freight
    FROM order_items
    GROUP BY order_id
),
reviews AS (               -- a few orders have more than one review
    SELECT order_id, AVG(review_score) AS review_score
    FROM order_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    c.customer_unique_id                                   AS customer_id,
    c.customer_state                                       AS state,
    c.customer_city                                        AS city,
    DATE(o.order_purchase_timestamp)                       AS purchase_date,
    strftime('%Y-%m', o.order_purchase_timestamp)          AS purchase_month,
    i.n_items,
    ROUND(i.product_revenue, 2)                            AS product_revenue,
    ROUND(i.freight, 2)                                    AS freight,
    ROUND(i.product_revenue + i.freight, 2)                AS order_value,
    ROUND(julianday(o.order_delivered_customer_date)
          - julianday(o.order_purchase_timestamp), 1)      AS delivery_days,
    CAST(julianday(DATE(o.order_delivered_customer_date))
         - julianday(DATE(o.order_estimated_delivery_date)) AS INTEGER) AS delay_days,  -- >0 = late
    CASE WHEN DATE(o.order_delivered_customer_date)
              > DATE(o.order_estimated_delivery_date) THEN 1 ELSE 0 END AS is_late,
    r.review_score,
    ROW_NUMBER() OVER (PARTITION BY c.customer_unique_id
                       ORDER BY o.order_purchase_timestamp)  AS order_seq   -- 1 = first order
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
JOIN items     i ON i.order_id    = o.order_id
LEFT JOIN reviews r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;


DROP TABLE IF EXISTS customer_facts;
CREATE TABLE customer_facts AS
WITH ref AS (SELECT MAX(purchase_date) AS ref_date FROM order_facts)
SELECT
    f.customer_id,
    MAX(CASE WHEN f.order_seq = 1 THEN f.state END)          AS state,
    MIN(f.purchase_date)                                     AS first_purchase_date,
    MAX(f.purchase_date)                                     AS last_purchase_date,
    strftime('%Y-%m', MIN(f.purchase_date))                  AS cohort_month,
    COUNT(*)                                                 AS n_orders,
    ROUND(SUM(f.order_value), 2)                             AS total_value,
    CAST(julianday((SELECT ref_date FROM ref))
         - julianday(MAX(f.purchase_date)) AS INTEGER)       AS recency_days,
    MAX(CASE WHEN f.order_seq = 1 THEN f.is_late END)        AS first_order_late,
    MAX(CASE WHEN f.order_seq = 1 THEN f.review_score END)   AS first_order_review,
    CASE WHEN COUNT(*) >= 2 THEN 1 ELSE 0 END                AS is_repeat
FROM order_facts f
GROUP BY f.customer_id;
