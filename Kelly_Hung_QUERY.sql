-- Checking if there are NULL values
-- Since there are none, no database alteration needed
SELECT * 
FROM vw_ALL 
WHERE User_Name IS NULL
    OR User_Age IS NULL
    OR User_Gender IS NULL
    OR Platform_Name IS NULL
    OR Entry_Date IS NULL
    OR Created_Date IS NULL
    OR Mental_State IS NULL
    OR Sleep_Hours IS NULL
    OR Physical_Activity_Min IS NULL
    OR Social_Media_Min IS NULL
    OR Daily_Screen_Time_Min IS NULL
    OR Positive_Interaction IS NULL
    OR Negative_Interaction IS NULL
    OR Mood_Level IS NULL
    OR Anxiety_Level IS NULL
    OR Stress_Level IS NULL;

-- UNDERSTANDING THE DATABASE --

-- Seeing the distribution of the age groups
-- There is more data on young adults ages 20-29 with a count of 38
SELECT 
	COUNT(*),
    Age_Group
FROM vw_AGE_GROUPS
GROUP BY Age_Group;

-- There is an even distribution of Male and Female
-- Other has a lower count reflecting smaller representation in the dataset
SELECT
	User_Gender,
	COUNT(User_Gender) AS Gender_Count
FROM USERS
GROUP BY User_Gender;

-- Even distribution (ranging from 15-17 rows) besides Youtube (11) and WhatsApp (9)
SELECT
	p.Platform_Name,
	COUNT(us.Record_ID) AS Count
FROM PLATFORMS p
INNER JOIN USER_SESSIONS us
	ON p.Platform_ID = us.Platform_ID
GROUP BY Platform_Name
ORDER BY Count DESC;

-- Distribution of mental states
-- At_Risk (2), Healthy(6), Stressed (92)
-- Stressed is by far the most common mental state
SELECT 
	ms.Mental_State,
	COUNT(us.Record_ID) AS 'Count'
FROM MENTAL_STATES ms
INNER JOIN USER_SESSIONS us
	ON ms.Mental_State_ID = us.Mental_State_ID
GROUP BY ms.Mental_State;

-- Queries for insights --
-- Ultimately I want to understand 

-- Average physical activity by gender and age group
/* 
Female and Male older adults had highest average physical activity
followed by middle aged, adults, teens, then young adult. Overall there
is a pattern of oldest age having highest physical activity and females having
slightly higher averages than male (when it comes to middle age and older). 
But, there is one exception for Other Young Adult whose physical activity 
is much more than teens (23.00 vs 16.5, 15.71, 15.00).
*/
SELECT
	u.User_Gender,
    ag.Age_Group,
	ROUND(AVG(al.Physical_Activity_Min),2) AS Avg_Physical_Activity_Min
FROM USER_SESSIONS us
INNER JOIN ACTIVITY_LOGS al 
	ON us.Record_ID = al.Record_ID
INNER JOIN USERS u
	ON us.User_ID = u.User_ID
INNER JOIN vw_AGE_GROUPS ag
	ON u.User_ID = ag.User_ID
GROUP BY User_Gender, Age_Group
ORDER BY Avg_Physical_Activity_Min DESC;

-- Counting the number of positive and negative interactions per platform
-- Youtube and Instagram have the highest Positive to Negative Ratio 3.5 and 3.00
SELECT
	p.Platform_Name,
    SUM(s.Positive_Interaction) AS Positive_Interaction_Total,
    SUM(s.Negative_Interaction) AS Negative_Interaction_Total,
    ROUND(SUM(s.Positive_Interaction)/SUM(s.Negative_Interaction),2) AS 'Positive to Negative Ratio'
FROM PLATFORMS p
INNER JOIN USER_SESSIONS us 
	ON p.Platform_ID = us.Platform_ID
INNER JOIN SOCIAL_INTERACTIONS s
	ON us.Record_ID = s.Record_ID
GROUP BY Platform_Name
ORDER BY SUM(s.Positive_Interaction)/SUM(s.Negative_Interaction) DESC;

-- Same code as before, but filtering for lower ratios
-- Twitter, TikTok, Facebook have the lowest Positive Negative Ratio 1.46, 1.40, 1.38
-- Social media platforms with lower ratio could possibly contribute to more negative health outcomes
SELECT
	p.Platform_Name,
    SUM(s.Positive_Interaction) AS Positive_Interaction_Total,
    SUM(s.Negative_Interaction) AS Negative_Interaction_Total,
    ROUND(SUM(s.Positive_Interaction)/SUM(s.Negative_Interaction),2) AS 'Positive to Negative Ratio'
FROM PLATFORMS p
INNER JOIN USER_SESSIONS us 
	ON p.Platform_ID = us.Platform_ID
INNER JOIN SOCIAL_INTERACTIONS s
	ON us.Record_ID = s.Record_ID
GROUP BY Platform_Name
HAVING ROUND(SUM(s.Positive_Interaction)/SUM(s.Negative_Interaction),2) < 2
ORDER BY SUM(s.Positive_Interaction)/SUM(s.Negative_Interaction) DESC;

-- Stressed and At_Risk mental states have higher screen time hours and higher social media hours compared to Healthy
WITH Avg_Screen_Time AS (
	SELECT
		ms.Mental_State,
        ROUND(AVG(al.Daily_Screen_Time_Min)/60,2) AS Avg_Screen_Time_Hrs,
        ROUND(AVG(al.Social_Media_Min)/60,2) AS Avg_Social_Media_Hrs
	FROM USER_SESSIONS us
    INNER JOIN MENTAL_STATES ms
		ON us.Mental_State_ID = ms.Mental_State_ID
	INNER JOIN ACTIVITY_LOGS al
		ON us.Record_ID = al.Record_ID
	GROUP BY ms.Mental_State
)
SELECT * FROM Avg_Screen_Time
ORDER BY Avg_Screen_Time_Hrs DESC;

-- Seeing how many users have screen time above average (via count and percentage)
-- 64.89% of users exceed the average daily screen time
-- Distribution for this variable is left skewed where a small number of low screen time users pull average downward
-- More users have higher screen time than mean suggests
SELECT 
    COUNT(us.User_ID) AS Users_Above_Avg,
    ROUND(COUNT(us.User_ID) * 100.0 / 
    (SELECT COUNT(User_ID) FROM USERS), 2) AS 'Percent of people above average screen time'
FROM USER_SESSIONS us
INNER JOIN ACTIVITY_LOGS al 
	ON us.Record_ID = al.Record_ID
WHERE al.Daily_Screen_Time_Min > (SELECT AVG(Daily_Screen_Time_Min) FROM ACTIVITY_LOGS);

-- Using view created from before
/*
TikTok has the highest proportion of ~65% meaning Tiktok users are more likely 
to spend most of their screen time on there. On average, WhatsApp users spend only
~25% of their screen time on the platform
*/
SELECT * FROM vw_PLATFORM_USAGE
ORDER BY Social_Media_To_Screen_Time_Proportion DESC;