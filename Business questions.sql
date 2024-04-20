
-- Count of products
select count(product_id) from order_items;


-- 1. Categories of tech products
SELECT product_category_name, COUNT(product_id) As Number_of_products
FROM products 
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios','audio','consoles_games','eletronicos') 
GROUP BY product_category_name;

-- A breakdown of all the total count of tech products in the products table

-- ----------------------------------------------------------------------------------------------------------------------------
-- 2. Products sold in the tech categories
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?

SELECT product_category_name, count(order_items.product_id) As Tech_products
FROM orders
LEFT JOIN order_items USING (order_id)
LEFT JOIN products USING (product_id)
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios','audio','consoles_games','eletronicos')
group by product_category_name;

-- The query joins the 'order', 'order items' and 'products' tables. 
-- It counts the number of products sold from order_items table and groups them by the tech categories. 

-- ----------------------------------------------------------------------------------------------------------------------------

-- Average price of the Tech products sold

-- By tech products
SELECT ROUND(AVG(price)) As Average_price
FROM orders
LEFT JOIN order_items USING (order_id)
LEFT JOIN products USING (product_id)
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios','audio','consoles_games','eletronicos');


-- Average price for products sold

Select ROUND(AVG(price)) As Average_price
FROM order_items;

-- ----------------------------------------------------------------------------------------------------------------------------

-- Popularity of tech products
Select COUNT(DISTINCT product_id) AS product_count, AVG(review_score) AS Avg_review_score,
  CASE WHEN price BETWEEN 0 AND 99 THEN "Low value"
     WHEN price BETWEEN 100 AND 150 THEN "Middle Range value"
     ELSE "High value"
     END AS Price_Categories
     FROM order_items
     JOIN products USING (product_id)
     JOIN order_reviews USING (order_id)
     WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios','audio','consoles_games','eletronicos')
     GROUP BY Price_Categories;
     
 -- The query returns the count of products per price categories and also the average reviews of the price categories. 
 
 -- ----------------------------------------------------------------------------------------------------------------------------

-- How many months of data are included in the magist database?

SELECT COUNT(DISTINCT MONTH(order_purchase_timestamp)) AS Month_
FROM orders;

 -- ----------------------------------------------------------------------------------------------------------------------------

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?

SELECT count(seller_id) FROM sellers;

-- Tech sellers

SELECT count(distinct seller_id) FROM sellers AS Number_of_Sellers
JOIN order_items USING (seller_id)
JOIN products USING (product_id)
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios','audio','consoles_games','eletronicos');


-- Percentage of tech sellers
SELECT 
    (COUNT(DISTINCT seller_id) * 100.0) / (SELECT COUNT(seller_id) FROM sellers) AS Percentage_Tech_Sellers
FROM sellers 
JOIN order_items USING (seller_id)
JOIN products USING (product_id) 
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios', 'audio', 'consoles_games', 'eletronicos');

 -- ----------------------------------------------------------------------------------------------------------------------------

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?

-- Sum of Seller earnings
SELECT Round(sum(price),2) AS Sellers_earnings
From order_items;

-- Average Seller earnings
SELECT Round(AVG(price),2) AS Sellers_earnings
From order_items
;

-- Sum of Non tech Sellers earnings
Select ROUND(AVG(price)) AS Tech_Sellers_earnings
From order_items
join products using (product_id)
WHERE product_category_name NOT IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios', 'audio', 'consoles_games', 'eletronicos');


--  Average Price of  tech Sellers earnings
Select ROUND(AVG(price)) AS Tech_Sellers_earnings
From order_items
join products using (product_id)
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios', 'audio', 'consoles_games', 'eletronicos');
 -- ----------------------------------------------------------------------------------------------------------------------------

-- Can you work out the average monthly income of all sellers? 

SELECT 
MONTH (order_purchase_timestamp) AS Month_,
YEAR (order_purchase_timestamp) AS Year_,
Round(AVG(price),2) AS Monthly_income
From orders
Join order_items using (order_id)
GROUP BY Month_,Year_
order by Month_,Year_ ASC;

-- Can you work out the average monthly income of Tech sellers?

SELECT 
MONTH (order_purchase_timestamp) AS Month_,
YEAR (order_purchase_timestamp) AS Year_,
Round(AVG(price),2) AS Monthly_income
From orders
Join order_items using (order_id)
Join products using (product_id)
WHERE product_category_name IN ('pc_gamer', 'telefonia', 'telefonia_fixa', 'informatica_acessorios', 'audio', 'consoles_games', 'eletronicos')
GROUP BY Month_,Year_
order by Month_,Year_ ASC;

 -- ----------------------------------------------------------------------------------------------------------------------------

-- What’s the average time between the order being placed and the product being delivered?

SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS Average_delivery_time
FROM orders
WHERE order_status = 'delivered';

 -- ----------------------------------------------------------------------------------------------------------------------------

-- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
    CASE 
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 'On time' 
        ELSE 'Delayed'
    END AS delivery_status, 
COUNT(DISTINCT order_id) AS orders_count
FROM orders 
WHERE order_status = 'delivered'
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;
    -- Calculates a count of Ontime and delayed deliveries
    
    -- impact of Profit/Loss from Deliveries
    
    SELECT 
    CASE 
        WHEN DATEDIFF(order_estimated_delivery_date, order_delivered_customer_date) > 0 THEN 'On time' 
        ELSE 'Delayed'
    END AS delivery_status, 
COUNT(DISTINCT order_id) AS orders_count, SUM(price-freight_value) AS Profit
FROM orders 
Join order_items using (order_id)
WHERE order_status = 'delivered'
AND order_estimated_delivery_date IS NOT NULL
AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- Calculates the POTENTIAL LOSS if orders are cancelled due to delayed deliveries 

-- Loss from Cancelled deliveries
SELECT COUNT(DISTINCT order_id) AS orders_count, SUM(price-freight_value) AS Profit
FROM orders 
Join order_items using (order_id)
WHERE order_status = 'canceled'
GROUP BY order_status;
    
-- ----------------------------------------------------------------------------------------------------------------------------
    
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT
    product_category_name,
    AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) AS Delay_rate
FROM
    orders
JOIN
    order_items USING (order_id)
JOIN
    products USING (product_id)
GROUP BY
    product_category_name
ORDER BY
    Delay_rate DESC;
