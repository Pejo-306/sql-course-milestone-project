/*
Question 3: What are the most in-demand skills for Data Engineers?
-- Join job postings to inner join table, similar to query 2;
-- Identify the top 5 in-demand skills for a Data Engineer;
-- Focus on all job postings;
-- Why? Retrieves the top 5 skills with the highest demand in the job market,
        providing insights into the most valuable skills for job seekers;
*/

SELECT
    skills.skills,
    COUNT(jobs.job_id) AS demand_count
FROM
    skills_dim AS skills
    INNER JOIN skills_job_dim AS skills_to_job ON skills.skill_id = skills_to_job.skill_id
    INNER JOIN job_postings_fact AS jobs ON skills_to_job.job_id = jobs.job_id
WHERE
    jobs.job_title_short = 'Data Engineer'
--     AND jobs.job_work_from_home = TRUE  -- Optional: check only for remote jobs
GROUP BY
    skills.skills
ORDER BY
    demand_count DESC
LIMIT 5;