use mavenfuzzyfactory;

SELECT
website_sessions.utm_content,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Ordered,
(COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100) AS Session_to_Order_cnv_Rate
FROM website_sessions
LEFT JOIN orders
	ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-02-01'
GROUP BY
1
ORDER BY Sessions
;

-- Assignment-1: Analyzing Channel Protfolio
SELECT * FROM website_sessions;
SELECT
MIN(DATE(website_sessions.created_at)) AS Week_Start_Date,
COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Gsearch_Sessions,
COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS Bsearch_Sessions,
COUNT(DISTINCT website_sessions.website_session_id) AS Total_Sessions
FROM website_sessions
WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-11-29'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	YEARWEEK(website_sessions.created_at)
;

-- Assignment-2: Comparing Channel Protfolio
Select * from website_sessions;
SELECT
utm_source,
COUNT(DISTINCT website_session_id) AS Total_Sessions,
COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS Mobile_Sessions,
(COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)*100) AS Pct_Mobile
FROM website_sessions
WHERE website_sessions.created_at > '2012-08-22'
	AND website_sessions.created_at < '2012-11-30'
    AND website_sessions.utm_campaign = 'nonbrand'
    -- AND website_sessions.utm_source IN ('gsearch','bsearch')
GROUP BY
	utm_source
;

-- Assignment-3: Cross Channel Bid Optimization -- 

SELECT 
website_sessions.device_type AS Device_Type,
website_sessions.utm_source AS UTM_Source,
COUNT(DISTINCT website_sessions.website_session_id) AS Sessions,
COUNT(DISTINCT orders.order_id) AS Orders,
ROUND((COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100),2) AS Conv_Rate
FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at > '2012-08-22'
    AND website_sessions.created_at < '2012-09-19'
   AND  website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	Device_Type, UTM_Source
;
-- Device Type: Desktop ,utm_source : gsearch order conversion rate is 4.52 % -- 

-- Assignment-4: Analyzing Channel Portfolio Trends -- 
SELECT
-- YEARWEEK(website_sessions.created_at),
MIN(DATE(website_sessions.created_at)) AS Week_Start_Date,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS g_dtop_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS b_dtop_sessions,
ROUND((COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END)*100),2) AS b_pct_of_gdtop,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS g_mob_sessions,
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS b_mob_sessions,
ROUND((COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END)*100),2) AS b_pct_of_mdtop
FROM website_sessions
WHERE website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at > '2012-11-04'
    AND website_sessions.created_at < '2012-12-22'
GROUP BY
	YEARWEEK(website_sessions.created_at)
;
    
-- Analyzing Direct Traffic --
SELECT
CASE
	WHEN http_referer IS NULL THEN 'direct_type_in'
    WHEN http_referer = 'https://www.gsearch.com' THEN 'gsearch_organic'
    WHEN http_referer = 'https://www.bsearch.com' THEN 'bsearch_organic'
    ELSE 'Others' 
    END AS Search_Type,
    COUNT(DISTINCT website_sessions.website_session_id) AS Sessions
FROM website_sessions
-- WHERE website_sessions.website_session_id BETWEEN 100000 AND 115000
	-- AND website_sessions.utm_source IS NULL
GROUP BY
	Search_Type
ORDER BY
	2 DESC;
    
-- Assignment-5: Analyzing Direct Traffic --

SELECT DISTINCT
CASE
	WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'Organic_Search'
    WHEN website_sessions.utm_campaign = 'nonbrand' THEN 'Paid_nonbrand'
    WHEN website_sessions.utm_campaign = 'brand' THEN 'Paid_brand'
    WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN 'Direct_Type'
    END AS Channel_Group,
website_sessions.utm_source,
website_sessions.utm_campaign,
website_sessions.http_referer
FROM website_sessions
WHERE website_sessions.created_at < '2012-12-23'