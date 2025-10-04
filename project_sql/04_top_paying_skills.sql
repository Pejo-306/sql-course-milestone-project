/*
Question: What are the top skills based on Data Engineering salaries?
-- Look at the average salary associated with each skill for Data Engineer positions;
-- Focus on roles with specified salaries (drop NULLs), regardless of location;
-- Why? It reveals how different skills impact salary levels for Data Engineers
        and helps identify the most financially rewarding skills to acquire or improve;
*/

SELECT
    skills.skills,
    ROUND(AVG(jobs.salary_year_avg), 2) AS average_salary
FROM
    skills_dim AS skills
    INNER JOIN skills_job_dim AS skills_to_job ON skills.skill_id = skills_to_job.skill_id
    INNER JOIN job_postings_fact AS jobs ON skills_to_job.job_id = jobs.job_id
WHERE
    jobs.job_title_short = 'Data Engineer'
    AND jobs.salary_year_avg IS NOT NULL
--     AND jobs.job_work_from_home = TRUE  -- Optional: check only for remote jobs
GROUP BY
    skills.skills
ORDER BY
    average_salary DESC
LIMIT 25;
