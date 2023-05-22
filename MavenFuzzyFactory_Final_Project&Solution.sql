use mavenfuzzyfactory;


/*
1.	Gsearch seems to be the biggest driver of our business. Could you pull monthly 
trends for gsearch sessions and orders so that we can showcase the growth there? 
*/ 

SELECT
YEAR(website_sessions.created_at) AS Year,
MONTHNAME(website_sessions.created_at) AS Month,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100),2) AS Session_to_Order_CNV_Rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.created_at < '2012-11-27'
GROUP BY 
1,2
ORDER BY 1,2
;



/*
2.	Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out nonbrand 
and brand campaigns separately. I am wondering if brand is picking up at all. If so, this is a good story to tell. 
*/ 
SELECT
YEAR(website_sessions.created_at) AS Year,
monthname(website_sessions.created_at) AS Name_of_Month,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS Nonbrand_Sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS Nonbrand_Orders,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Brand_Sessions,
COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS Brand_Orders
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
GROUP BY
	1,2
;

/*
3.	While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
I want to flex our analytical muscles a little and show the board we really know our traffic sources. 
*/ 

SELECT
YEAR(website_sessions.created_at) AS Year,
MONTHNAME(website_sessions.created_at) AS Month_Name,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS Session_By_Mobile,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS Ordered_By_Mobile,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS Session_By_Desktop,
COUNT(DISTINCT CASE WHEN website_sessions.device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS Ordered_By_Desktop
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	1,2
;


/*
4.	I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?
*/ 

-- first, finding the various utm sources and referers to see the traffic we're getting

SELECT DISTINCT
website_sessions.utm_source,
website_sessions.utm_campaign,
website_sessions.http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
;

SELECT
YEAR(website_sessions.created_at) AS Year,
MONTHNAME(website_sessions.created_at) AS Month_Name,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS Gsearch_Nonbrand_Paid_Sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Gsearch_Brand_Paid_Sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS Bsearch_Nonbrand_Paid_Sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) AS Bsearch_Brand_Paid_Sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS Organic_search_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS Direct_type_Sessions
FROM website_sessions
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY
	1,2
;

/*
5.	I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
Could you pull session to order conversion rates, by month? 
*/

SELECT
CONCAT(LEFT(MONTHNAME(website_sessions.created_at),3),"-",RIGHT(YEAR(website_sessions.created_at),2))AS Month,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100),2) AS Order_cnv_Rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY
	1
;

/*
6.	For the gsearch lander test, please estimate the revenue that test earned us 
(Hint: Look at the increase in CVR from the test (Jun 19 – Jul 28), and use 
nonbrand sessions and revenue since then to calculate incremental value)
*/ 

SELECT
MIN(website_pageviews.website_pageview_id) AS First_pv_id
FROM website_pageviews
WHERE website_pageviews.pageview_url = '/lander-1';

-- 23504
CREATE TEMPORARY TABLE First_Page_View
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS First_pv_id
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at < '2012-07-28'
	AND website_pageviews.website_pageview_id >= 23504
	AND website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 
	1;
    
CREATE TEMPORARY TABLE Nonbrand_Session_w_LandingPage
SELECT
First_Page_View.website_session_id,
website_pageviews.pageview_url AS Landing_Page
FROM First_Page_View
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = First_Page_View.First_pv_id
WHERE website_pageviews.pageview_url IN ('/home','/lander-1');

CREATE TEMPORARY TABLE Nonbrand_Session_w_LandingPage_Order
SELECT
Nonbrand_Session_w_LandingPage.website_session_id,
Nonbrand_Session_w_LandingPage.Landing_Page,
orders.order_id AS Order_id
FROM Nonbrand_Session_w_LandingPage
LEFT JOIN orders
	ON orders.website_session_id = Nonbrand_Session_w_LandingPage.website_session_id
;
    
SELECT
Landing_Page,
COUNT(DISTINCT website_session_id) AS Sessions,
COUNT(DISTINCT Order_id) AS Ordered,
ROUND((COUNT(DISTINCT Order_id)/COUNT(DISTINCT website_session_id)*100),2) AS Order_cnv_Rate
FROM Nonbrand_Session_w_LandingPage_Order
GROUP BY
1
;

SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_gsearch_nonbrand_home_pageview 
FROM website_sessions 
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
    AND pageview_url = '/home'
    AND website_sessions.created_at < '2012-11-27'
;
-- 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
;

/*
7.	For the landing page test you analyzed previously, it would be great to show a full conversion funnel 
from each of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28).
*/ 
SELECT DISTINCT website_pageviews.pageview_url FROM website_pageviews;

CREATE TEMPORARY TABLE Page_Level
SELECT
website_sessions.website_session_id,
website_pageviews.pageview_url,
CASE WHEN website_pageviews.pageview_url = '/home' THEN 1 ELSE 0 END AS Homepage, -- Page Level Flag --
CASE WHEN website_pageviews.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS Custom_lander_page,
CASE WHEN website_pageviews.pageview_url = '/products' THEN 1 ELSE 0 END AS Product_Page,
CASE WHEN website_pageviews.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS Mrfuzzy_Page,
CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
CASE WHEN website_pageviews.pageview_url = '/billing' THEN 1 ELSE 0 END AS Billing_Page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
    AND website_sessions.created_at < '2012-07-28'
    AND website_sessions.created_at > '2012-06-19'
ORDER BY
	website_sessions.website_session_id, website_pageviews.pageview_url
;

CREATE TEMPORARY TABLE Session_level_Flagged
SELECT
website_session_id,
MAX(Homepage) AS Homepage_View,
MAX(Custom_lander_page) AS Custom_lander_Page_View,
MAX(Product_Page) AS Product_Page_View,
MAX(Mrfuzzy_Page) AS Mrfuzzy_Page_View,
MAX(Cart_Page) AS Cart_Page_View,
MAX(Shipping_Page) AS Shipping_Page_View,
MAX(Billing_Page) AS Billing_Page_View,
MAX(Thankyou_Page) AS Thankyou_Page_View
FROM (SELECT * FROM Page_Level)
AS Page_View_Level
GROUP BY
	website_session_id;

CREATE TEMPORARY TABLE Page_Level_Segmentation
SELECT
CASE
WHEN Homepage_View = 1 THEN 'Saw_Homepage'
WHEN Custom_lander_Page_View = 1 THEN 'Saw_Landerpage'
ELSE 'Need_to_ChecK'
END AS Segment,
COUNT(DISTINCT website_session_id) AS Session,
COUNT(DISTINCT CASE WHEN Product_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_Products,
COUNT(DISTINCT CASE WHEN Mrfuzzy_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_Mrfuzyy,
COUNT(DISTINCT CASE WHEN Cart_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_Cart,
COUNT(DISTINCT CASE WHEN Shipping_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_Shipping,
COUNT(DISTINCT CASE WHEN Billing_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_Billing,
COUNT(DISTINCT CASE WHEN Thankyou_Page_View = 1 THEN website_session_id ELSE NULL END) AS To_ThanK_You
FROM Session_level_Flagged
GROUP BY
	Segment;

SELECT * FROM Page_Level_Segmentation;
SELECT
Segment,
ROUND(((To_Products/Session)*100),2) AS lander_click_rt,
ROUND(((To_Mrfuzyy/To_Products)*100),2) AS products_click_rt,
ROUND(((To_Cart/To_Mrfuzyy)*100),2) AS mrfuzzy_click_rt,
ROUND(((To_Shipping/To_Cart)*100),2) AS cart_click_rt,
ROUND(((To_Billing/To_Shipping)*100),2) AS Shipping_click_rt,
ROUND(((To_ThanK_You/To_Billing)*100),2) AS Billing_click_rt
FROM Page_Level_Segmentation
;




/*
8.	I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated 
from the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number 
of billing page sessions for the past month to understand monthly impact.
*/ 
SELECT
Billing_Version,
COUNT(DISTINCT website_session_id) AS Sessions,
COUNT(DISTINCT Order_id) AS Ordered,
SUM(Order_price) AS Amount_of_Ordered_Placed,
ROUND(SUM(Order_price)/COUNT(DISTINCT website_session_id),2) AS Revenue_per_billing_page
FROM(
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url AS Billing_Version,
orders.order_id AS Order_id,
orders.price_usd AS Order_price
FROM website_pageviews
	LEFT JOIN orders
		ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10'
	AND website_pageviews.created_at < '2021-11-10'
    AND website_pageviews.pageview_url IN ('/billing','/billing-2')
) AS Billing_Pageviews_Order_Data
GROUP BY
1;

-- $22.55 Revenue per billing page seen for the old version --
-- $38.35 for the new version
-- Lift : $15.80 per billu page page view

SELECT 
COUNT(website_session_id) AS billing_sessions_past_month
FROM website_pageviews 
WHERE website_pageviews.pageview_url IN ('/billing','/billing-2') 
	AND created_at BETWEEN '2012-10-27' AND '2012-11-27' -- past month

-- 1,194 billing sessions past month
-- Lift : $15.80 per billu page page view
-- VALUE OF BILLING TEST: $18,865.00 over the past month

