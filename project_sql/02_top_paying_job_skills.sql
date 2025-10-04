/* Question 2: What skills are required for these top paying Data Engineer jobs?
-- Use the top 10 highest-paying Data Engineer jobs from first query
-- Add the specific skills required for these roles
-- Why? It provides a detailed look at which high-paying jobs demand certain skills,
        helping job seekers understand which skills to develop that align with top salaries
*/

WITH top_paying_jobs AS (
    SELECT
        jobs.job_id,
        jobs.job_title,
        companies.name AS company_name,
        jobs.salary_year_avg
    FROM
        job_postings_fact AS jobs
        LEFT JOIN company_dim AS companies ON jobs.company_id = companies.company_id
    WHERE
        jobs.job_title_short = 'Data Engineer'
        AND jobs.job_location = 'Anywhere'  -- remote jobs
        AND jobs.salary_year_avg IS NOT NULL
    ORDER BY
        jobs.salary_year_avg DESC
    LIMIT 10
)

SELECT
    jobs.*,
    skills.skills
FROM
    top_paying_jobs AS jobs
    INNER JOIN skills_job_dim AS job_to_skills ON jobs.job_id = job_to_skills.job_id
    INNER JOIN skills_dim AS skills ON job_to_skills.skill_id = skills.skill_id
ORDER BY
    jobs.salary_year_avg DESC;


/*
Here’s a quick breakdown of insights from the skill column for the top 10 data engineer jobs in 2023:

🧠 Most In-Demand Skills
| Rank | Skill                                                                       | Mentions |
| ---- | --------------------------------------------------------------------------- | -------- |
| 1    | **Python**                                                                  | 7        |
| 2    | **Spark**                                                                   | 5        |
| 3    | **Hadoop**, **Kafka**, **Scala**                                            | 3 each   |
| 4    | **Pandas**, **NumPy**, **PySpark**, **Kubernetes**, **SQL**, **Databricks** | 2 each   |

🚀 Key Insights

1. Python dominates — it’s the universal glue for data engineering, analytics, and ML.
2. Big Data stack is essential — Spark, Hadoop, and Kafka form the backbone for handling large-scale data pipelines.
3. DataFrame tools (Pandas, NumPy, PySpark) — still highly relevant, especially in ETL and preprocessing workflows.
4. Cloud & DevOps integration — tools like Kubernetes, Databricks, and AWS/GCP/Azure show the growing blend between data engineering and infrastructure automation.
5. SQL remains a constant — even in 2023, structured data querying is a must-have.
6. Emerging crossover skills — PyTorch, Keras, and R appear in some listings, reflecting hybrid data engineer / ML engineer roles.

*/