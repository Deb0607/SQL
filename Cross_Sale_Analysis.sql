/* Assignment-1: Cross Sell Analysis */

WITH Session_Seeing_Cart AS
(
SELECT
CASE 
WHEN website_pageviews.created_at < '2013-09-25' THEN 'A.Pre_Cross_Sell'
WHEN website_pageviews.created_at >= '2013-09-25' THEN 'B.Post_Cross_Sell'
ELSE 'N/A' END AS Time_Preiod,
website_pageviews.created_at,
website_pageviews.website_session_id AS Cart_Session_id,
website_pageviews.website_pageview_id AS Cart_Page_View_id
FROM website_pageviews
WHERE website_pageviews.created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND website_pageviews.pageview_url = '/cart'
),Session_Seeing_Another_Page AS
(SELECT
Session_Seeing_Cart.Time_Preiod,
Session_Seeing_Cart.Cart_Session_id,
MIN(website_pageviews.website_pageview_id) AS Next_Page_View_id
FROM Session_Seeing_Cart
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = Session_Seeing_Cart.Cart_Session_id
        AND website_pageviews.website_pageview_id > Session_Seeing_Cart.Cart_Page_View_id
	GROUP BY
		1,2
	HAVING
		Next_Page_View_id IS NOT NULL
), Pre_post_sessions_orders AS
(SELECT
Session_Seeing_Cart.Time_Preiod,
Session_Seeing_Cart.Cart_Session_id,
orders.order_id,
orders.items_purchased,
orders.price_usd AS Order_Value
FROM Session_Seeing_Cart
	INNER JOIN orders
		ON orders.website_session_id = Session_Seeing_Cart.Cart_Session_id
), Full_Data AS
(SELECT
Session_Seeing_Cart.Time_Preiod,
Session_Seeing_Cart.Cart_Session_id,
CASE WHEN Session_Seeing_Another_Page.Cart_Session_id IS NULL THEN 0 ELSE 1 END AS Clicked_to_another_page,
CASE WHEN Pre_post_sessions_orders.Cart_Session_id IS NULL THEN 0 ELSE 1 END AS Placed_Order,
Pre_post_sessions_orders.items_purchased,
Pre_post_sessions_orders.Order_Value
FROM Session_Seeing_Cart
	LEFT JOIN Session_Seeing_Another_Page
		ON Session_Seeing_Cart.Cart_Session_id = Session_Seeing_Another_Page.Cart_Session_id
	LEFT JOIN Pre_post_sessions_orders
		ON Session_Seeing_Cart.Cart_Session_id = Pre_post_sessions_orders.Cart_Session_id
	ORDER BY
		2)
SELECT
Time_Preiod,
COUNT(DISTINCT Cart_Session_id) AS Cart_sessions,
SUM(Clicked_to_another_page) AS Click_to_another_Page,
ROUND((SUM(Clicked_to_another_page)/COUNT(DISTINCT Cart_Session_id)*100),2) AS Cart_cnv_Rate,
SUM(Placed_Order) AS Orders_Placed,
SUM(items_purchased) AS Products_Purchased,
ROUND(SUM(items_purchased)/SUM(Placed_Order),2) AS Products_per_Order,
SUM(Order_Value) AS Revenue,
ROUND(SUM(Order_Value)/SUM(Placed_Order),2) AS Avarage_Order_Value,
ROUND(SUM(Order_Value)/COUNT(DISTINCT Cart_Session_id),2) AS Revenue_per_cert_session
FROM Full_Data
GROUP BY
	1