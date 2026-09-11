-- View of all variables
CREATE VIEW vw_ALL AS
SELECT 
    u.User_Name,
    u.User_Age,
    u.User_Gender,
    p.Platform_Name,
    us.Entry_Date,
    ms.Mental_State,
    al.Sleep_Hours,
    al.Physical_Activity_Min,
    al.Social_Media_Min,
    al.Daily_Screen_Time_Min,
    si.Positive_Interaction,
    si.Negative_Interaction,
    mhr.Mood_Level,
    mhr.Anxiety_Level,
    mhr.Stress_Level
FROM USER_SESSIONS us
JOIN USERS u ON us.User_ID = u.User_ID
JOIN PLATFORMS p ON us.Platform_ID = p.Platform_ID
JOIN MENTAL_STATES ms ON us.Mental_State_ID = ms.Mental_State_ID
JOIN ACTIVITY_LOGS al ON us.Record_ID = al.Record_ID
JOIN SOCIAL_INTERACTIONS si ON us.Record_ID = si.Record_ID
JOIN MENTAL_HEALTH_RECORDS mhr ON us.Record_ID = mhr.Record_ID;

-- View of average usage for each platform and average usage users of the specific platform are on social media
CREATE VIEW vw_PLATFORM_USAGE AS
SELECT
	Platform_Name, 
	ROUND(AVG(Social_Media_Min)/60,2) AS Avg_Social_Media_Hrs, 
	ROUND(AVG(Daily_Screen_Time_Min)/60,2) AS Avg_Screen_Time_Hrs
FROM vw_ALL
GROUP BY Platform_Name;

-- Expanding on the previous View, vw_PLATFORM_USAGE, I think it's helpful to see proportion
-- Updating the View
CREATE OR REPLACE VIEW vw_PLATFORM_USAGE AS
SELECT 
	Platform_Name,
    ROUND(AVG(Social_Media_Min)/60,2) AS Avg_Social_Media_Hrs, 
    ROUND(AVG(Daily_Screen_Time_Min)/60,2) AS Avg_Screen_Time_Hrs,
    ROUND((AVG(Social_Media_Min)/AVG(Daily_Screen_Time_Min)) *100,2) AS Social_Media_To_Screen_Time_Proportion
FROM vw_ALL
GROUP BY Platform_Name;

-- Creating a view of age groups and binning them
-- Checking age range before creating age groups
SELECT 
	MIN(User_Age) AS Min_Age,
    MAX(User_Age) AS Max_Age
FROM USERS;

CREATE VIEW vw_AGE_GROUPS AS 
	SELECT 
		User_ID,
        User_Name,
        User_Age,
        User_Gender,
		CASE 
			WHEN User_Age BETWEEN 13 AND 19 THEN 'Teen (13-19)'
			WHEN User_Age BETWEEN 20 AND 29 THEN 'Young Adult (20-29)'
			WHEN User_Age BETWEEN 30 AND 39 THEN 'Adult (30-39)'
			WHEN User_Age BETWEEN 40 AND 49 THEN 'Middle Aged (40-49)'
			WHEN User_Age BETWEEN 50 AND 69 THEN 'Older Adult (50-69)'
		END AS Age_Group
	FROM USERS;