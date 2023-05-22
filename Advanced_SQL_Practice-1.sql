Select * 
from orders;

select * 
from website_sessions; -- where website_session_id = 1059;

select * 
from website_pageviews where website_session_id = 1059;

select * 
from orders where website_session_id =1059;

select
utm_source,
utm_campaign
from website_sessions;

SELECT
website_sessions.utm_content,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100),2) AS Session_To_Order_Convert_Rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY
	1
ORDER BY
	4 DESC;
    
SELECT 
website_sessions.utm_source AS UTM_Source,
website_sessions.utm_campaign AS UTM_Campaign,
website_sessions.http_referer AS Reffering_Domain,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-04-12'
GROUP BY
	1,
    2,
    3
ORDER BY
	4 DESC;
    

SELECT
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
(COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100) AS Session_to_Order_CVR
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-04-14' 
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
;

SELECT
YEAR(created_at) AS Year,
WEEK(created_at) AS WEEK,
-- DATE(created_at) AS Date,
MIN(DATE(created_at)) AS Week_Start,
COUNT(DISTINCT website_session_id) AS Sessions
FROM website_sessions
WHERE website_session_id BETWEEN 100000 AND 115000
GROUP BY
	1,2
ORDER BY
	4 DESC
;

SELECT * FROM orders;

SELECT 
orders.primary_product_id AS Primary_Product_Code,
COUNT(DISTINCT CASE WHEN orders.items_purchased = 1 THEN orders.order_id ELSE NULL END) AS Ordered_Single_Item,
COUNT(DISTINCT CASE WHEN orders.items_purchased = 2 THEN orders.order_id ELSE NULL END) AS Ordered_Multiple_Items,
COUNT(DISTINCT orders.order_id) AS Total_Orders
FROM orders
WHERE orders.order_id BETWEEN 30000 AND 32000
GROUP BY
	1
;

SELECT
MIN(DATE(website_sessions.created_at)) AS Week_Start_Date,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions
FROM website_sessions
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-05-12'
GROUP BY
	YEAR(created_at),
	WEEK(created_at)
;

-- SELECT * FROM website_sessions WHERE created_at < '2012-05-12' -- AND utm_source = 'gearch' AND utm_campaign = 'nonbrand'
-- Trafic Source Bid Optimazation. Mobile Vs Deskstop Session to Order Converstion Rate --
SELECT
website_sessions.device_type AS Device_Type,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100),2) AS Session_to_Order_Conv_Rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-05-11'
	AND website_sessions.utm_source = 'gsearch'
	and website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	1
;
-- Traffic Source Segment Tranding --
SELECT
MIN(DATE(website_sessions.created_at)) AS Week_Start_Date,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS Desktop_Sessions,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS Mob_Sessions
FROM website_sessions
WHERE website_sessions.created_at BETWEEN '2012-04-15' AND '2012-06-09'
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEAR(created_at),
    WEEK(created_at)
;

SELECT
pageview_url,
COUNT(DISTINCT website_pageview_id) AS No_Of_Views
FROM website_pageviews
GROUP BY
	1
ORDER BY
	No_Of_Views DESC
;

-- Creating Temporary Table --
CREATE TEMPORARY TABLE Page_View
SELECT
website_session_id,
MIN(website_pageview_id) AS Min_Pv_Id
FROM website_pageviews
GROUP BY
	1;
    
SELECT
website_pageviews.pageview_url AS Landing_Page,
COUNT(DISTINCT Page_View.website_session_id) AS Session_Hitting_This_Page
FROM Page_View
	LEFT JOIN website_pageviews
		ON Page_View.Min_Pv_Id = website_pageviews.website_pageview_id
WHERE website_pageviews.created_at < '2012-06-12'
GROUP BY
1;

SELECT
website_pageviews.pageview_url AS Page_View_Url,
COUNT(DISTINCT Page_View.website_session_id) AS Sessions
FROM Page_View
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = Page_View.website_session_id
        WHERE website_pageviews.created_at < '2012-06-09'
GROUP BY
	1
ORDER BY
	Sessions DESC
;

SELECT
pageview_url,
COUNT(DISTINCT website_pageview_id) AS Page_View_Sessions
FROM website_pageviews
WHERE website_pageviews.created_at < '2012-06-09'
GROUP BY
	pageview_url
ORDER BY
	Page_View_Sessions DESC
;


