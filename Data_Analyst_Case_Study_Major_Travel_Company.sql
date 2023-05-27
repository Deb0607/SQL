CREATE DATABASE Booking;

USE  Booking;

CREATE TABLE Bookin_Details(
Booking_id VARCHAR(10) NOT NULL,
Booking_date DATE NOT NULL,
User_id VARCHAR(5) NOT NULL,
Line_of_business VARCHAR(10) NOT NULL
);

CREATE TABLE User_table(
User_id VARCHAR(5) NOT NULL,
Segment VARCHAR(5) NOT NULL
)

INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b1','2022-03-23','u1','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b2','2022-03-27','u2','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b3','2022-03-28','u1','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b4','2022-03-31','u4','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b5','2022-04-02','u1','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b6','2022-04-02','u2','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b7','2022-04-06','u5','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b8','2022-04-06','u6','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b9','2022-04-06','u2','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b10','2022-04-10','u1','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b11','2022-04-12','u4','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b12','2022-04-16','u1','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b13','2022-04-19','u2','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b14','2022-04-20','u5','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b15','2022-04-22','u6','Flight');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b16','2022-04-26','u4','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b17','2022-04-28','u2','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b18','2022-04-30','u1','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b19','2022-05-04','u4','Hotel');
INSERT INTO Bookin_Details(Booking_id,Booking_date,User_id,Line_of_business) VALUES ('b20','2022-05-06','u1','Flight');
;

INSERT INTO user_table(User_id,Segment) VALUES ('u1','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u2','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u3','s1');
INSERT INTO user_table(User_id,Segment) VALUES ('u4','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u5','s2');
INSERT INTO user_table(User_id,Segment) VALUES ('u6','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u7','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u8','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u9','s3');
INSERT INTO user_table(User_id,Segment) VALUES ('u10','s3');

SELECT * FROM Bookin_Details;
SELECT * FROM User_table;

-- Write a SQL query that gives the below out put
-- Segment | Total_User_Count | User_Who_booked_flight_in_2022

SELECT
ut.Segment,
COUNT(DISTINCT ut.User_id) AS Total_User_Count,
COUNT(DISTINCT CASE WHEN bd.Line_of_business = 'Flight' AND bd.Booking_date BETWEEN '2022-04-01' AND '2022-04-30' THEN bd.User_id ELSE NULL END) AS User_Who_Booked_Flight_in_2022
FROM User_table AS ut
LEFT JOIN Bookin_Details AS bd
	ON ut.User_id = bd.User_id
GROUP BY
	ut.Segment;

-- Write a query to identify users whose first booking was hotel booking -- 
WITH Find_First_Booking AS(
SELECT * 
,RANK() OVER (PARTITION BY User_id ORDER BY Booking_date) AS rn
FROM Bookin_Details)
SELECT * FROM 
Find_First_Booking
WHERE rn = 1 AND Line_of_business = 'Hotel';

WITH Find_First_Booking AS(
SELECT * 
,first_value(Line_of_business) OVER (PARTITION BY User_id ORDER BY Booking_date) AS first_booking
FROM Bookin_Details)
SELECT DISTINCT(User_id) FROM 
Find_First_Booking
WHERE first_booking = 'Hotel' ;

-- Write a query to calculate the first & last booking of user

SELECT
User_id,
MIN(Booking_date) AS First_Booking,
MAX(Booking_date) AS Last_Booking,
DATEDIFF(DAY,MIN(Booking_date),MAX(Booking_date)) AS Booking_Duration
FROM Bookin_Details
GROUP BY User_id;


-- Write a query to count the number of flight and hotel booking in each user segments for the year 2022 --

SELECT
u.Segment,
COUNT(DISTINCT CASE WHEN b.Line_of_business = 'Flight' THEN b.Booking_id ELSE NULL END) AS no_of_flight_booking,
COUNT(DISTINCT CASE WHEN b.Line_of_business = 'Hotel' THEN b.Booking_id ELSE NULL END) AS no_of_hotel_booking
FROM Bookin_Details AS b
INNER JOIN User_table AS u
	ON b.User_id = u.User_id
GROUP BY
u.Segment;