SELECT
    *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS january_jobs
LIMIT 100;

WITH january_jobs AS (
    SELECT
        *
    FROM 
        job_postings_fact
    WHERE
        EXTRACT(MONTH FROM job_posted_date) = 1
)

SELECT
    *
FROM
    january_jobs
LIMIT 100;

SELECT
    company_id,
    job_no_degree_mention
FROM
    job_postings_fact
WHERE
    job_no_degree_mention = TRUE
LIMIT 100;

SELECT
    name AS company_name
FROM
    company_dim
WHERE
    company_id IN (
        SELECT
            company_id
        FROM
            job_postings_fact
        WHERE
            job_no_degree_mention = TRUE
        LIMIT 100
    );

WITH company_job_count AS (
    SELECT
        company_id,
        COUNT(*) AS total_jobs
    FROM
        job_postings_fact
    GROUP BY
        company_id
)

SELECT
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM
    company_dim
    LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY
    company_job_count.total_jobs DESC;

-- Problem 1:
WITH top_skills AS (
    SELECT
        skill_id,
        COUNT(job_id) AS skill_count
    FROM
        skills_job_dim AS skills_to_jobs
    GROUP BY
        skill_id
    ORDER BY
        skill_count DESC
    LIMIT 5
)

SELECT
    skills.skill_id,
    skills.skills,
    top_skills.skill_count
FROM
    skills_dim AS skills
    INNER JOIN top_skills ON top_skills.skill_id = skills.skill_id
ORDER BY
    top_skills.skill_count DESC;

-- Problem 2:
SELECT
    companies.name,
    sub_counted_jobs.jobs_count,
    CASE
        WHEN sub_counted_jobs.jobs_count > 50 THEN 'Large'
        WHEN sub_counted_jobs.jobs_count >= 10 THEN 'Medium'  -- 10 <= jobs_count <= 50
        WHEN sub_counted_jobs.jobs_count < 10 THEN 'Small'
    END AS size_category
FROM
    (
        SELECT
            company_id,
            COUNT(job_id) AS jobs_count
        FROM
            job_postings_fact
        GROUP BY
            company_id
    ) AS sub_counted_jobs
    INNER JOIN company_dim AS companies ON sub_counted_jobs.company_id = companies.company_id;

SELECT
    company_id,
    company_name,
    CASE
        WHEN jobs_count > 50 THEN 'Large'
        WHEN jobs_count >= 10 THEN 'Medium'  -- 10 <= jobs_count <= 50
        WHEN jobs_count < 10 THEN 'Small'
    END AS company_size
FROM
    (
        SELECT
            companies.company_id,
            companies.name AS company_name,
            COUNT(jobs.job_id) AS jobs_count
        FROM
            job_postings_fact AS jobs
            INNER JOIN company_dim AS companies ON companies.company_id = jobs.company_id
        GROUP BY
            companies.company_id,
            companies.name
    ) AS company_job_count;

-- Problem 3
-- Problem: Find the names of companies that have an average salary
--          greater than the overall average salary across all job postings
-- Solution:
--  subquery#1 to find the average salary across all job postings
--  subquery#2 to find the average salary for each company
--  query to filter subquery#2 by average company salary > average job salary 

-- subquery#2: find the average company salary
SELECT
    companies.name AS company_name,
    AVG(jobs.salary_year_avg) AS average_company_salary
FROM
    company_dim AS companies
    INNER JOIN job_postings_fact AS jobs ON jobs.company_id = companies.company_id
WHERE
    jobs.salary_year_avg IS NOT NULL
GROUP BY
    company_name
ORDER BY
    average_company_salary DESC;

-- subquery #1: find the avearge salary across all job postings
SELECT
    AVG(salary_year_avg) AS average_job_salary
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL;

-- query: filter subquery#2 by the result of subquery #1
SELECT
    company_name,
    average_company_salary
FROM
    ( -- subquery #2
        SELECT
            companies.name AS company_name,
            AVG(jobs.salary_year_avg) AS average_company_salary
        FROM
            company_dim AS companies
            INNER JOIN job_postings_fact AS jobs ON jobs.company_id = companies.company_id
        WHERE
            jobs.salary_year_avg IS NOT NULL
        GROUP BY
            company_name
    ) AS sub_company_salaries
WHERE
    average_company_salary > (  -- subquery#1
        SELECT
            AVG(salary_year_avg) AS average_job_salary
        FROM
            job_postings_fact
        WHERE
            salary_year_avg IS NOT NULL
    )
ORDER BY
    average_company_salary DESC;

-- alternative solution: join company_dim with average salaries in main query

SELECT
    companies.name AS company_name,
    sub_company_salaries.average_company_salary
FROM
    company_dim AS companies
    INNER JOIN ( -- subquery #2
        SELECT
            company_id,
            AVG(salary_year_avg) AS average_company_salary
        FROM
            job_postings_fact
        WHERE
            salary_year_avg IS NOT NULL
        GROUP BY
            company_id
    ) AS sub_company_salaries ON sub_company_salaries.company_id = companies.company_id
WHERE
    sub_company_salaries.average_company_salary > (  -- subquery#1
        SELECT
            AVG(salary_year_avg) AS average_job_salary
        FROM
            job_postings_fact
        WHERE
            salary_year_avg IS NOT NULL
    )
ORDER BY
    sub_company_salaries.average_company_salary DESC;