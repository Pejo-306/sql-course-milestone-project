/* Question 1: What are the top-paying jobs for my role?
-- Identify the top 10 highest paying Data Engeineer roles that are available remotely;
-- Focus on job postings with specified salaries (remove nulls);
-- Why? Highlight the top-paying opportunities for Data Engineers,
   offering insights into employment opportunities
*/

SELECT
    jobs.job_id,
    jobs.job_title,
    companies.name AS company_name,
    jobs.job_location,
    jobs.job_schedule_type,
    jobs.salary_year_avg,
    jobs.job_posted_date
FROM
    job_postings_fact AS jobs
    LEFT JOIN company_dim AS companies ON jobs.company_id = companies.company_id
WHERE
    jobs.job_title_short = 'Data Engineer'
    AND jobs.job_location = 'Anywhere'  -- remote jobs
    AND jobs.salary_year_avg IS NOT NULL
ORDER BY
    jobs.salary_year_avg DESC
LIMIT 10;

