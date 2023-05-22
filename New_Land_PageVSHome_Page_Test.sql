USE mavenfuzzyfactory;

SELECT 
MIN(created_at) AS First_Created_Date,
MIN(website_pageview_id) AS First_Page_ID
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL
;



CREATE TEMPORARY TABLE Fisrt_Test_PageViwes
SELECT
website_pageviews.website_session_id,
MIN(website_pageviews.website_pageview_id) AS PV_ID
FROM website_pageviews
INNER JOIN website_sessions
	ON website_sessions.website_session_id = website_pageviews.website_session_id
	-- AND website_pageviews.pageview_url IN ('/home','/lander-1')
	AND website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
    AND website_pageviews.created_at < '2012-07-28'
    AND website_pageviews.website_pageview_id > '23504'
GROUP BY
	website_pageviews.website_session_id
    ;
CREATE TEMPORARY TABLE  Nonbrand_Test_Session_Landing_Page
SELECT
Fisrt_Test_PageViwes.website_session_id,
website_pageviews.pageview_url AS Landing_Page
FROM Fisrt_Test_PageViwes
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = Fisrt_Test_PageViwes.PV_ID
WHERE website_pageviews.pageview_url IN ('/home','/lander-1')
;

-- SELECT * FROM Session_Landing_Page_Demo;
CREATE TEMPORARY TABLE Bounced_Sessions_Test
SELECT
Nonbrand_Test_Session_Landing_Page.website_session_id,
Nonbrand_Test_Session_Landing_Page.Landing_page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS Number_of_Page_Viewed
FROM Nonbrand_Test_Session_Landing_Page
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = Nonbrand_Test_Session_Landing_Page.website_session_id
GROUP BY
	Nonbrand_Test_Session_Landing_Page.website_session_id,
    Nonbrand_Test_Session_Landing_Page.Landing_page
HAVING Number_of_Page_Viewed = 1
;

SELECT
Nonbrand_Test_Session_Landing_Page.Landing_page,
Nonbrand_Test_Session_Landing_Page.website_session_id AS Sessions,
Bounced_Sessions_Test.website_session_id AS Bounced_Sessions
FROM Nonbrand_Test_Session_Landing_Page
LEFT JOIN Bounced_Sessions_Test
	ON Bounced_Sessions_Test.website_session_id = Nonbrand_Test_Session_Landing_Page.website_session_id;

SELECT
Nonbrand_Test_Session_Landing_Page.Landing_page,
COUNT(DISTINCT Nonbrand_Test_Session_Landing_Page.website_session_id) AS Sessions,
COUNT(DISTINCT Bounced_Sessions_Test.website_session_id) AS Bounced_Sessions,
ROUND((COUNT(DISTINCT Bounced_Sessions_Test.website_session_id)/COUNT(DISTINCT Nonbrand_Test_Session_Landing_Page.website_session_id)*100),2) AS Bounce_Cnv_Rate
FROM Nonbrand_Test_Session_Landing_Page
LEFT JOIN Bounced_Sessions_Test
	ON Bounced_Sessions_Test.website_session_id = Nonbrand_Test_Session_Landing_Page.website_session_id
GROUP BY
Nonbrand_Test_Session_Landing_Page.Landing_page
;

