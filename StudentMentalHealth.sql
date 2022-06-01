/*

Exploring insights into the mental health of college students in a foreign country.
Data can be found at:
https://www.kaggle.com/datasets/shariful07/student-mental-health

Depression = Whether student believes to be depressed.
Anxiety = Whether student believes to have anxiety.
Panic Attacks = Whether student claims to have periodic panic attacks.
Treatment = Whether students have chosen to seek out treatment for their condition.

use projects;

select * from mentalhealth;


/* -------------------------------------------------------------------------------------------------------------- */ 
-- Examining the data and ensuring that data is clean.

select * from mentalhealth;

ALTER TABLE mentalhealth 
DROP COLUMN Timestamp,
DROP COLUMN MyUnknownColumn;

-- Correcting capitalization on genders & respective titles on college years.
UPDATE mentalhealth
SET Gender = 
CASE
    WHEN Gender = 'female' THEN 'Female'
    WHEN Gender = 'F' THEN 'Female'
    WHEN Gender = 'male' THEN 'Male'
    WHEN Gender = 'M' THEN 'Male'
    ELSE Gender
END ;

UPDATE mentalhealth
SET Year = 
CASE
    WHEN Year = 'year 1' THEN 'First Year'
    WHEN Year = 'year 2' THEN 'Sophomore'
    WHEN Year = 'year 3' THEN 'Junior'
    WHEN Year = 'year 4' THEN 'Senior'
    ELSE Year
END ;

ALTER TABLE mentalhealth
RENAME COLUMN `Marital Status` TO `Married`;


-- Adjusting a duplicate nursing major name and trimming any other potential Majors with trim().
Select Major, count(Major)
from mentalhealth
group by Major
order by 2 desc;

UPDATE mentalhealth 
SET Major = TRIM(Major);

-- Verifying that there are now two student counts under the same Nursing program.
SELECT Major, count(Major)
FROM mentalhealth
GROUP BY Major
ORDER BY 2 DESC;


/* ----------------------------------------------------------------------------------------------- */ 
-- Exploring the data


-- Adding row index
ALTER TABLE mentalhealth
ADD Row_Num int;

SET @row_number = 0;
UPDATE mentalhealth
SET Row_Num = (@row_number:=@row_number + 1);

#ALTER TABLE mentalhealth
#DROP COLUMN Row_Num;

-- Avg age for those married?
SELECT avg(Age), Married
FROM mentalhealth
WHERE Married = 'Yes'
GROUP BY Married;


-- Of the students taking the 3 most popular majors, how many have 2 or more conditions?
-- Using a Subquery within a CTE to extract this information

WITH Conditions AS (
SELECT *,
	CASE 
    	WHEN (Depression = 'Yes' AND         Anxiety = 'YES') THEN 'Yes' 
    	WHEN (Depression = 'Yes' AND `Panic Attacks` = 'YES') THEN 'Yes' 
	WHEN (Anxiety = 'Yes' 	 AND `Panic Attacks` = 'Yes') THEN 'Yes'  
	ELSE 'No' END AS Two_Or_More
FROM(
SELECT Major,Year, Depression, Anxiety, `Panic Attacks`
FROM mentalhealth
ORDER BY Major DESC) AS Sub
)
SELECT Major, sum(Two_Or_More = 'Yes') AS Two_Or_More_Conditions, count(Major) AS Total_Students_In_Major,
	round((sum(Two_Or_More = 'Yes')/count(Major)), 2) AS Percent_of_Students_With_Two_Or_More_Conditions
FROM Conditions
GROUP BY Major
ORDER BY Total_Students_In_Major DESC
LIMIT 3;


-- Top Major For Males? Females?
-- From the query below, we can see that BCS is the most popular major for Males and Engineering for Females
SELECT
    Major,
    sum(Gender='Male') as Male,
    sum(Gender='Female') as Female
FROM mentalhealth
GROUP BY Major
ORDER BY Male DESC, Female DESC;
