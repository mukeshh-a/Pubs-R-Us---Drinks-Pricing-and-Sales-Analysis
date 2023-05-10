-- 1. How many pubs are located in each country??

SELECT country AS Country, COUNT(DISTINCT pub_id) AS Pubs
FROM pubs
GROUP BY country;

-- 2. What is the total sales amount for each pub, including the beverage price and quantity sold?

SELECT p.pub_name, SUM(b.price_per_unit * s.quantity) AS 'Total Sales Amount'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
GROUP BY p.pub_name;

-- OR

SELECT p.pub_name, b.beverage_name, b.price_per_unit, s.quantity, (b.price_per_unit * s.quantity) AS 'Total Sales Amount'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
GROUP BY p.pub_name, b.beverage_name, b.price_per_unit, s.quantity; 

-- 3. Which pub has the highest average rating?

SELECT pub_name AS 'Pub Name', AVG(rating) 'Average Rating'
FROM pubs p 
JOIN ratings r ON p.pub_id = r.pub_id
GROUP BY pub_name 
ORDER BY AVG(rating) DESC
LIMIT 1;


-- 4. What are the top 5 beverages by sales quantity across all pubs?

SELECT p.pub_name AS 'Pub Name', b.beverage_name AS 'Beverage Name', SUM(s.quantity) AS 'Sales Quantity'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
GROUP BY p.pub_name, b.beverage_name
ORDER BY SUM(s.quantity) DESC
LIMIT 5;


-- 5. How many sales transactions occurred on each date?

SELECT transaction_date AS 'Date', COUNT(sale_id) AS 'Sales Transactions'
FROM sales
GROUP BY transaction_date
ORDER BY COUNT(sale_id);


-- 6. Find the name of someone that had cocktails and which pub they had it in.

SELECT customer_name AS 'Customer Name', pub_name AS 'Pub Name'
FROM ratings r 
JOIN pubs p ON r.pub_id = p.pub_id
JOIN sales s ON r.pub_id = s.pub_id
JOIN beverages b ON b.beverage_id = s.beverage_id
WHERE b.category = 'cocktail'


-- 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?

SELECT category AS 'Beverage Category', AVG(price_per_unit) AS 'Average Price Per Unit'
FROM beverages
WHERE category NOT LIKE 'Spirit'
GROUP BY category 
ORDER BY AVG(price_per_unit) DESC;


-- 8. Which pubs have a rating higher than the average rating of all pubs?

SELECT p.pub_name AS 'Pub Name', AVG(r.rating) AS 'Average Rating'
FROM pubs p
JOIN ratings r ON p.pub_id = r.pub_id
GROUP BY p.pub_name
HAVING AVG(r.rating) > (SELECT AVG(rating) FROM ratings)
ORDER BY AVG(r.rating) DESC;


-- 9. What is the running total of sales amount for each pub, ordered by the transaction date?

SELECT p.pub_name AS 'Pub Name', s.transaction_date AS 'Transaction Date',
    (SELECT SUM(b.price_per_unit * s2.quantity)
    FROM sales s2
    JOIN beverages b ON s2.beverage_id = b.beverage_id
    WHERE s2.pub_id = p.pub_id AND s2.transaction_date <= s.transaction_date) AS 'Running Total of Sales Amount'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
ORDER BY s.transaction_date;

/* 10. For each country, what is the average price per unit of beverages in each category, 
and what is the overall average price per unit of beverages across all categories? */

WITH ap AS (
    SELECT p.country, b.category, AVG(b.price_per_unit) AS average_price
    FROM pubs p 
    JOIN sales s ON s.pub_id = p.pub_id
    JOIN beverages b ON s.beverage_id = b.beverage_id
    GROUP BY p.country, b.category
), tp AS (
    SELECT p.country, AVG(b.price_per_unit) AS total_average_price
    FROM pubs p 
    JOIN sales s ON s.pub_id = p.pub_id
    JOIN beverages b ON s.beverage_id = b.beverage_id
    GROUP BY p.country
)
SELECT ap.country AS Country, ap.category AS Category, ap.average_price AS 'Average Price Per Unit', tp.total_average_price AS 'Overall Average Price Per Unit'
FROM ap
JOIN tp ON ap.country = tp.country;


/* 11. For each pub, 
what is the percentage contribution of each category of beverages to the total sales amount, 
and what is the pub's overall sales amount? */

SELECT p.pub_id AS 'Pub ID', p.pub_name AS 'Pub Name', b.category 'Beverage Category',
       (SUM(s.quantity * b.price_per_unit) / pt.pub_total_sales_amount) * 100 AS 'Percentage Contribution',
       pt.pub_total_sales_amount AS 'Total Sales Amount'
FROM pubs p
JOIN sales s ON p.pub_id = s.pub_id
JOIN beverages b ON s.beverage_id = b.beverage_id
JOIN (
  SELECT p.pub_id, SUM(s.quantity * b.price_per_unit) AS pub_total_sales_amount
  FROM pubs p
  JOIN sales s ON p.pub_id = s.pub_id
  JOIN beverages b ON s.beverage_id = b.beverage_id
  GROUP BY p.pub_id
) pt ON p.pub_id = pt.pub_id
GROUP BY p.pub_id, p.pub_name, b.category, pt.pub_total_sales_amount;



 