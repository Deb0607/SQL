SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url,
MIN(website_pageview_id) AS First_PV_Id
FROM website_pageviews
WHERE created_at < '2012-06-14'
	AND website_pageviews.pageview_url = '/home'
GROUP BY
	website_pageviews.website_session_id
;

CREATE TEMPORARY TABLE First_PageView_Per_Session_Demo
SELECT
website_pageviews.website_session_id,
website_pageviews.pageview_url,
MIN(website_pageview_id) AS First_PV_Id
FROM website_pageviews
WHERE created_at < '2012-06-14'
	AND website_pageviews.pageview_url = '/home'
GROUP BY
	website_pageviews.website_session_id
;
CREATE TEMPORARY TABLE Session_Landing_Page_Demo
SELECT
First_PageView_Per_Session_Demo.website_session_id,
website_pageviews.pageview_url AS Landing_Page
FROM First_PageView_Per_Session_Demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_pageview_id = First_PageView_Per_Session_Demo.First_PV_Id
;

-- CREATE TEMPORARY TABLE Bounced_Sessions
SELECT 
Session_Landing_Page_Demo.website_session_id,
Session_Landing_Page_Demo.Landing_Page,
COUNT(DISTINCT website_pageviews.website_pageview_id) AS Count_of_Page_Viewed
FROM Session_Landing_Page_Demo
LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = Session_Landing_Page_Demo.website_session_id
GROUP BY
	Session_Landing_Page_Demo.website_session_id,
	Session_Landing_Page_Demo.Landing_Page
-- HAVING Count_of_Page_Viewed = 1
;

SELECT
Session_Landing_Page_Demo.Landing_Page,
Session_Landing_Page_Demo.website_session_id,
Bounced_Sessions.website_session_id AS Bounce_Session_Id
FROM Session_Landing_Page_Demo
LEFT JOIN Bounced_Sessions
	ON Bounced_Sessions.website_session_id = Session_Landing_Page_Demo.website_session_id
ORDER BY Session_Landing_Page_Demo.website_session_id
;

SELECT
Session_Landing_Page_Demo.Landing_Page,
COUNT(DISTINCT Session_Landing_Page_Demo.website_session_id) AS Sessions,
COUNT(DISTINCT Bounced_Sessions.website_session_id) AS Bounced_Sessions,
ROUND((COUNT(DISTINCT Bounced_Sessions.website_session_id)/COUNT(DISTINCT Session_Landing_Page_Demo.website_session_id)*100),2) AS Home_Page_Bounce_Rate
FROM Session_Landing_Page_Demo
LEFT JOIN Bounced_Sessions
	ON Bounced_Sessions.website_session_id = Session_Landing_Page_Demo.website_session_id
GROUP BY
Session_Landing_Page_Demo.Landing_Page
;

SELECT