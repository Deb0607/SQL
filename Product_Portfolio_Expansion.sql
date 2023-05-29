SELECT * FROM orders;
SELECT
CASE
WHEN website_sessions.created_at < '2013-12-12' THEN 'A.Pre_Birthday_Bear_Product'
WHEN website_sessions.created_at >= '2013-12-12' THEN 'B.Post_Birthday_Bear_Product'
ELSE 'N/A' END AS Time_Preoid,
-- COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
-- COUNT(DISTINCT orders.order_id) AS Orders,
ROUND(COUNT(DISTINCT website_sessions.website_session_id)/COUNT(DISTINCT orders.order_id),2) AS Order_Cnv_rate,
-- SUM(orders.price_usd) AS Total_Revenue,
-- SUM(orders.items_purchased) AS Total_product_sold,
ROUND(SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id),2) AS Avg_order_value,
ROUND(SUM(orders.items_purchased)/COUNT(DISTINCT orders.order_id),2) AS Products_per_order,
ROUND(SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id),2) AS Revenue_per_sessions
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY
	Time_Preoid
