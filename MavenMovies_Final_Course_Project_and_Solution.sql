USE mavenmovies;
/* 
1. My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
SELECT
ST.first_name AS Manger_Fisrt_Name,
ST.last_name AS Manger_Last_Name,
AD.address AS Street_Address,
AD.district AS District,
C.city AS City,
CN.country AS Country
FROM store AS S
INNER JOIN staff AS ST
	ON S.manager_staff_id = ST.staff_id
INNER JOIN address AS AD
	ON ST.address_id = AD.address_id
INNER JOIN city AS C
	ON AD.city_id = C.city_id
INNER JOIN country AS CN
	ON C.country_id = CN.country_id;


SELECT
ST.first_name AS Manger_Fisrt_Name,
ST.last_name AS Manger_Last_Name,
AD.address AS Street_Address,
AD.district AS District,
C.city AS City,
CN.country AS Country
FROM store AS S
LEFT JOIN staff AS ST
	ON S.manager_staff_id = ST.staff_id
LEFT JOIN address AS AD
	ON ST.address_id = AD.address_id
LEFT JOIN city AS C
	ON AD.city_id = C.city_id
LEFT JOIN country AS CN
	ON C.country_id = CN.country_id;



	
/*
2.	I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

SELECT
I.store_id AS Store_Id,
I.inventory_id AS Inventory_Id,
F.title AS Name_of_The_Film,
F.rating AS Films_Rating,
f.rental_rate AS Rental_Rete,
f.replacement_cost AS Replacement_Cost
FROM inventory AS I
LEFT JOIN film AS F
	ON I.film_id = F.film_id;

/* 
3.	From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

SELECT
I.store_id AS Store_Id,
F.rating as Rating,
COUNT(I.inventory_id) AS Inventory_Items
FROM inventory AS I
LEFT JOIN film AS F
	ON I.film_id = F.film_id
GROUP BY
	Store_Id,
    Rating;

/* 
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 

SELECT
I.store_id AS Store_Id,
C.name AS Film_Category,
COUNT(I.inventory_id) AS No_of_Films,
AVG(F.replacement_cost) AS Avarage_Replacement_Cost,
SUM(F.replacement_cost) AS Total_Replacement_Cost
FROM inventory AS I
LEFT JOIN film AS F
	ON I.film_id = F.film_id
LEFT JOIN film_category AS FC
	ON F.film_id = FC.film_id
LEFT JOIN category AS C
	ON FC.category_id = C.category_id
GROUP BY
    Store_Id,
    Film_Category
ORDER BY
	Total_Replacement_Cost;
    

/*
5.	We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/
SELECT
customer.first_name AS First_Name,
customer.last_name AS Last_Name,
CASE
WHEN customer.store_id = 1 THEN 'STORE-1'
WHEN customer.store_id = 2 THEN 'STORE-2'
ELSE 'NEED TO CHECK' END AS Store,
CASE 
WHEN customer.active = 1 THEN 'Active'
WHEN customer.active = 0 THEN 'Inactive'
ELSE 'NEED TO CHECK' END AS Customer_Status,
address.address AS Street_Address,
city.city AS City,
country.country AS Country
FROM customer
LEFT JOIN address
	ON customer.address_id = address.address_id
LEFT JOIN city
	ON address.city_id = city.city_id
LEFT JOIN country
	ON city.country_id = country.country_id;


/*
6.	We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

SELECT
customer.first_name AS Fisrt_Name,
customer.last_name AS Last_Name,
COUNT(rental.rental_id) AS Total_Rentals,
SUM(payment.amount) AS Total_Payment_Amount
FROM customer
LEFT JOIN rental
	ON customer.customer_id = rental.customer_id
LEFT JOIN payment
	ON rental.rental_id = payment.rental_id
GROUP BY
	Fisrt_Name,
    Last_Name
ORDER BY
	 Total_Payment_Amount DESC;    
/*
7. My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/
SELECT
'Investor' AS TYPE,
first_name, 
last_name, 
company_name
FROM investor
UNION
SELECT
'Advisor' AS TYPE,
first_name,
last_name,
NULL
FROM advisor;

/*
8. We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/
SELECT (count(actor_award_id)/avg(actor_award.actor_id)*100) FROM actor_award;
SELECT
CASE
	WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 Awards'
    WHEN actor_award.awards IN ('Emmy, Oscar', 'Emmy, Tony' , 'Oscar, Tony') THEN '2 Awards'
    ELSE '1 Award'
    END AS Type_Of_Awards,
    COUNT(actor_award_id) AS No_of_Awards ,
    (COUNT(actor_award.actor_id)/COUNT(actor_award.actor_award_id)*100) AS Award_wining_Rate
    FROM actor_award
GROUP BY
Type_Of_Awards
	
