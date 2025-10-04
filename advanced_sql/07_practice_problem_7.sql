WITH remote_job_skills AS (
    SELECT
        skills_to_jobs.skill_id,
        COUNT(job_postings.job_id) AS skill_count
    FROM
        job_postings_fact AS job_postings
        INNER JOIN skills_job_dim AS skills_to_jobs ON skills_to_jobs.job_id = job_postings.job_id
    WHERE
        job_postings.job_work_from_home = TRUE
        AND job_postings.job_title_short = 'Data Engineer'
    GROUP BY
        skills_to_jobs.skill_id
)

SELECT
    skills.skill_id,
    skills.skills,
    remote_job_skills.skill_count
FROM
    skills_dim AS skills
    INNER JOIN remote_job_skills ON remote_job_skills.skill_id = skills.skill_id
ORDER BY
    remote_job_skills.skill_count DESC
LIMIT 5;
