USE MAVENMOVIES;

SELECT *
FROM RENTAL;

SELECT 
customer_id,
rental_date
from rental;

SELECT 
	first_name,
	last_name,
	email
FROM customer;

SELECT * FROM film;

SELECT
	DISTINCT(rating)
    FROM film;
    
    SELECT
		distinct(rental_duration)
        FROM film;
  
Select * from payment;  
SELECT
	customer_id,
    rental_id,
    amount,
    payment_date
FROM payment
where payment_date > '2005-06-01';

SELECT *
FROM payment
WHERE customer_id < 101
AND amount > 5
AND payment_date > '2006-01-01';


SELECT *
FROM payment
WHERE customer_id = 5
OR customer_id = 11
OR customer_id = 29;

SELECT 
customer_id,
rental_id,
amount,
payment_date
FROM payment
WHERE amount > 5
OR customer_id = 42
OR customer_id = 53
OR customer_id = 60
OR customer_id = 75;

SELECT 
customer_id,
rental_id,
amount,
payment_date
FROM payment
WHERE amount > 5
OR customer_id IN (42,53,60,75);

SELECT *
FROM payment
WHERE customer_id IN (5,11,29);

SELECT
title,
special_features
FROM film
WHERE special_features LIKE '%Behind the scenes%';

SELECT
rating,
COUNT(film_id) as num
FROM FILM
GROUP BY
	rating;
    
SELECT 
rental_duration,
COUNT(film_id) AS film_with_rental_dutaion
FROM film
GROUP BY
 rental_duration;
 
 -- Multiple Group BY--
 SELECT
 rating,
 rental_duration,
 COUNT(film_id) AS film_with_rental_dutaion
FROM film
GROUP BY
	rating,
    rental_duration
ORDER BY
	film_with_rental_dutaion DESC;

SELECT
replacement_cost,
COUNT(film_id) AS No_of_Flims,
MIN(rental_rate) AS Cheapest_Rental,
MAX(rental_rate) AS Expensive_Rental,
AVG(rental_rate) AS Avarage_Rental
FROM film
GROUP BY
	replacement_cost;
-- ORDER BY
	-- replacement_cost DESC;-

SELECT
customer_id,
COUNT(rental_id) AS Total_Rental
FROM rental
GROUP BY
	customer_id
HAVING
	Total_Rental < 15;

SELECT
	title,
    length,
    rental_rate
FROM film
ORDER BY
	length DESC;
    
SELECT 
    DISTINCT(length),
    title,
    CASE
		WHEN length < 60 THEN 'Under 1 Hr'
        WHEN length <= 90 THEN '1-1.5 Hrs'
		WHEN length <= 120 THEN 'Under 2 Hrs'
        WHEN length > 120 THEN	'Over 2 Hrs'
        ELSE 'Need to check'
	END AS Length_Bucket
FROM film;
-- WHERE Length_Bucket = 'Need to check';



SELECT 
DISTINCT(length) 
FROM film;

SELECT * from CUSTOMER;

SELECT
DISTINCT(store_id),
CONCAT(first_name," ",last_name) AS Customer_Name,
CASE
	WHEN store_id = 1 AND active = 1 THEN 'Store 1 Active'
    WHEN store_id = 1 AND active = 0 THEN 'Store 1 Inactive'
    WHEN store_id = 2 AND active = 1 THEN 'Store 2 Active'
    WHEN store_id = 2 AND active = 0 THEN 'Store 2 Inactive'
    ELSE 'Need to Check'
END AS Store_Status
FROM customer;
 