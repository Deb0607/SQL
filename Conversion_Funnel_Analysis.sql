USE mavenfuzzyfactory;

SELECT *
FROM website_pageviews
WHERE website_session_id = 1059;

SELECT *
FROM(SELECT * FROM website_sessions WHERE website_session_id <= 100) AS First_Hundred
;

SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Fuzzy_Page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-03-31'
	AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
;
CREATE TEMPORARY TABLE Session_Level_Flag
SELECT
website_session_id,
MAX(Product_Page) AS Product_made_it,
MAX(Fuzzy_Page) AS Mrfuzzy_made_it,
MAX(Cart_Page) AS Cart_made_it
FROM (SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Fuzzy_Page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page
-- CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
-- CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
-- CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-03-31'
	AND website_pageviews.pageview_url IN ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
ORDER BY
    website_sessions.website_session_id,
    website_pageviews.created_at
    ) AS Pageview_Level
GROUP BY
	website_session_id
;

SELECT
COUNT(DISTINCT website_session_id) AS Sessions,
ROUND((COUNT(DISTINCT CASE WHEN Product_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)*100),2) AS Lander_to_Product_Page,
ROUND((COUNT(DISTINCT CASE WHEN Mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN Product_made_it = 1 THEN website_session_id ELSE NULL END)*100),2) AS Product_Page_To_Mrfuzzy_Page,
ROUND((COUNT(DISTINCT CASE WHEN Cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN Mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)*100),2) AS Mrfuzzy_To_Cart_Page
FROM Session_Level_Flag
;

SELECT *
FROM website_sessions;

SELECT DISTINCT 
pageview_url

FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
;

SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mrfuzzy_Page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page

FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
;

CREATE TABLE Second_level_Page_View
SELECT
website_session_id,
MAX(Product_Page) AS Product_Made_it,
MAX(Mrfuzzy_Page) AS Mrfuzzy_Made_it,
MAX(Cart_Page) AS Cart_Made_it,
MAX(Shipping_Page) AS Shipping_Made_it,
MAX(Billing_Page) AS Billing_Made_it,
MAX(Thankyou_Page) AS Thankyou_Made_it
FROM(SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mrfuzzy_Page,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at > '2012-08-05'
    AND website_sessions.created_at < '2012-09-05'
ORDER BY
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS Page_View_Label
GROUP BY
	website_session_id
;

SELECT * FROM Second_level_Page_View;
Create TEMPORARY TABLE Session_to_Page
SELECT
COUNT(DISTINCT Second_level_Page_View.website_session_id) AS Sessions,
COUNT(DISTINCT CASE WHEN Product_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Product_Page,
COUNT(DISTINCT CASE WHEN Mrfuzzy_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Mrfuzzy_Page,
COUNT(DISTINCT CASE WHEN Cart_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Cart_Page,
COUNT(DISTINCT CASE WHEN Shipping_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Shipping_Page,
COUNT(DISTINCT CASE WHEN Billing_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Billing_Page,
COUNT(DISTINCT CASE WHEN Thankyou_Made_it = 1 THEN Second_level_Page_View.website_session_id ELSE NULL END) AS To_Thankyou_Page
FROM Second_level_Page_View
;

SELECT * FROM Session_to_Page;
SELECT
ROUND(((To_Product_Page/Sessions)*100),2) AS lander_Page_Click_Rate,
ROUND(((To_Mrfuzzy_Page/To_Product_Page)*100),2) AS Product_Page_Click_Rate,
ROUND(((To_Cart_Page/To_Mrfuzzy_Page)*100),2) AS Mrfuzzy_Page_Click_Rate,
ROUND(((To_Shipping_Page/To_Cart_Page)*100),2) AS Cart_Page_Click_Rate,
ROUND(((To_Billing_Page/To_Shipping_Page)*100),2) AS Shipping_Page_Click_Rate,
ROUND(((To_Thankyou_Page/To_Billing_Page)*100),2) AS Billing_Page_Click_Rate
FROM Session_to_Page
;

SELECT
MIN(website_pageviews.website_pageview_id)
-- MIN(website_pageviews.created_at)
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/billing-2';
-- First PV ID = 53550

SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_Version_Page,
orders.order_id AS Order_Id
FROM website_pageviews
LEFT JOIN orders
	ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
    ;

SELECT
Billing_Version_Page,
COUNT(DISTINCT website_session_id) AS Sessions,
COUNT(DISTINCT order_id) AS Orders,
ROUND((COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id)*100),2) AS Billing_to_Order_cnv_Rate
FROM (SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_Version_Page,
orders.order_id AS Order_Id
FROM website_pageviews
LEFT JOIN orders
	ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS Billing_Seasons_wrt_Orders
GROUP BY
Billing_Version_Page
;

SELECT
website_pageviews.pageview_url,
COUNT(DISTINCT website_pageviews.website_session_id) AS No_Of_Sessions,
COUNT(DISTINCT orders.order_id) AS No_Of_Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_pageviews.website_session_id)*100),2) AS Billing_to_Order_cnv_Rate
FROM website_pageviews
LEFT JOIN orders
ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.website_pageview_id >= 53550
	AND website_pageviews.created_at < '2012-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
GROUP BY
	website_pageviews.pageview_url