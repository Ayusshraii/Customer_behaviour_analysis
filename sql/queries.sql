-- Customer shopping behavior: SQL queries
-- Written for SQLite. On PostgreSQL / MySQL only small changes are needed (e.g. casting in ROUND).
-- The table is called customer and is created by analysis.py

-- Q1. Revenue by gender
SELECT gender, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY gender;

-- Q2. Customers who used a discount but still spent above the average purchase
SELECT customer_id, purchase_amount
FROM customer
WHERE discount_applied = 'Yes'
  AND purchase_amount >= (SELECT AVG(purchase_amount) FROM customer);

-- Q3. Top 5 products by average review rating
SELECT item_purchased, ROUND(AVG(review_rating), 2) AS avg_rating
FROM customer
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Q4. Average purchase amount: Standard vs Express shipping
SELECT shipping_type, ROUND(AVG(purchase_amount), 2) AS avg_purchase
FROM customer
WHERE shipping_type IN ('Standard', 'Express')
GROUP BY shipping_type;

-- Q5. Do subscribers spend more?
SELECT subscription_status,
       COUNT(customer_id) AS total_customers,
       ROUND(AVG(purchase_amount), 2) AS avg_spend,
       ROUND(SUM(purchase_amount), 2) AS total_revenue
FROM customer
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Q6. Top 5 products by share of purchases made with a discount
SELECT item_purchased,
       ROUND(100.0 * SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS discount_rate_pct
FROM customer
GROUP BY item_purchased
ORDER BY discount_rate_pct DESC
LIMIT 5;

-- Q7. Customer segments by previous purchases
WITH customer_type AS (
  SELECT customer_id,
         CASE WHEN previous_purchases = 1 THEN 'New'
              WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
              ELSE 'Loyal' END AS customer_segment
  FROM customer)
SELECT customer_segment, COUNT(*) AS num_customers
FROM customer_type
GROUP BY customer_segment;

-- Q8. Top 3 most purchased products within each category
WITH item_counts AS (
  SELECT category, item_purchased, COUNT(customer_id) AS total_orders,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY COUNT(customer_id) DESC) AS item_rank
  FROM customer
  GROUP BY category, item_purchased)
SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;

-- Q9. Are repeat buyers (>5 previous purchases) likely to subscribe?
SELECT subscription_status, COUNT(customer_id) AS repeat_buyers
FROM customer
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- Q10. Revenue contribution by age group
SELECT age_group, SUM(purchase_amount) AS total_revenue,
       ROUND(100.0 * SUM(purchase_amount) / (SELECT SUM(purchase_amount) FROM customer), 1) AS pct_of_revenue
FROM customer
GROUP BY age_group
ORDER BY total_revenue DESC;


-- ---- Extra queries I added ----

-- E1. Top 10 states by revenue and average order value
SELECT location, COUNT(*) AS orders, SUM(purchase_amount) AS revenue, ROUND(AVG(purchase_amount), 2) AS avg_order_value
FROM customer
GROUP BY location
ORDER BY revenue DESC
LIMIT 10;

-- E2. Does a discount change spend? Revenue and average spend by discount usage
SELECT discount_applied, COUNT(*) AS orders, ROUND(AVG(purchase_amount), 2) AS avg_spend, SUM(purchase_amount) AS revenue
FROM customer
GROUP BY discount_applied;

-- E3. Revenue and average spend by category and season
SELECT category, season, SUM(purchase_amount) AS revenue, ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM customer
GROUP BY category, season
ORDER BY category, revenue DESC;

-- E4. Spend by segment and subscription (are loyal subscribers worth more?)
WITH seg AS (
  SELECT *, CASE WHEN previous_purchases = 1 THEN 'New'
                 WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
                 ELSE 'Loyal' END AS customer_segment
  FROM customer)
SELECT customer_segment, subscription_status, COUNT(*) AS customers, ROUND(AVG(purchase_amount), 2) AS avg_spend
FROM seg
GROUP BY customer_segment, subscription_status
ORDER BY customer_segment, subscription_status;

-- E5. Payment method share of orders and revenue
SELECT payment_method, COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customer), 1) AS pct_orders,
       SUM(purchase_amount) AS revenue
FROM customer
GROUP BY payment_method
ORDER BY revenue DESC;
