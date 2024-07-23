use salaries_db;


/*1.Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD*/

SELECT distINct(company_locatiON) FROM salaries WHERE job_title like '%Manager%' and salary_IN_usd > 90000 and remote_ratio= 100;




/*2.Identify top 5 Country Having greatest count of large (company size) number of companies.*/

SELECT company_locatiON, COUNT(company_size) AS 'cnt' 
FROM (
    SELECT * FROM salaries WHERE experience_level ='EN' AND company_size='L'
) AS t  
GROUP BY company_locatiON 
ORDER BY cnt DESC
LIMIT 5;




/*3.Calculate the percentage of employees who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, 
Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/

set @COUNT= (SELECT COUNT(*) FROM salaries  WHERE salary_IN_usd >100000 and remote_ratio=100);
set @total = (SELECT COUNT(*) FROM salaries where salary_in_usd>100000);
set @percentage= round((((SELECT @COUNT)/(SELECT @total))*100),2);
SELECT @percentage AS '%  of people workINg remotly and havINg salary >100,000 USD';





/4.Identify the Locations where entry-level average salaries exceed the average salary for that job title IN market for entry level. */

SELECT company_locatiON, t.job_title, average_per_country, average FROM 
(
	SELECT company_locatiON,job_title,AVG(salary_IN_usd) AS average_per_country FROM  salaries WHERE experience_level = 'EN' 
	GROUP BY  company_locatiON, job_title
) AS t 
INNER JOIN 
( 
	 SELECT job_title,AVG(salary_IN_usd) AS average FROM  salaries  WHERE experience_level = 'EN'  GROUP BY job_title
) AS p 
ON  t.job_title = p.job_title WHERE average_per_country> average
    




/*5.Find out for each job title which country pays the maximum average salary.*/

SELECT company_locatiON , job_title , average FROM
(
SELECT *, dense_rank() over (partitiON by job_title order by average desc)  AS num FROM 
(
SELECT company_locatiON , job_title , AVG(salary_IN_usd) AS 'average' FROM salaries GROUP BY company_locatiON, job_title
)k
)t  WHERE num=1




/*6.Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years 
(Countries WHERE data is available for 3 years Only(present year and past two years) providing Insights into Locations 
experiencing Sustained salary growth.*/

WITH t AS
(
 SELECT * FROM  salaries WHERE company_locatiON IN
		(
			SELECT company_locatiON FROM
			(
				SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3 
			)m
		)
)  -- step 4
-- SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM 
(
SELECT company_locatiON, work_year, AVG(salary_IN_usd) AS average FROM  t GROUP BY company_locatiON, work_year 
)q GROUP BY company_locatiON  havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022 -- step 3 and havINg step 4.

         --------------------------------------
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries   group by company_location , work_year-- step 1
select  company_locatiON, work_year, AVG(salary_IN_usd) AS AVG_salary  FROM salaries  where work_year>=year(current_date())-2  group by company_location , work_year  -- step 2
SELECT company_locatiON, AVG(salary_IN_usd) AS AVG_salary,COUNT(DISTINCT work_year) AS num_years FROM salaries WHERE work_year >= YEAR(CURRENT_DATE()) - 2
				GROUP BY  company_locatiON HAVING  num_years = 3       -- STEP 3


 
 /* 7.	Determine the percentage of fully remote work for each experience level IN 2021 and compare it with the corresponding figures for 2024, Highlighting any significant Increases or decreases IN remote work Adoption over the years.*/

 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level
 
 
 
/* 8. Calculate the average salary increase percentage for each experience level and job title between the years 2023 and 2024*/

WITH t AS
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) GROUP BY experience_level, job_title, work_year
)  -- step 1



SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
	SELECT 
		experience_level, job_title,
		MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
		MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
	FROM  t GROUP BY experience_level , job_title -- step 2
)a WHERE (((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100)  IS NOT NULL -- STEP 3




 
/* 9.Implement a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) 
can only access details relevant to their respective experience level, ensuring data confidentiality and minimizing the risk 
of unauthorized access.*/

 select * from salaries
 select distinct experience_level from salaries
 Show privileges
 


CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN'

GRANT SELECT ON campusx.entry_level TO 'Entry_level'@'%'

UPDATE view entry_level set WORK_YEAR = 2025 WHERE EMPLOYNMENT_TYPE='FT'




/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences such as 
( their year of experience , their employment type, company location and company size )  and want to make an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create PROCEDURE GetAverageSalary(IN exp_lev VARCHAR(2), IN emp_type VARCHAR(3), IN comp_loc VARCHAR(2), IN comp_size VARCHAR(2))
BEGIN
    SELECT job_title, experience_level, company_location, company_size, employment_type, ROUND(AVG(salary), 2) AS avg_salary 
    FROM salaries 
    WHERE experience_level = exp_lev AND company_location = comp_loc AND company_size = comp_size AND employment_type = emp_type 
    GROUP BY experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
END//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.

call GetAverageSalary('EN','FT','AU','M')


drop procedure Getaveragesalary


/*11. Figure out how many people were employed IN different types of companies AS per their size IN 2021.

SELECT company_size, COUNT(company_size) AS 'COUNT of employees' 
FROM salaries 
WHERE work_year = 2021 
GROUP BY company_size;

/*12. 12.Identify the top 3 job titles that command the highest average salary Among part-time Positions IN the year 2023. 
However, you are Only Interested IN Countries WHERE there are more than 50 employees, Ensuring a robust sample size for your analysis.*/

SELECT job_title, AVG(salary_in_usd) AS 'average' 
FROM salaries  
WHERE employment_type = 'PT'  
GROUP BY job_title 
ORDER BY AVG(salary_IN_usd) DESC 
LIMIT 3;

/*13.Select Countries where average mid-level salary is higher than overall mid-level salary for the year 2023.*/

SET @average = (SELECT AVG(salary_IN_usd) AS 'average' FROM salaries WHERE experience_level='MI');
SELECT company_location, AVG(salary_IN_usd) 
FROM salaries 
WHERE experience_level = 'MI' AND salary_IN_usd > @average 
GROUP BY company_location;

/*14.Identify the company locations with the highest and lowest average salary for senior-level (SE) employees in 2023.*/

DELIMITER //

CREATE PROCEDURE GetSeniorSalaryStats()
BEGIN
    -- Query to find the highest average salary for senior-level employees in 2023
    SELECT company_location AS highest_location, AVG(salary_in_usd) AS highest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY highest_avg_salary DESC
    LIMIT 1;

    -- Query to find the lowest average salary for senior-level employees in 2023
    SELECT company_location AS lowest_location, AVG(salary_in_usd) AS lowest_avg_salary
    FROM  salaries
    WHERE work_year = 2023 AND experience_level = 'SE'
    GROUP BY company_location
    ORDER BY lowest_avg_salary ASC
    LIMIT 1;
END //

-- Reset the delimiter back to semicolon
DELIMITER ;

-- Call the stored procedure to get the results
CALL GetSeniorSalaryStats();


/*15.Assess the annual salary growth rate for various job titles by Calculating the percentage Increase IN salary FROM previous year to this year, aim to provide valuable Insights Into salary trends WITHIN different job roles.*/

WITH t AS    -- creating common table expression.
(
    -- Subquery to calculate average salary for each job title in 2023 and 2024
    SELECT a.job_title, average_2023, average_2024 FROM
    (
        -- Subquery to calculate average salary for each job title in 2023
        SELECT job_title , AVG(salary_IN_usd) AS average_2023 
        FROM salaries 
        WHERE work_year = 2023 
        GROUP BY job_title
    ) a
    -- Inner join with subquery to calculate average salary for each job title in 2024
    INNER JOIN
    (
        -- Subquery to calculate average salary for each job title in 2024
        SELECT job_title , AVG(salary_IN_usd) AS average_2024 
        FROM salaries 
        WHERE work_year = 2024 
        GROUP BY job_title
    ) b ON a.job_title = b.job_title
)
-- Final query to calculate percentage change in salary from 2023 to 2024 for each job title
SELECT *, ROUND((((average_2024-average_2023)/average_2023)*100),2) AS 'percentage_change' 
FROM t;


/* 16.List the top three Countries with the highest salary growth rate FROM 2020 to 2023, Considering Only companies with more than 50 employees. */

WITH t AS   -- creating CTE
(
    -- Subquery to calculate average salary for entry-level roles in 2021 and 2023
    SELECT 
        company_location, 
        work_year, 
        AVG(salary_in_usd) as average 
    FROM 
        salaries 
    WHERE 
        experience_level = 'EN' 
        AND (work_year = 2021 OR work_year = 2023)
    GROUP BY  
        company_location, 
        work_year
)
-- Main query to calculate percentage change in salary from 2021 to 2023 for each country
SELECT 
    *, 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) AS changes
FROM
(
    -- Subquery to pivot the data and calculate average salary for each country in 2021 and 2023
    SELECT 
        company_location,
        MAX(CASE WHEN work_year = 2021 THEN average END) AS AVG_salary_2021,
        MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023
    FROM 
        t 
    GROUP BY 
        company_location
) a 
-- Filter out null values and select the top three countries with the highest salary growth rate
WHERE 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) IS NOT NULL  
ORDER BY 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) DESC 
    limit 3 ;


/* 17.Picture yourself as a data architect responsible for database management. 
Companies in US and AU(Australia) decided to create a hybrid model for employees they decided that employees 
earning salaries exceeding $90000 USD, will be given work from home. 
You now need to update the remote work ratio for eligible employees, ensuring efficient remote work management 
while implementing appropriate error handling mechanisms for invalid input parameters. */


 create  table camp  as select * from   salaries;  -- creating temporary table so that changes are not made in actual table as actual table is being used in other cases also.
 
 -- by default mysql runs on safe update mode , this mode  is a safeguard against updating
 -- or deleting large portion of  a table.
 -- We will turn off safe update mode using set_sql_safe_updates
 
SET SQL_SAFE_UPDATES = 0;
 

UPDATE camp 
SET remote_ratio = 100
WHERE (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;

select * from camp where (company_location = 'AU' OR company_location ='US')AND salary_in_usd > 90000;


/* 18.In the year 2024, due to increased demand in the data industry, there was an increase in salaries of data field employees.
a.Entry Level-35% of the salary.
b.Mid junior – 30% of the salary.
c.Immediate senior level- 22% of the salary.
d.Expert level- 20% of the salary.
e.Director – 15% of the salary.
Update the salaries accordingly and update them back in the original database.*/

UPDATE camp
SET salary_in_usd = 
    CASE 
        WHEN experience_level = 'EN' THEN salary_in_usd * 1.35  -- Increase salary for Entry Level by 35%
        WHEN experience_level = 'MI' THEN salary_in_usd * 1.30  -- Increase salary for Mid Junior by 30%
        WHEN experience_level = 'SE' THEN salary_in_usd * 1.22  -- Increase salary for Immediate Senior Level by 22%
        WHEN experience_level = 'EX' THEN salary_in_usd * 1.20  -- Increase salary for Expert Level by 20%
        WHEN experience_level = 'DX' THEN salary_in_usd * 1.15  -- Increase salary for Director by 15%
        ELSE salary_in_usd  -- Keep salary unchanged for other experience levels
    END
WHERE work_year = 2024;  -- Update salaries only for the year 2024


/*19.Find the year with the highest average salary for each job title. */

WITH avg_salary_per_year AS 
(
    -- Calculate the average salary for each job title in each year
    SELECT work_year, job_title, AVG(salary_in_usd) AS avg_salary 
    FROM salaries
    GROUP BY work_year, job_title
)

SELECT job_title, work_year, avg_salary FROM 
    (
       -- Rank the average salaries for each job title in each year
       SELECT job_title, work_year, avg_salary, RANK() OVER (PARTITION BY job_title ORDER BY avg_salary DESC) AS rank_by_salary
	   FROM avg_salary_per_year
    ) AS ranked_salary
WHERE 
    rank_by_salary = 1; -- Select the records where the rank of average salary is 1 (highest)
    
    
    
/*20.You have been hired by a market research agency where you been assigned the task to show the percentage of different 
employment type (full time, part time) in Different job roles, in the format where each row will be job title, each column 
will be type of employment type and cell value for that row and column will show the % value. */
