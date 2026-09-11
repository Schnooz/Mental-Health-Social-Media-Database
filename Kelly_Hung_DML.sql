-- Loading in the csv file, I named it Mental_Health_Raw
SELECT * FROM Mental_Health_Raw;

/*
Main Strat:
1) Add independent tables to generate IDs accordingly
2) Add all ID columns to Mental_Health_Raw
2) Adding generated IDs to Mental_Health_Raw
3) Generate Record_ID by adding to USER_SESSIONS (main table for merging)
4) Add Record_ID to Mental_Health_Raw and update tables that use Record_ID
*/

-- Start with small, independent tables: MENTAL_STATES, PLATFORMS, USERS
INSERT INTO MENTAL_STATES (Mental_State)
SELECT DISTINCT Mental_State
FROM Mental_Health_Raw;

INSERT INTO PLATFORMS (Platform_Name)
SELECT DISTINCT platform
FROM Mental_Health_Raw;

INSERT INTO USERS (User_Name, User_Age, User_Gender)
SELECT DISTINCT person_name, age, gender
FROM Mental_Health_Raw;

-- Add ID rows to Mental_Health_Raw
ALTER TABLE Mental_Health_Raw
ADD Record_ID INT,
ADD Mental_State_ID INT,
ADD Platform_ID INT,
ADD User_ID INT;

-- Updating Mental_Health_Raw with IDs from tables with generated IDs
UPDATE Mental_Health_Raw r
JOIN USERS u 
	ON u.User_Name = r.person_name
	AND u.User_Age = r.age
    AND u.User_Gender = r.gender
SET r.User_ID = u.User_ID;

UPDATE Mental_Health_Raw r
JOIN MENTAL_STATES ms ON ms.Mental_State= r.mental_state
SET r.Mental_State_ID = ms.Mental_State_ID;

UPDATE Mental_Health_Raw r
JOIN PLATFORMS p ON p.Platform_Name =r.platform
SET r.Platform_ID = p.Platform_ID;

-- Generating Record_ID by updating USER_SESSIONS
INSERT INTO USER_SESSIONS (User_ID, Mental_State_ID, Platform_ID, Entry_Date)
SELECT User_ID, Mental_State_ID, Platform_ID, date
FROM Mental_Health_Raw;

-- Updating Record_ID in Mental_Health_Raw
UPDATE Mental_Health_Raw r
JOIN USER_SESSIONS us 
	ON us.User_ID = r.User_ID
    AND us.Mental_State_ID = r.Mental_State_ID
    AND us.Platform_ID = r.Platform_ID
    AND us.Entry_Date = r.date
SET r.Record_ID = us.Record_ID;

-- Updating tables linked to Record_ID
INSERT INTO MENTAL_HEALTH_RECORDS (Record_ID, Mood_Level, Anxiety_Level, Stress_Level)
SELECT Record_ID, mood_level, anxiety_level, stress_level
FROM Mental_Health_Raw;

INSERT INTO SOCIAL_INTERACTIONS(Record_ID, Positive_Interaction, Negative_Interaction)
SELECT Record_ID, positive_interactions_count, negative_interactions_count
FROM Mental_Health_Raw;

INSERT INTO ACTIVITY_LOGS (Record_ID, Sleep_Hours, Physical_Activity_Min, Social_Media_Min, Daily_Screen_Time_Min)
SELECT Record_ID, sleep_hours, physical_activity_min, social_media_time_min, daily_screen_time_min
FROM Mental_Health_Raw;