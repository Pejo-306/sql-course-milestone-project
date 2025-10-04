/*
Question 5: What are the most optimal skills to learn
            (aka it's in high demand AND a high-paying skill)?
-- Identify skills in high demand and associated with high average salaries for Data Engineer roles;
-- Focus on remote positiions with specified salaries;
-- Why? Target skills that offer job security (high demand) and financial benefits (high salaries),
        offering strategic insights for career development in data analysis;
*/

-- Solution 1: get seperate result sets for demand count and average salaries,
--             then join together in a query
WITH
    skills_demand AS (
        SELECT
            skills_to_job.skill_id,
            COUNT(jobs.job_id) AS demand_count
        FROM
            job_postings_fact AS jobs
            INNER JOIN skills_job_dim AS skills_to_job ON skills_to_job.job_id = jobs.job_id
        WHERE
            jobs.job_title_short = 'Data Engineer'
            AND jobs.salary_year_avg IS NOT NULL
            AND job_work_from_home = TRUE
        GROUP BY
            skills_to_job.skill_id
    ),
    average_salaries AS (
        SELECT
            skills_to_job.skill_id,
            ROUND(AVG(jobs.salary_year_avg), 2) AS average_salary
        FROM
            job_postings_fact AS jobs
            INNER JOIN skills_job_dim AS skills_to_job ON skills_to_job.job_id = jobs.job_id
        WHERE
            jobs.job_title_short = 'Data Engineer'
            AND jobs.salary_year_avg IS NOT NULL
            AND job_work_from_home = TRUE
        GROUP BY
            skills_to_job.skill_id
    )

SELECT
    skills.skill_id,
    skills.skills,
    skills_demand.demand_count,
    average_salaries.average_salary
FROM
    skills_dim AS skills
    INNER JOIN skills_demand ON skills.skill_id = skills_demand.skill_id
    INNER JOIN average_salaries ON skills_demand.skill_id = average_salaries.skill_id
WHERE
    skills_demand.demand_count >= 10
ORDER BY
    average_salaries.average_salary DESC,
    skills_demand.demand_count DESC
LIMIT 25;


-- Solution 2: Find the demand count and average salaries inside a single query
SELECT
    skills.skill_id,
    skills.skills,
    COUNT(jobs.job_id) AS demand_count,
    ROUND(AVG(jobs.salary_year_avg), 2) AS average_salary
FROM
    skills_dim AS skills
    INNER JOIN skills_job_dim AS skills_to_job ON skills.skill_id = skills_to_job.skill_id
    INNER JOIN job_postings_fact AS jobs ON skills_to_job.job_id = jobs.job_id
WHERE
    jobs.job_title_short = 'Data Engineer'
    AND jobs.salary_year_avg IS NOT NULL
    AND jobs.job_work_from_home = TRUE
GROUP BY
    skills.skill_id,
    skills.skills
HAVING
    COUNT(jobs.job_id) >= 10  -- demand for skill >= 10, so we avoid one-off outliers
ORDER BY
    average_salary DESC,
    demand_count DESC
LIMIT 25;