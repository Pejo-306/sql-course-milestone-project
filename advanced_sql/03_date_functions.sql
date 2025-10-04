SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date,
    job_posted_date AT TIME ZONE 'UTC' AS utc_date,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM
    job_postings_fact
LIMIT 10;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS month
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    month
ORDER BY
    job_posted_count DESC;

-- Problem 1
SELECT
    job_schedule_type,
    ROUND(AVG(salary_year_avg), 2) AS average_yearly_salary,
    ROUND(AVG(salary_hour_avg), 2) AS average_hourly_salary
FROM
    job_postings_fact
WHERE
    -- EXTRACT(MONTH FROM job_posted_date) >= 6
    job_posted_date::date > '2023-06-01'
GROUP BY
    job_schedule_type
ORDER BY
    job_schedule_type ASC;

-- Problem 2
SELECT
    EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS posted_month,
    COUNT(job_id) AS job_postings_count
FROM
    job_postings_fact
GROUP BY
    posted_month
ORDER BY
    posted_month ASC;

-- Problem 3
SELECT
    companies.name AS company_name,
    COUNT(job_postings.job_id) AS job_postings_count
FROM
    job_postings_fact AS job_postings
    INNER JOIN company_dim AS companies ON job_postings.company_id = companies.company_id
WHERE
    EXTRACT(MONTH FROM job_postings.job_posted_date) BETWEEN 4 AND 6
    AND job_postings.job_health_insurance = TRUE
GROUP BY
    companies.name
ORDER BY
    job_postings_count DESC;