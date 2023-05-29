USE mavenfuzzyfactory;
SELECT DISTINCT(website_pageviews.pageview_url) 
FROM website_pageviews
WHERE website_pageviews.created_at < '2014-04-10'
		AND website_pageviews.created_at > '2013-01-06';
SELECT
website_pageviews.pageview_url,
COUNT(DISTINCT website_pageviews.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_pageviews.website_session_id)*100),2) AS Sessions_to_Order_cnv_Rate
FROM website_pageviews
LEFT JOIN orders
	ON 	orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at BETWEEN '2013-02-01' AND '2013-03-01'
AND website_pageviews.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
GROUP BY
website_pageviews.pageview_url;

SELECT * FROM products;

-- Assignment Product Pathing Analysis --
WITH Product_Page_View AS
(SELECT
website_pageviews.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.created_at,
website_pageviews.pageview_url,
CASE
WHEN website_pageviews.created_at < '2013-01-06' THEN 'A.Pre_Product_2'
WHEN website_pageviews.created_at >= '2013-01-06' THEN 'B.Post_Product_2'
ELSE 'Need to Check' END AS Time_Period
FROM website_pageviews
	WHERE website_pageviews.created_at > '2012-10-06'
		AND website_pageviews.created_at < '2013-04-06'
        AND website_pageviews.pageview_url = '/products'
),
Product_Page_View_Session_id AS
(SELECT
Product_Page_View.Time_Period,
Product_Page_View.website_session_id,
MIN(website_pageviews.website_pageview_id) AS Next_Page_View_id
FROM Product_Page_View
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = Product_Page_View.website_session_id
		AND website_pageviews.website_pageview_id > Product_Page_View.website_pageview_id
GROUP BY
	1,2),
Product_Page_View_Session_url AS 
(SELECT
Product_Page_View_Session_id.Time_Period,
Product_Page_View_Session_id.website_session_id,
website_pageviews.pageview_url AS Next_Page_Url
FROM Product_Page_View_Session_id
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = Product_Page_View_Session_id.Next_Page_View_id)
SELECT
Product_Page_View_Session_url.Time_Period AS Time_Period_Segment,
COUNT(DISTINCT Product_Page_View_Session_url.website_session_id) AS Sessions,
COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url IS NOT NULL THEN Product_Page_View_Session_url.website_session_id ELSE NULL END) AS Next_Page_Sessions,
ROUND((COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url IS NOT NULL THEN Product_Page_View_Session_url.website_session_id ELSE NULL END)/
COUNT(DISTINCT Product_Page_View_Session_url.website_session_id)*100),2) AS Next_Page_Session_cnv_Rate,
COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url = '/the-original-mr-fuzzy' THEN Product_Page_View_Session_url.website_session_id ELSE NULL END) AS Mrfuzzy_Page_Sessions,
ROUND((COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url = '/the-original-mr-fuzzy' THEN Product_Page_View_Session_url.website_session_id ELSE NULL END)/
COUNT(DISTINCT Product_Page_View_Session_url.website_session_id)*100),2) AS Mrfuzzy_Page_Session_cnv_Rate,
COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url = '/the-forever-love-bear' THEN Product_Page_View_Session_url.website_session_id ELSE NULL END) AS Forever_love_Bear_Page_Sessions,
ROUND((COUNT(DISTINCT CASE WHEN Product_Page_View_Session_url.Next_Page_Url = '/the-forever-love-bear' THEN Product_Page_View_Session_url.website_session_id ELSE NULL END)/
COUNT(DISTINCT Product_Page_View_Session_url.website_session_id)*100),2) AS Forever_love_Bear_Page_Session_cnv_Rate
FROM Product_Page_View_Session_url
GROUP BY
	1;


-- ASSGNMENT: Product level Conversion Funnel --
WITH Sessions_Seen_Product_Page AS
(SELECT
website_pageviews.website_session_id,
website_pageviews.website_pageview_id,
website_pageviews.pageview_url AS Product_Page_Seen
FROM website_pageviews
	WHERE website_pageviews.created_at < '2014-04-10'
		AND website_pageviews.created_at > '2013-01-06'
        AND website_pageviews.pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
),
Page_View_url AS
(SELECT DISTINCT
website_pageviews.pageview_url
FROM Sessions_Seen_Product_Page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = Sessions_Seen_Product_Page.website_session_id),
Page_View_level AS
(SELECT
Sessions_Seen_Product_Page.website_session_id,
Sessions_Seen_Product_Page.Product_Page_Seen,
CASE WHEN website_pageviews.pageview_url = '/cart' THEN 1 ELSE 0 END AS Cart_Page,
CASE WHEN website_pageviews.pageview_url = '/shipping' THEN 1 ELSE 0 END AS Shipping_Page,
CASE WHEN website_pageviews.pageview_url = '/billing-2' THEN 1 ELSE 0 END AS Billing_Page,
CASE WHEN website_pageviews.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS Thankyou_Page
FROM Sessions_Seen_Product_Page
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = Sessions_Seen_Product_Page.website_session_id
        AND website_pageviews.website_pageview_id > Sessions_Seen_Product_Page.website_pageview_id
	ORDER BY
		Sessions_Seen_Product_Page.website_session_id,
        website_pageviews.created_at
),
Session_product_level_made_it_flags AS
(
SELECT
website_session_id,
CASE
WHEN Product_Page_Seen = '/the-original-mr-fuzzy' THEN 'Mrfuzzy'
WHEN Product_Page_Seen = '/the-forever-love-bear' THEN 'Love_you_bear'
ELSE 'N/A' END AS Product_Seen,
MAX(Cart_Page) AS Cart_made_it,
MAX(Shipping_Page) AS Shipping_made_it,
MAX(Billing_Page) AS Billing_made_it,
MAX(Thankyou_Page) AS Thankyou_made_it
FROM Page_View_level
GROUP BY
	1,2
),
Product_to_Next_Page_Conversion AS
(SELECT
Product_Seen,
COUNT(DISTINCT website_session_id) AS Sessions,
COUNT(DISTINCT CASE WHEN Cart_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Cart,
COUNT(DISTINCT CASE WHEN Shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Shipping,
COUNT(DISTINCT CASE WHEN Billing_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Billing,
COUNT(DISTINCT CASE WHEN Thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS To_Thankyou
FROM Session_product_level_made_it_flags
GROUP BY
	Product_Seen
ORDER BY
	2 DESC
)
SELECT
Product_Seen,
Sessions,
To_Cart,
To_Shipping,
To_Billing,
To_Thankyou,
ROUND(((To_Cart/Sessions)*100),2) AS Product_page_click_rate,
ROUND(((To_Shipping/To_Cart)*100),2) AS Cart_Page_click_rate,
ROUND(((To_Billing/To_Shipping)*100),2) AS Shipping_Page_click_rate,
ROUND(((To_Thankyou/To_Billing)*100),2) AS Billing_Page_click_rate
FROM Product_to_Next_Page_Conversion
	GROUP BY
		Product_Seen;

