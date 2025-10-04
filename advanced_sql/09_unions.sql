(
    SELECT
        job_title_short,
        company_id,
        job_location
    FROM
        january_jobs
    LIMIT 100
)

UNION ALL

(
    SELECT
        job_title_short,
        company_id,
        job_location
    FROM
        february_jobs
    LIMIT 100
)

UNION ALL

(
    SELECT
        job_title_short,
        company_id,
        job_location
    FROM
        march_jobs
    LIMIT 100
)

/*
Problem 1:
  Create a unified query that categorizes job postings into two groups:
  those with salary information (salary_year_avg or salary_hour_avg is not null)
  and those without it. Each job posting should be listed with its job_id, job_title,
  and an indicator of whether salary information is provided.
Solution:
  - query1: select all job postings where there is salary information & mark them
  - query2: select all job postings where there is NO salary information & mark them
  - union all both queries
*/

(
    SELECT
        job_id,
        job_title,
        salary_hour_avg,
        salary_year_avg,
        TRUE AS has_salary_information
    FROM
        job_postings_fact
    WHERE
        salary_year_avg IS NOT NULL
        OR salary_hour_avg IS NOT NULL
)
UNION ALL
(
    SELECT
        job_id,
        job_title,
        salary_hour_avg,
        salary_year_avg,
        FALSE AS has_salary_information
    FROM
        job_postings_fact
    WHERE
        salary_year_avg IS NULL
        AND salary_hour_avg IS NULL
)
LIMIT 1000;


/*
Problem 2:
  Retrieve the job id, job title short, job location, job via, skill and skill type
  for each job posting from the first quarter (January to March). 
  Using a subquery to combine job postings from the first quarter
  (these tables were created in the Advanced Section - Practice Problem 6 Video)
  Only include postings with an average yearly salary greater than $70,000.
Solution:
  - query1: select fields from january jobs
  - query2: select fields from february jobs
  - query3: select fields from march jobs
  - union all queries 1-3
  - select fields from subquery of union all where salary > 70k
  - left join to skills_dim and retrieve needed info
*/

SELECT
    q1_jobs.job_id,
    q1_jobs.job_title_short,
    q1_jobs.job_location,
    q1_jobs.job_via,
    skills.skills,
    skills.type
FROM
    (
        SELECT * FROM january_jobs
        UNION ALL
        SELECT * FROM february_jobs
        UNION ALL
        SELECT * FROM march_jobs
    ) AS q1_jobs
    LEFT JOIN skills_job_dim AS skills_to_job ON q1_jobs.job_id = skills_to_job.job_id
    LEFT JOIN skills_dim AS skills ON skills_to_job.skill_id = skills.skill_id
WHERE
    q1_jobs.salary_year_avg > 70000
ORDER BY
    q1_jobs.job_id
LIMIT 400;


/*
Problem 3:
  Analyze the monthly demand for skills by counting the number of job postings
  for each skill in the first quarter (January to March),
  utilizing data from separate tables for each month.
  Ensure to include skills from all job postings across these months.
  The tables for the first quarter job postings were created in Practice Problem 6.
Solution:
  - subquery: union all fields from q1 job posting tables
  - query: skills_dim left join subquery group by skill, count # of job_postings
*/

WITH q1_jobs AS (
    SELECT job_id, job_posted_date FROM january_jobs
    UNION ALL
    SELECT job_id, job_posted_date FROM february_jobs
    UNION ALL
    SELECT job_id, job_posted_date FROM march_jobs
)

SELECT
    skills.skills AS skill,
    EXTRACT(YEAR FROM q1_jobs.job_posted_date) AS posted_year,
    EXTRACT(MONTH FROM q1_jobs.job_posted_date) AS posted_month,
    COUNT(q1_jobs.job_id) AS job_count
FROM
    skills_dim AS skills
    INNER JOIN skills_job_dim AS skills_to_job ON skills.skill_id = skills_to_job.skill_id
    INNER JOIN q1_jobs ON skills_to_job.job_id = q1_jobs.job_id
GROUP BY
    skill,
    posted_year,
    posted_month
ORDER BY
    skill ASC,
    posted_year ASC,
    posted_month ASC;