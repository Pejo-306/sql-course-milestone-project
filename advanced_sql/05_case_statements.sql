SELECT
    job_title_short,
    job_location,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
LIMIT 100;

SELECT
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
GROUP BY
    location_category;

-- Problem 1:
SELECT
    job_id,
    job_title_short,
    job_title,
    salary_year_avg,
    CASE
        WHEN salary_year_avg >= 100000.0    THEN 'High Salary'
        WHEN salary_year_avg >= 60000.0     THEN 'Standard Salary'
        WHEN salary_year_avg < 60000.0      THEN 'Low Salary'
    END AS salary_category
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 100;

-- Problem 2:
SELECT
    COUNT(DISTINCT companies.name),
    CASE
        WHEN job_postings.job_work_from_home = TRUE  THEN 'WFH'
        WHEN job_postings.job_work_from_home = FALSE THEN 'Onsite'
    END AS job_location_category
FROM
    job_postings_fact AS job_postings
    INNER JOIN company_dim AS companies ON job_postings.company_id = companies.company_id
GROUP BY
    job_location_category;

SELECT
    COUNT(DISTINCT CASE WHEN job_work_from_home = TRUE THEN company_id END) AS wfh_companies,
    COUNT(DISTINCT CASE WHEN job_work_from_home = FALSE THEN company_id END) AS non_wfh_companies
FROM
    job_postings_fact;

-- Problem 3:
SELECT
    job_id,
    salary_year_avg,
    CASE
        WHEN job_title ILIKE '%Senior%' THEN 'Senior'
        WHEN job_title ILIKE '%Manager%' OR job_title ILIKE '%Lead%' THEN 'Lead/Manager'
        WHEN job_title ILIKE '%Junior%' OR job_title ILIKE '%Entry%' THEN 'Junior/Entry'
        ELSE 'Not Specified'
    END AS experience_level,
    CASE
        WHEN job_work_from_home = TRUE THEN 'Yes'
        ELSE 'No'
    END AS remote_option
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
ORDER BY
    job_id ASC
LIMIT 100;
