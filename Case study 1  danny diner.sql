/* On this Project we will be working  on a caSe Study, we will call it Case Study 1
Danny seriously loves Japanese food so in the beginning of 2021, 
he decides to embark upon a risky venture and opens up a cute little 
restaurant that sells his 3 favourite foods: sushi, curry and ramen.

We will be answering questions a few simple questions about his customers, 
especially about their visiting patterns, 
how much money they’ve spent and also which menu items are their favourite. 
Having this deeper connection with his customers will help him deliver a better and more personalised experience 
for his loyal customers.
*/


-- use a Database named DANNY_DINER ()
CREATE DATABASE IF NOT exists danny_diner;
USE danny_diner;

-- Create the tables that will be used on the case study 1 (Menu, Sales and Members)
CREATE TABLE menu(
product_id int,
product_name varchar(5),
price int
);

CREATE TABLE sales(
customer_id varchar(1),
order_date date,
product_id int
);

CREATE TABLE members(
customer_id varchar(1),
join_date date
);

-- Populate the tables with their respectives values
INSERT INTO menu 
(product_id, product_name, price)
values ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

INSERT INTO  sales
(customer_id, order_date, product_id)
 VALUES ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
  
  INSERT INTO members
  (customer_id, join_date)
  VALUES ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
  -- Show the tables and its rows
  SELECT *
  FROM members;
  
  SELECT *
  FROM sales; 
  
  SELECT *
  FROM menu; 
  
  
  -- Start asnwerin the questions
  
  -- 1. What is the total amount each customer spent at the restaurant?
SELECT 
    sales.customer_id, SUM(menu.price)
   
FROM  
    sales 
INNER JOIN 
    menu ON sales.product_id = menu.product_id
GROUP BY 
	sales.customer_id;
    

-- 2. How many days has each customer visited the restaurant? 
SELECT
	sales.customer_id , count(sales.order_date) as Number_of_Visits
FROM
	sales
GROUP BY
sales.customer_id;


-- 3. What was the first item from the menu purchased by each customer?
WITH ranked_sales AS (
SELECT 
	sales.customer_id, sales.order_date, row_number() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_num
FROM
	sales
)

SELECT
	customer_id, order_date
FROM
	ranked_sales
WHERE
	row_num=1;
    
    
 -- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH PURCHASES AS (
  
  SELECT
       distinctrow menu.product_name, 
        COUNT(sales.order_date) OVER (PARTITION BY menu.product_name) AS NUMBER_OF_TIMES
    FROM
        sales
    INNER JOIN 
        menu ON sales.product_id = menu.product_id

)
SELECT
	product_name, NUMBER_OF_TIMES
FROM 
	PURCHASES
ORDER BY 
	NUMBER_OF_TIMES DESC
LIMIT 1;
    
-- 5. Which item was the most popular for each customer?
WITH times AS (
	SELECT
		sales.customer_id,
		menu.product_name,
		COUNT(*) OVER (PARTITION BY menu.product_id) AS TIMES_BOUGHT,
        ROW_NUMBER() OVER (PARTITION BY sales.customer_id ORDER BY COUNT(*) DESC) AS rn
	FROM 
		menu
	INNER JOIN sales on menu.product_id = sales.product_id
    
     GROUP BY
        sales.customer_id, menu.product_name, menu.product_id
   
)

SELECT
	customer_id,
    product_name, 
    TIMES_BOUGHT,
    rn
FROM
	times
WHERE
	rn =1;
    
    
-- 6. Which item was purchased first by the customer after they became a member?
WITH PURCHASES AS (	
    SELECT
		members.customer_id,
        members.join_date,
        sales.order_date,
        menu.product_name,
        COUNT(*) OVER (PARTITION BY members.customer_id) AS FIRST_BOUGHT,
        ROW_NUMBER () OVER (PARTITION BY members.customer_id ORDER BY COUNT(*) ) AS rn
                
    FROM 
		members
        
	INNER JOIN sales ON members.customer_id = sales.customer_id
    INNER JOIN menu ON  sales.product_id = menu.product_id
    
    WHERE
		members.join_date < sales.order_date
    
    GROUP BY
	members.customer_id,
        members.join_date,
        sales.order_date,
        menu.product_name	
)

SELECT
	Customer_id,
    product_name
FROM
	PURCHASES
WHERE
	rn = 1;
    
    
    
-- 7. Which item was purchased just before the customer became a member?
WITH PURCHASED AS (
	SELECT 
		members.customer_id,
        members.join_date,
        sales.order_date,
        sales.product_id,
        ROW_NUMBER () OVER (PARTITION BY members.customer_id  ORDER BY sales.order_date DESC) AS rn
        
    FROM
		members
	
    INNER JOIN sales on members.customer_id = sales.customer_id
    
    WHERE
	members.join_date > sales.order_date
    
    GROUP BY
		members.customer_id,
        members.join_date,
        sales.order_date,
        sales.product_id
)

SELECT
	customer_id,
    join_date,
    order_date,
    product_id
    
FROM
	PURCHASED
WHERE
	rn=1;
    
    
-- 8. What is the total items and amount spent for each member before they became a member?

	SELECT
		members.customer_id,
        COUNT(sales.order_date) AS ITEMS_NUMBER,
        SUM(menu.price) AS Total_spent
        
        
    FROM
		members
	
	INNER JOIN sales ON members.customer_id = sales.customer_id
    INNER JOIN menu ON sales.product_id = menu.product_id
    
    WHERE
		members.join_date > sales.order_date
        
	GROUP BY 
		members.customer_id;



-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH POINTS	 AS (
	SELECT
		sales.customer_id,
        sales.product_id,
        CASE
			WHEN sales.product_id = 1 THEN (menu.price * 10)*2 
            ELSE menu.price * 10
		END AS TOTAL_POINTS
            
    FROM
		sales
	
    INNER JOIN menu ON sales.product_id = menu.product_id
    
    GROUP BY
	sales.customer_id,
    sales.product_id,
    menu.price
)

SELECT
	customer_id,
    SUM(TOTAL_POINTS) AS TOTAL

FROM
	POINTS
GROUP BY
    customer_id;
    
    


/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 not just sushi - how many points do customer A and B have at the end of January? */
 
     -- same plan has the previous one the only difference is that you ill add another when which will meantione the 1 week 
                 -- for the month of January u just need to filter the CTE table        

WITH POINTS AS (

 SELECT
		sales.customer_id,
        sales.product_id,
        sales.order_date,
        CASE
			WHEN sales.order_date BETWEEN members.join_date AND DATE_ADD(members.join_date, INTERVAL 1 WEEK) THEN (menu.price * 10)*2 
			WHEN sales.product_id = 1 THEN (menu.price * 10)*2 
            ELSE menu.price * 10
		END AS TOTAL_POINTS
            
    FROM
		sales
	
    INNER JOIN menu ON sales.product_id = menu.product_id
    INNER JOIN members ON sales.customer_id = members.customer_id

)

SELECT
	customer_id,
    SUM(TOTAL_POINTS)

FROM
	POINTS

WHERE
	MONTH(order_date) =1 AND YEAR(order_date)= 2021
    
GROUP BY 
	customer_id;



-- BONUS QUESTION
-- JOIN EVERYTHING

CREATE TABLE combined_data AS
SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date < mem.join_date THEN 'N'
        ELSE 'Y'
    END AS member
FROM
    sales s
JOIN menu m ON s.product_id = m.product_id
LEFT JOIN members mem ON s.customer_id = mem.customer_id

UNION ALL

SELECT
    s.customer_id,
    s.order_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date < mem.join_date THEN 'N'
        ELSE 'Y'
    END AS member
FROM
    sales s
JOIN menu m ON s.product_id = m.product_id
RIGHT JOIN members mem ON s.customer_id = mem.customer_id;

select * from combined_data;


DROP TABLE EVERYTHING;


-- Rank All The Things

CREATE TABLE combined_data_with_ranking AS
SELECT
    customer_id,
    order_date,
    product_name,
    price,
    member,
    CASE
        WHEN member = 'Y' THEN ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date)
        ELSE NULL
    END AS ranking
FROM
    combined_data;
    



