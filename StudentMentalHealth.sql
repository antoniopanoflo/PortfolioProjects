/*

This dataset is a sample of students asked about their mental health in the country of ___. 

Depression = Whether student believes to be depressed.
Anxiety = Whether student believes to have anxiety.
Panic Attacks = Whether student claims to have periodic panic attacks.
Treatment = Whether students have chosen to seek out treatment for their condition.

*/

use projects;

select * from descriptions;
select * from conditions;


/* -------------------------------------------------------------------------------------------------------------- */ 
-- Examining the data and ensuring that data is clean.

ALTER TABLE conditions
DROP COLUMN Match_ID;

ALTER TABLE conditions
ADD Match_ID text;

SET @row_number = 0;
UPDATE conditions
SET Match_ID = (@row_number:=@row_number + 1);


-- Correcting capitalization on genders & respective titles on college years.
UPDATE descriptions
SET Gender = 
CASE
    WHEN Gender = 'female' THEN 'Female'
    WHEN Gender = 'F' THEN 'Female'
    WHEN Gender = 'male' THEN 'Male'
    WHEN Gender = 'M' THEN 'Male'
    ELSE Gender
END ;

UPDATE descriptions
SET Year = 
CASE
    WHEN Year = 'year 1' THEN 'First Year'
    WHEN Year = 'year 2' THEN 'Sophomore'
    WHEN Year = 'year 3' THEN 'Junior'
    WHEN Year = 'year 4' THEN 'Senior'
    ELSE Year
END ;

ALTER TABLE conditions
RENAME COLUMN `Marital Status` TO `Married`;


-- Adjusting a duplicate nursing major name and trimming any other potential Majors with trim().
SELECT Major, count(Major)
FROM descriptions
GROUP BY Major
ORDER BY 2 DESC;

UPDATE descriptions 
SET Major = TRIM(Major);

UPDATE descriptions 
SET GPA = TRIM(GPA);

/* ----------------------------------------------------------------------------------------------- */ 
-- Exploring the data

-- Avg age for those married?
SELECT avg(Age) AS Avg_Age, Married
FROM descriptions
JOIN conditions
	ON ID = Match_ID
WHERE Married = 'Yes'
GROUP BY Married;

-- Of the students taking the 3 most popular majors, how many have 2 or more conditions? Their ratio from total students?
-- Using a Subquery within a CTE to extract this information.
WITH setup AS (
SELECT *,
	CASE 
    WHEN (Depression = 'Yes' AND  Anxiety        = 'YES') THEN 'Yes' 
    WHEN (Depression = 'Yes' AND `Panic Attacks` = 'YES') THEN 'Yes' 
    WHEN (Anxiety    = 'Yes' AND `Panic Attacks` = 'Yes') THEN 'Yes'  ELSE 'No' END AS Two_Or_More
FROM (
SELECT Major,Year, Depression, Anxiety, `Panic Attacks`
FROM descriptions
JOIN conditions
	ON descriptions.ID = conditions.Match_ID) AS Sub
)
SELECT Major, sum(Two_Or_More = 'Yes') AS Two_Or_More_Conditions, count(Major) AS Total_Students_In_Major,
	round((sum(Two_Or_More = 'Yes')/count(Major)), 2) * 100 AS Percent_of_Students_With_Two_Or_More_Conditions
FROM setup
GROUP BY Major
ORDER BY Total_Students_In_Major DESC
LIMIT 3;

-- Of the students taking the 3 most popular majors, how many don't have any conditions?
WITH Condition_Free AS (
SELECT *,
	CASE 
    WHEN (Depression = 'NO' AND Anxiety = 'No' AND `Panic Attacks` = 'No') THEN 'True'
    ELSE 'False' END AS NotSick
FROM(
SELECT Major,Year, Depression, Anxiety, `Panic Attacks`
FROM descriptions
JOIN conditions
	ON descriptions.ID = conditions.Match_ID) as Sub
)
SELECT Major, sum(NotSick = 'True') as Not_Sick_Count , count(Major) as Total_Students_In_Major
FROM Condition_Free
GROUP BY Major
ORDER BY Total_Students_In_Major DESC
LIMIT 3;

-- Top Major For Males? Females?
-- From the query below, we can see that BCS is the most popular major for Males and Engineering for Females
SELECT
    Major,
    sum(Gender='Male') as Male,
    sum(Gender='Female') as Female
FROM descriptions
JOIN conditions
	ON ID = Match_ID
GROUP BY Major
ORDER BY Male DESC, Female DESC;

-- Which GPA range has the highest ratio of anxious students?
SELECT RANK() OVER (ORDER BY GPA DESC) as GPA_Rank, GPA, sum(Anxiety = "Yes") Total_Students_With_Anxiety, count(GPA) as Total_Students_In_GPA_Range,
sum(Anxiety = "Yes")/count(GPA) * 100 as Percent_of_Anxious_Students
FROM descriptions
JOIN conditions
	ON ID = Match_ID
GROUP BY GPA;

-- We can see that the higher the GPA, the more anxious the students are!
-- Could this mean that those with low GPA's have a lack of interest / those with high GPA's are worried about upkeeping their scores?
