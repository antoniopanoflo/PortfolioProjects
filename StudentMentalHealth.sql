/*

This dataset is a sample of students asked about their mental health in the country of ___. 

Depression = Whether student believes to be depressed.
Anxiety = Whether student believes to have anxiety.
Panic Attacks = Whether student claims to have periodic panic attacks.
Treatment = Whether students have chosen to seek out treatment for their condition.

*/

USE projects;

SELECT * FROM descriptions;
SELECT * FROM conditions;


/* -------------------------------------------------------------------------------------------------------------- */ 
-- Examining the data and ensuring that data is clean.

ALTER TABLE conditions
DROP COLUMN match_id
;

ALTER TABLE conditions
ADD match_id text;

SET @row_number = 0;
UPDATE conditions
SET match_id = (@row_number:=@row_number + 1);


-- Correcting capitalization on genders & respective titles on college years.
UPDATE descriptions
SET gender = 
CASE
    WHEN gender = 'female' THEN 'Female'
    WHEN gender = 'F' THEN 'Female'
    WHEN gender = 'male' THEN 'Male'
    WHEN gender = 'M' THEN 'Male'
    ELSE gender
END ;

UPDATE descriptions
SET year = 
CASE
    WHEN year = 'year 1' THEN 'First Year'
    WHEN year = 'year 2' THEN 'Sophomore'
    WHEN year = 'year 3' THEN 'Junior'
    WHEN year = 'year 4' THEN 'Senior'
    ELSE year
END ;

ALTER TABLE conditions
RENAME COLUMN `Marital Status` TO `married`;


-- Adjusting a duplicate nursing major name and trimming any other potential Majors with trim().
SELECT major, count(major)
FROM descriptions
GROUP BY major
ORDER BY 2 DESC;

UPDATE descriptions 
SET major = TRIM(major);

UPDATE descriptions 
SET gpa = TRIM(gpa);

/* ----------------------------------------------------------------------------------------------- */ 
-- Exploring the data

-- Avg age for those married?
SELECT avg(age) AS avg_age, married
FROM descriptions
JOIN conditions
	ON id = match_id
WHERE married = 'Yes'
GROUP BY married;

-- Of the students taking the 3 most popular majors, how many have 2 or more conditions? Their ratio from total students?
-- How many don't have any conditions? Their ratio from total students?
-- Using a Subquery within a CTE to extract this information.
WITH setup AS (
SELECT *,
	CASE 
    WHEN (Depression = 'Yes' AND Anxiety = 'YES') THEN 'Atleast Two' 
    WHEN (Depression = 'Yes' AND `Panic Attacks` = 'YES') THEN 'Atleast Two' 
    WHEN (Anxiety = 'Yes' AND `Panic Attacks` = 'Yes') THEN 'Atleast Two' 
    WHEN (Depression = 'NO' AND Anxiety = 'No' AND `Panic Attacks` = 'No') THEN 'No Condition'
    ELSE 'Neither' END AS Condition_Num
FROM (
SELECT Major,Year, Depression, Anxiety, `Panic Attacks`
FROM descriptions
JOIN conditions
	ON descriptions.ID = conditions.Match_ID) AS Sub
)
SELECT Major, sum(Condition_Num = 'Atleast Two') AS Two_Or_More_Conditions,
	round((sum(Condition_Num = 'Atleast Two')/count(Major)), 2) * 100 AS Percent_of_Students_With_Two_Or_More_Conditions,
    sum(Condition_Num = 'No Condition') AS Not_Sick_Count,
	round((sum(Condition_Num = 'No Condition')/count(Major)), 2) * 100 AS Percent_of_Students_With_No_Conditions,
    count(Major) AS Total_Students_In_Major
FROM setup
GROUP BY Major
ORDER BY Total_Students_In_Major DESC
LIMIT 3;

-- Top Major For Males? Females?
-- From the query below, we can see that BCS is the most popular major for Males and Engineering for Females
SELECT
    major,
    sum(Gender='Male') AS male,
    sum(Gender='Female') AS female
FROM descriptions
JOIN conditions
	ON id = match_id
GROUP BY major
ORDER BY male DESC, female DESC;

-- Which GPA range has the highest ratio of anxious students?
SELECT RANK() OVER (ORDER BY gpa DESC) AS gpa_rank, GPA, sum(anxiety = "Yes") total_students_with_anxiety, COUNT(gpa) AS total_students_in_gpa_range,
sum(anxiety = "Yes")/COUNT(gpa) * 100 AS percent_of_anxious_students
FROM descriptions
JOIN conditions
	ON id = match_id
GROUP BY gpa;

-- We can see that the higher the GPA, the more anxious the students are!
-- Could this mean that those with low GPA's have a lack of interest / those with high GPA's are worried about upkeeping their scores?
