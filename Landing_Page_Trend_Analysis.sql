USE mavenfuzzyfactory;

CREATE TEMPORARY TABLE Session_Min_PV_id_And_Count
SELECT
website_sessions.website_session_id,
MIN(website_pageviews.website_pageview_id) AS First_Page_View_Id,
COUNT(website_pageviews.website_pageview_id) AS No_Of_Page_Views
FROM website_sessions
LEFT JOIN website_pageviews
	ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE website_sessions.created_at > '2012-06-01' 
	AND website_sessions.created_at < '2012-08-31'
    AND website_sessions.utm_source = 'gsearch'
    and website_sessions.utm_campaign = 'nonbrand'
GROUP BY
	website_sessions.website_session_id
;

CREATE TEMPORARY TABLE Sessions_W_Counts_Lander_and_Created_at
SELECT
Session_Min_PV_id_And_Count.website_session_id,
Session_Min_PV_id_And_Count.First_Page_View_Id,
Session_Min_PV_id_And_Count.No_Of_Page_Views,
website_pageviews.pageview_url AS Landing_Page,
website_pageviews.created_at AS Session_Created_at
FROM Session_Min_PV_id_And_Count
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = Session_Min_PV_id_And_Count.website_session_id
;

SELECT
MIN(DATE(Session_Created_at)) AS Week_Start_Date,
-- COUNT(DISTINCT website_session_id) AS Total_Session,
-- COUNT(DISTINCT CASE WHEN No_Of_Page_Views = 1 THEN website_session_id ELSE NULL END) AS Bounced_Sessions,
(COUNT(DISTINCT CASE WHEN No_Of_Page_Views = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)*100) AS Bounce_Rate,
COUNT(DISTINCT CASE WHEN Landing_Page = '/home' THEN website_session_id ELSE NULL END) AS Home_Sessions,
COUNT(DISTINCT CASE WHEN Landing_Page = '/lander-1' THEN website_session_id ELSE NULL END) AS Lander_Sessions
FROM Sessions_W_Counts_Lander_and_Created_at
GROUP BY
	YEARWEEK(Session_Created_at)
;
