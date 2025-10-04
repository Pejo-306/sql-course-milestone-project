-- Problem 1: Find the top 10 copmanies with the most diverse job titles
WITH cte_unique_jobs AS (
    SELECT
        companies.name AS company_name,
        jobs.company_id,
        COUNT(DISTINCT jobs.job_title) AS unique_job_titles
    FROM
        job_postings_fact AS jobs
        INNER JOIN company_dim AS companies ON companies.company_id = jobs.company_id
    GROUP BY
        jobs.company_id,
        company_name
)

SELECT
    company_name,
    unique_job_titles
FROM
    cte_unique_jobs
ORDER BY
    unique_job_titles DESC
LIMIT 10;

-- Problem 2: Explore job postings by listing job id, job titles, company names, 
--            and their average salary rates, while categorizing these salaries
--            relative to the average in their respective countries.
--            Include the month of the job posted date. Use CTEs, conditional logic,
--            and date functions, to compare individual salaries with national averages.
-- Solution:
-- cte: find average salaries by country
-- case statement: categorize job salary as above average / below average / exceptionally high (2x+)
-- extract month from job posted date
-- query: join job_postings_fact with cte + select fields + categorize by case statement + extract date


-- TODO: consider whether we should drop NULL job_country fields (yes, those are remote jobs)
-- TODO: consider whether we should keep country groups with NULL yearly salary
--       (no, there is no reliable way to calculate the yearly salary)
--       (therefore, it doesn't make sense to even compare salaries)
WITH average_country_salaries AS (
    SELECT
        job_country AS country,
        AVG(salary_year_avg) AS average_salary
    FROM
        job_postings_fact
    WHERE
        salary_year_avg IS NOT NULL
    GROUP BY
        job_country
)

SELECT
    jobs.job_id,
    jobs.job_title,
    companies.name AS company_name,
    jobs.job_country,
    jobs.salary_year_avg,
    CASE
        WHEN jobs.salary_year_avg >= 2 * country_salaries.average_salary THEN 'Exceptionally High'
        WHEN jobs.salary_year_avg >= country_salaries.average_salary THEN 'Above Average'
        ELSE 'Average'
    END AS salary_expectations,
    EXTRACT(MONTH FROM jobs.job_posted_date) AS posted_month
FROM
    job_postings_fact AS jobs
    INNER JOIN average_country_salaries AS country_salaries ON country_salaries.country = jobs.job_country
    INNER JOIN company_dim AS companies ON companies.company_id = jobs.company_id
WHERE
    salary_year_avg IS NOT NULL
ORDER BY
    jobs.job_country DESC,
    jobs.salary_year_avg DESC
LIMIT 100;


-- Problem 3: Calculate two metrics for each company
--            1) number of unique skills for their job postings
--            2) highest average annual salary among their job postings, which require minimum 1 skills
--            Return company name, number of unique skills, highest salary
--            If company has no skill related job postings, skill_count = 0 & salary = NULL
-- Solution:
--   cte1: create a table with company_id & skill_id via job_postings_fact (use left join)
--         then group by company_id & count distinct skill_ids
--   cte2: job_postings_fact -> group by company_id, get max yearly_salary
--         having unique skill count >= 1
--   query: join ctes & select relevant fields

WITH
    required_skills AS (
        SELECT
            companies.company_id,
            COUNT(DISTINCT skills_to_job.skill_id) AS unique_skills
        FROM
            company_dim AS companies
            LEFT JOIN job_postings_fact AS jobs ON companies.company_id = jobs.company_id
            LEFT JOIN skills_job_dim AS skills_to_job ON skills_to_job.job_id = jobs.job_id
        GROUP BY
            companies.company_id
    ),
    max_salaries AS (
        SELECT
            jobs.company_id,
            MAX(jobs.salary_year_avg) AS annual_max_salary
        FROM
            job_postings_fact AS jobs
            INNER JOIN required_skills ON jobs.company_id = required_skills.company_id
        WHERE
            required_skills.unique_skills > 0
        GROUP BY
            jobs.company_id
    )

SELECT
    companies.name AS company_name,
    required_skills.unique_skills,
    max_salaries.annual_max_salary AS highest_average_annual_salary 
FROM
    company_dim AS companies
    INNER JOIN required_skills ON required_skills.company_id = companies.company_id
    LEFT JOIN max_salaries ON max_salaries.company_id = companies.company_id
ORDER BY
    highest_average_annual_salary DESC NULLS LAST
LIMIT 400;

