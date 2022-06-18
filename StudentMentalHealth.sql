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
-- Using a Subquery within a CTE to extract this information.
WITH setup AS (
SELECT *,
    CASE 
    WHEN (depression = 'Yes' AND  anxiety        = 'YES') THEN 'Yes' 
    WHEN (depression = 'Yes' AND `panic attacks` = 'YES') THEN 'Yes' 
    WHEN (anxiety    = 'Yes' AND `panic attacks` = 'Yes') THEN 'Yes'  ELSE 'No' END AS two_or_more
FROM (
SELECT major,year, depression, anxiety, `panic attacks`
FROM descriptions
JOIN conditions
	ON descriptions.id = conditions.match_id) AS sub
)
SELECT major, sum(two_or_more = 'Yes') AS two_or_more_conditions, COUNT(major) AS total_students_in_major,
	round((sum(two_or_more = 'Yes')/COUNT(major)), 2) * 100 AS percent_of_students_with_two_or_more_conditions
FROM setup
GROUP BY major
ORDER BY total_students_in_major DESC
LIMIT 3;

-- Of the students taking the 3 most popular majors, how many don't have any conditions?
WITH condition_free AS (
SELECT *,
	CASE 
    WHEN (depression = 'NO' AND anxiety = 'No' AND `panic attacks` = 'No') THEN 'True'
    ELSE 'False' END AS notsick
FROM(
SELECT major,year, depression, anxiety, `panic attacks`
FROM descriptions
JOIN conditions
	ON descriptions.id = conditions.match_id) AS Sub
)
SELECT major, sum(notsick = 'True') AS not_sick_Count , COUNT(major) AS total_students_in_major
FROM condition_free
GROUP BY major
ORDER BY total_students_in_major DESC
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
