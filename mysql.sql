create database ecommerce;


-- 1. List all unique cities where customers are located.
select distinct customer_city from customers;



-- 2. Count the number of orders placed in 2017.
select count(order_id) from orders where year(order_purchase_timestamp)= 2017


-- 3. Count the number of customers from each state.--
SELECT * FROM customers LIMIT 10;
SELECT `customer_state`, COUNT(`customer_id`)
FROM `customers`
GROUP BY `customer_state`;



SELECT * FROM customers LIMIT 10;
SELECT `customer_state`, COUNT(`customer_id`)
FROM `customers`
GROUP BY `customer_state`;



--  4. Calculate the number of orders per month in 2018.
SELECT MONTHNAME(order_purchase_timestamp) AS months, COUNT(order_id) AS order_count
FROM orders
WHERE YEAR(order_purchase_timestamp) = 2018
GROUP BY monthname(order_purchase_timestamp);



-- 5.Find the average number of products per order, grouped by customer city.

SELECT orders.order_id, orders.customer_id, count(order_items.order_id) AS oc
    FROM orders JOIN order_items
    ON orders.order_id = order_items.order_id
    GROUP BY orders.order_id, orders.customer_id;



-- 6. Calculate the total revenue generated by each seller
SELECT order_items.seller_id, SUM(payments.payment_value)
FROM order_items
JOIN payments ON order_items.order_id = payments.order_id
GROUP BY order_items.seller_id



-- 7. Calculate the moving average of order values for each customer over their order history.
select customer_id, order_purchase_timestamp, payment,
avg(payment) over(partition by customer_id order by order_purchase_timestamp rows between 2 preceding and current row) as mov_avg
from
(select orders.customer_id, orders.order_purchase_timestamp,
payments.payment_value as payment
from payments join orders
on payments.order_id = orders.order_id) as a;



-- 8. Calculate the cumulative sales per month for each year.
SELECT years, 
       months, 
       payment, 
       SUM(payment) OVER (ORDER BY years, months) AS cumulative_sales 
FROM (
    SELECT YEAR(orders.order_purchase_timestamp) AS years, 
           MONTH(orders.order_purchase_timestamp) AS months,
           ROUND(SUM(payments.payment_value), 2) AS payment 
    FROM orders 
    JOIN payments ON orders.order_id = payments.order_id 
    GROUP BY years, months
) AS a;



-- 9. Calculate the year-over-year growth rate of total sales.
WITH a AS (
    SELECT YEAR(orders.order_purchase_timestamp) AS years,
           ROUND(SUM(payments.payment_value), 2) AS payment 
    FROM orders 
    JOIN payments ON orders.order_id = payments.order_id 
    GROUP BY years 
    ORDER BY years
)

SELECT years, 
           ((payment - LAG(payment, 1) OVER(ORDER BY years)) /
           LAG(payment, 1) OVER(ORDER BY years)) * 100 AS previous_year
    FROM a;
    
    
    
-- 10. Identify the top 3 customers who spent the most money in each year.
 SELECT years, customer_id, payment, d_rank
    FROM (
        SELECT YEAR(orders.order_purchase_timestamp) AS years,
               orders.customer_id,
               SUM(payments.payment_value) AS payment,
               DENSE_RANK() OVER(PARTITION BY YEAR(orders.order_purchase_timestamp)
                                 ORDER BY SUM(payments.payment_value) DESC) AS d_rank
        FROM orders
        JOIN payments ON payments.order_id = orders.order_id
        GROUP BY YEAR(orders.order_purchase_timestamp), orders.customer_id
    ) AS a
    WHERE d_rank <= 3;
    











