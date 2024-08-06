-- IMPORTANT VALUES ---

-- Total Orders
SELECT count(order_id) AS Total_Orders FROM olist_orders_dataset;

-- Total Products
SELECT count(product_id) AS Total_Products FROM olist_products_dataset;

-- Total Customers
SELECT count(customer_id) AS Total_Customers FROM olist_customers_dataset;

-- Average Review Score
SELECT round(avg(review_score)) AS Average_Review_Score FROM olist_order_reviews_dataset;


SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

-- MAIN KPI's
-- KPI 1-Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics
SELECT 
CASE 
    WHEN dayname(order_purchase_timestamp) ="Saturday"
    THEN "Weekend"
    WHEN dayname(order_purchase_timestamp) ="Sunday"
    THEN "Weekend"
    ELSE "Weekday"
END AS WeekdayorWeekend,
concat(round((sum(payment_value)/16008872)*100),"%") AS Percenatge_of_Payment
FROM olist_orders_dataset 
LEFT JOIN olist_order_payments_dataset 
ON olist_orders_dataset.order_id=olist_order_payments_dataset.order_id
GROUP BY WeekdayorWeekend;

-- KPI 2 Number of Orders with review score 5 and payment type as credit card.
SELECT review_score, payment_type,
count(olist_order_reviews_dataset.order_id) AS No_of_orders
FROM olist_order_reviews_dataset 
JOIN olist_order_payments_dataset 
ON olist_order_reviews_dataset.order_id = olist_order_payments_dataset.order_id
WHERE review_score = 5 AND payment_type = "credit_card"
GROUP BY review_score;

-- KPI 3 Average number of days taken for order_delivered_customer_date for pet_shop
SELECT  product_category_name, 
round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp))) AS "Avg Days taken for pet shop"
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
ON o.order_id = i.order_id
JOIN olist_products_dataset p
ON p.product_id = i.product_id
WHERE product_category_name = "pet_shop";

-- KPI 4 Average price and payment values from customers of sao paulo city
SELECT customer_city,round(avg(price)) AS Average_Price, 
round(avg(payment_value)) AS Average_Payment
FROM olist_customers_dataset
JOIN olist_orders_dataset
USING(customer_id)
JOIN olist_order_items_dataset
USING(order_id)
JOIN olist_order_payments_dataset
USING(order_id)
WHERE olist_customers_dataset.customer_city ="sao paulo";

-- KPI 5 Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.
SELECT review_score,
round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp))) AS Shipping_Days
FROM olist_orders_dataset 
JOIN olist_order_reviews_dataset 
USING (order_id)
GROUP BY review_score
ORDER BY shipping_days desc;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

