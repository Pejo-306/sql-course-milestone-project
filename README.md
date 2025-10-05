# Job Data Analysis - SQL Milestone Project

Focusing on Data Engineering roles, explore top-paying jobs, in-demand skills, and where demand meets high-salary in data engineering. Built as a capstone project for Luke Barousses's [SQL Course](https://lukebarousse.com/sql) with a job listings dataset from 2023.

- SQL queries -> find them inside [project_sql folder](/project_sql/).
- My solutions to advanced SQL problems from the course -> find them inside [advanced_sql folder](/advanced_sql/)
- 2023 job marketplace dataset -> find the raw data inside [csv_files folder](/csv_files/)

## Table of Contents

* [Background](#background)
* [Data Model](#data-model)
* [The Questions I Wanted to Answer Through my SQL Queries Were](#the-questions-i-wanted-to-answer-through-my-sql-queries-were)
* [Tools I Used](#tools-i-used)
* [Setup](#setup)
* [The Analysis](#the-analysis)
  - [1. Top Paying Data Engineer Jobs](#1-top-paying-data-engineer-jobs)
  - [2. Skills for Top Paying Jobs](#2-skills-for-top-paying-jobs)
  - [3. In-Demand Skills for Data Engineers](#3-in-demand-skills-for-data-engineers)
  - [4. Skills Based on Salary](#4-skills-based-on-salary)
  - [5. Most Optimal Skills to Learn](#5-most-optimal-skills-to-learn)
* [What I Learned](#what-i-learned)
* [Conclusions](#conclusions)
  - [Insights](#insights)
  - [Closing Thoughts](#closing-thoughts)
* [Built With](#built-with)
* [License](#license)
* [Credits](#credits)

## Background

Driven by a desire to both a) refresh my SQL skills and b) improve on them with a small capstone project, this project was born while searching for a new data engineering role in my career development.

You can check out [Luke's free SQL for Data Analytics course on YouTube](https://www.youtube.com/watch?v=7mz73uXD9DA) for more background on the queries, dataset and analysis. I have spun my own flavour on his capstone project in this repository.

## Data Model

Data hails from Luke Barousse's [SQL Course](https://lukebarousse.com/sql). It's packed with insights on job titles, salaries, locations, and essential skills.

![Data Model](assets/00_data_model.png)
*Data model of 2023 jobs dataset showcasing a job postings fact table with 3 relational dimension tables for skills, companies, and many-to-many skills-to-jobs relations*

## The Questions I Wanted to Answer Through my SQL Queries Were:

1. *What are the top-paying data engineering jobs?*
2. *What skills are required for these top-paying jobs?*
3. *What skills are most in demand for data engineering?*
4. *Which skills are associated with higher salaries?*
5. *What are the most optimal skills to learn?*

## Tools I Used

For my deep dive into the data engineering job market, I used:

- **SQL:** The backbone of my analysis, allowing me to query the database and unearth critical insights;
- **PostgreSQL:** The chosen database management system, ideal for handling the job posting data;
- **Visual Studio Code:** My go-to for database management and executing SQL queries;
- **Git & GitHub & Git LFS:** Essential for version control and sharing my SQL scripts and analysis, ensuring collaboration and project tracking;
- **pgAdmin4**: My visual command center for PostgreSQL - perfect for managing databases, running queries, and exploring tables without leaving the browser;
- **Docker Compose**: The engine behind my local setup, spinning up a PostgreSQL + pgAdmin4 combo to keep everything isolated, reproducible, and ready to go in seconds;

## Setup

In this section, we deploy a local PostgreSQL database via Docker Compose and load the 2023 source dataset into it.

### TL;DR

In *bash* shell:
```bash
# Clone the repository
git clone https://github.com/Pejo-306/sql-course-milestone-project
cd sql-course-milestone-project/

# Deploy Docker stack
docker compose up -d

# Create database and tables
docker cp sql_load/1_create_database.sql pgdb:/tmp/1_create_database.sql
docker cp sql_load/2_create_tables.sql pgdb:/tmp/2_create_tables.sql
docker exec -it pgdb psql -U postgres -f /tmp/1_create_database.sql
docker exec -it pgdb psql -U postgres -d sql_course -f /tmp/2_create_tables.sql

# Copy source dataset into PostgreSQL container
# Then, load the dataset into the database via the following psql shell
docker cp csv_files/company_dim.csv pgdb:/tmp/company_dim.csv
docker cp csv_files/job_postings_fact.csv pgdb:/tmp/job_postings_fact.csv
docker cp csv_files/skills_dim.csv pgdb:/tmp/skills_dim.csv
docker cp csv_files/skills_job_dim.csv pgdb:/tmp/skills_job_dim.csv
docker exec -it pgdb psql -U postgres -d sql_course
```

In opened *psql* shell:
```
\copy company_dim FROM '/tmp/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '/tmp/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '/tmp/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '/tmp/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

exit
```

### Prerequisites

- **Docker** version **28.1+**
- **Docker Compose** version **2.35+**

### Clone Repository

Clone the repo:
```bash
git clone https://github.com/Pejo-306/sql-course-milestone-project
cd sql-course-milestone-project/
```

### Deploy Docker Stack

Use Docker Compose to deploy:
- **pgdb** (container): Local **PostgreSQL** database, exposed on **[localhost:5432](http://localhost:5432)**
- **pgadmin4** (container): **pgAdmin4** command center for PostgreSQL databases, accessible on **[localhost:8888](http://localhost:8888)**

```bash
docker compose up
```

**NOTE:** If you currently have a PostgreSQL database running on your local machine, the **pgdb** container will conflict with your local PostgreSQL database for port **5432**. Either disable your local PostgreSQL database or edit the [docker compose file](/docker-compose.yml) to use another port.

### Connect pgAdmin4 to PostgreSQL database

1. Access pgAdmin4 on **[localhost:8888](http://localhost:8888)** and log in with:
* **email**: postgres@example.com
* **password**: postgres
2. Click *"Add New Server"*
3. In the *General* tab fill *"Name"* field with *'postgres'*
4. In the *Connection* tab, fill:
* **Host name/address**: pgdb
* **Username**: postgres
* **Password**: postgres
* **Save password?**: ON
5. Inspect the databases on the left panel. There should be a "postgres" database.

### Create Database and Tables

There are two ways to create the database and tables:

* **Option 1**: Open the [database creation script](/sql_load/1_create_database.sql) and [tables creation script](/sql_load/2_create_tables.sql), then copy the SQL scripts and run them in pgAdmin4 via its query tool.
* **Option 2**: Copy the [database creation script](/sql_load/1_create_database.sql) and [tables creation script](/sql_load/2_create_tables.sql) inside the **pgdb** (PostgreSQL database) container and execute them.

In this section, option 2 is detailed:

1. Copy both SQL scripts inside the **pgdb** container:
```bash
docker cp sql_load/1_create_database.sql pgdb:/tmp/1_create_database.sql
docker cp sql_load/2_create_tables.sql pgdb:/tmp/2_create_tables.sql
```
2. Run the [database creation script](/sql_load/1_create_database.sql):
```bash
docker exec -it pgdb psql -U postgres -f /tmp/1_create_database.sql
``` 
3. Run the [tables creation script](/sql_load/2_create_tables.sql):
```bash
docker exec -it pgdb psql -U postgres -d sql_course -f /tmp/2_create_tables.sql
```
4. Check the 4 tables were successfully created:
```bash
docker exec -i pgdb psql -U postgres -d sql_course -c "\dt"
```

You should see the following output in your terminal:

```
               List of relations
 Schema |       Name        | Type  |  Owner   
--------+-------------------+-------+----------
 public | company_dim       | table | postgres
 public | job_postings_fact | table | postgres
 public | skills_dim        | table | postgres
 public | skills_job_dim    | table | postgres
(4 rows)
```

### Load Source Dataset

Loading the datasets into the database requires copying the [source csv files](/csv_files/) into the **pgdb** container and copying the data via the *psql* tool inside the container itself:

**IMPORTANT:** Please execute the following commands **in this order** to avoid foreign key constraint issues from the database.

1. Copy [source csv files](/csv_files/) into the **pgdb** container:
```bash
docker cp csv_files/company_dim.csv pgdb:/tmp/company_dim.csv
docker cp csv_files/job_postings_fact.csv pgdb:/tmp/job_postings_fact.csv
docker cp csv_files/skills_dim.csv pgdb:/tmp/skills_dim.csv
docker cp csv_files/skills_job_dim.csv pgdb:/tmp/skills_job_dim.csv
``` 
2. Open the container's interactive *psql* tool:
```bash
docker exec -it pgdb psql -U postgres -d sql_course
```
3. Load data for companies into **company_dim** table:
```
\copy company_dim FROM '/tmp/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```
4. Load data for skills into **skills_dim** table:
```
\copy skills_dim FROM '/tmp/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```
5. Load data for job postings into **job_postings_fact** table:
```
\copy job_postings_fact FROM '/tmp/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```
6. Load data for many-to-many skills-to-job-postings relationship into **skills_job_dim** table (**NOTE:** it may take a few minutes, please allow it time to finish):
```
\copy skills_job_dim FROM '/tmp/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
```
7. Exit:
```
exit
```

Your shell should look like this:

```
psql (13.2 (Debian 13.2-1.pgdg100+1))
Type "help" for help.

sql_course=# \copy company_dim FROM '/tmp/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY 140033
sql_course=# \copy skills_dim FROM '/tmp/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY 259
sql_course=# \copy job_postings_fact FROM '/tmp/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY 787686
sql_course=# \copy skills_job_dim FROM '/tmp/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY 3669604
sql_course=# 
```

### Test (via pgadmin4)

Access pgAdmin4 on **[localhost:8888](http://localhost:8888)** and log in with:
* **email**: postgres@example.com
* **password**: postgres

Access the database **sql_course** and run a simple query (via pgAdmin's *Query Tool*) to test data is available:

```sql
SELECT * FROM job_postings_fact LIMIT 100;
```

You should get a result set of 100 job postings. With that done, we're ready to begin 

## The Analysis

Each query for this project aimed at investigating specific aspects of the data analyst job market. Here’s how I approached each question:

### 1. Top Paying Data Engineer Jobs

To identify the highest-paying roles, I filtered **data engineer** positions by average yearly salary and location, focusing on remote jobs. This query highlights the high paying opportunities in the field.

**NOTE**: Query can be found inside [/project_sql/01_top_paying_jobs.sql](/project_sql/01_top_paying_jobs.sql)

```sql
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
```

Here’s a breakdown of the Top 10 Paying Data Engineering Jobs (2023) based on our 2023 dataset:

| Metric             | Value               |
| ------------------ | ------------------- |
| **Total Jobs**     | 10                  |
| **Average Salary** | **$268,300 / year** |
| **Highest Salary** | **$325,000**        |
| **Lowest Salary**  | **$242,000**        |


**Key Insights**

1. The average pay range ($242K–$325K) shows that data engineering roles at the top level are highly lucrative and often overlap with director or leadership positions;
2. The term “Principal” and “Staff” appear frequently - signaling strong demand for experienced engineers capable of designing large-scale data systems;
3. Most companies listed are tech-first organizations or consultancies, suggesting that data engineering remains core to scaling data-driven operations.

![Top Paying Jobs](assets/01_top_paying_jobs.png)
*Horizontal bar chart showing the average salary by job title among the top 10 paying data engineering positions - clearly higlights an even distribution among senior data engineering roles, making this role a stable and lucrative one*

### 2. Skills for Top Paying Jobs

To understand what skills are required for the top-paying jobs, I joined the job postings with the skills data, providing insights into what employers value for high-compensation roles.

**NOTE**: Query can be found inside [/project_sql/02_top_paying_job_skills.sql](/project_sql/02_top_paying_job_skills.sql)

```sql
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
```

Here’s a quick breakdown of insights from the skill column for the top 10 data engineer jobs in 2023:

**Most In-Demand Skills (for top-paying jobs)**
| Rank | Skill                                                                       | Mentions |
| ---- | --------------------------------------------------------------------------- | -------- |
| 1    | **Python**                                                                  | 7        |
| 2    | **Spark**                                                                   | 5        |
| 3    | **Hadoop**, **Kafka**, **Scala**                                            | 3 each   |
| 4    | **Pandas**, **NumPy**, **PySpark**, **Kubernetes**, **SQL**, **Databricks** | 2 each   |

**Key Insights**

* **Python dominates** - it’s the universal glue for data engineering, analytics, and ML;
* **Big Data stack is essential** - Spark, Hadoop, and Kafka form the backbone for handling large-scale data pipelines;
* **DataFrame tools (Pandas, NumPy, PySpark)** - still highly relevant, especially in ETL and preprocessing workflows;
* **Cloud & DevOps integration** - tools like Kubernetes, Databricks, and AWS/GCP/Azure show the growing blend between data engineering and infrastructure automation;
* **SQL remains a constant** - even in 2023, structured data querying is a must-have;
* **Emerging crossover skills** - PyTorch, Keras, and R appear in some listings, reflecting hybrid data engineer / ML engineer roles;

![Top Paying Jobs' Skills](assets/02_top_paying_jobs_skills.png)
*Horizontal bar chart showing the Top 10 Data Engineering Skills found in 2023 job postings - with **Python** and **Spark** clearly leading, followed by the core big data and cloud ecosystem tools.*

### 3. In-Demand Skills for Data Engineers

This query helped identify the skills most frequently requested in job postings, directing focus to areas with high demand.

**NOTE**: Query can be found inside [/project_sql/03_top_demanded_skills.sql](/project_sql/03_top_demanded_skills.sql)

```sql
SELECT
    skills.skills,
    COUNT(jobs.job_id) AS demand_count
FROM
    skills_dim AS skills
    INNER JOIN skills_job_dim AS skills_to_job ON skills.skill_id = skills_to_job.skill_id
    INNER JOIN job_postings_fact AS jobs ON skills_to_job.job_id = jobs.job_id
WHERE
    jobs.job_title_short = 'Data Engineer'
    AND jobs.work_from_home = True  -- Optional: check only for remote jobs
GROUP BY
    skills.skills
ORDER BY
    demand_count DESC
LIMIT 5;
```

**Top 5 Most In-Demand Skills**

| Rank | Skill      | Demand Count |
| ---- | ---------- | ------------ |
| 1    | **SQL**    | 14,213       |
| 2    | **Python** | 13,893       |
| 3    | **AWS**    | 8,570        |
| 4    | **Azure**  | 6,997        |
| 5    | **Spark**  | 6,612        |


**Key Insights**

* **SQL remains the top essential skill**, confirming that structured data manipulation is still the backbone of data engineering work.
* **Python is nearly as critical** - indispensable for data transformation, automation, and integration with modern data frameworks.
* **Cloud expertise dominates** - with AWS and Azure ranking third and fourth, it’s clear remote data roles heavily rely on cloud-based infrastructure.
* **Spark solidifies its place** as the go-to big data processing framework, reinforcing the demand for engineers skilled in distributed data systems.
* Together, these skills illustrate the **blend of traditional database expertise, modern programming, and cloud-native capabilities** defining today’s remote data engineering landscape.

### 4. Skills Based on Salary

Exploring the average salaries associated with different skills revealed which skills are the highest paying.

**NOTE**: Query can be found inside [/project_sql/04_top_paying_skills.sql](/project_sql/04_top_paying_skills.sql)

```sql
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
    AND jobs.job_work_from_home = TRUE  -- Optional: check only for remote jobs
GROUP BY
    skills.skills
ORDER BY
    average_salary DESC
LIMIT 25;
```

**Top 25 Highest Paying Skills**

| Rank | Skill          | Avg. Salary (USD) |
| ---- | -------------- | ----------------: |
| 1    | **Assembly**   |           192,500 |
| 2    | **Mongo**      |           182,222 |
| 3    | **ggplot2**    |           176,250 |
| 4    | **Rust**       |           172,819 |
| 5    | **Clojure**    |           170,867 |
| 6    | **Perl**       |           169,000 |
| 7    | **Neo4j**      |           166,559 |
| 8    | **Solidity**   |           166,250 |
| 9    | **GraphQL**    |           162,547 |
| 10   | **Julia**      |           160,500 |
| 11   | **Splunk**     |           160,397 |
| 12   | **Bitbucket**  |           160,333 |
| 13   | **Zoom**       |           159,000 |
| 14   | **Kubernetes** |           158,190 |
| 15   | **NumPy**      |           157,592 |
| 16   | **MXNet**      |           157,500 |
| 17   | **FastAPI**    |           157,500 |
| 18   | **Redis**      |           157,000 |
| 19   | **Trello**     |           155,000 |
| 20   | **jQuery**     |           151,667 |
| 21   | **Express**    |           151,636 |
| 22   | **Cassandra**  |           151,282 |
| 23   | **Unify**      |           151,000 |
| 24   | **Kafka**      |           150,549 |
| 25   | **VMware**     |           150,000 |


**Key Insights**

* **Low-level and niche languages pay premium rates** - skills like Assembly, Rust, and Clojure command top salaries due to their scarcity and specialized nature in performance-critical systems.
* These results show a **diverse mix of high-paying technical skills** - spanning from low-level programming (Assembly, Rust) to modern frameworks and data systems (Kubernetes, Kafka, Neo4j, Redis)
* High-paying data engineers are those who **combine system-level programming, distributed systems, and ML-aware data pipeline skills** - bridging the gap between raw infrastructure and intelligent automation.

### 5. Most Optimal Skills to Learn

Combining insights from demand and salary data, this query aimed to pinpoint skills that are both in high demand and have high salaries, offering a strategic focus for skill development.

**NOTE**: Query can be found inside [/project_sql/05_optimal_skills.sql](/project_sql/05_optimal_skills.sql)

```sql
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
```

**Top 25 Most Optimal Skills (High Demand AND High Salary)**

| Rank | Skill             | Demand Count | Avg. Salary (USD) |
| ---- | ----------------- | -----------: | ----------------: |
| 1    | **Kubernetes**    |           56 |           158,190 |
| 2    | **NumPy**         |           14 |           157,592 |
| 3    | **Cassandra**     |           19 |           151,282 |
| 4    | **Kafka**         |          134 |           150,549 |
| 5    | **TensorFlow**    |           10 |           148,100 |
| 6    | **Golang**        |           11 |           147,818 |
| 7    | **Terraform**     |           44 |           146,057 |
| 8    | **Pandas**        |           38 |           144,656 |
| 9    | **Elasticsearch** |           21 |           144,102 |
| 10   | **Ruby**          |           14 |           144,000 |
| 11   | **Aurora**        |           14 |           142,887 |
| 12   | **PyTorch**       |           11 |           142,254 |
| 13   | **Scala**         |          113 |           141,777 |
| 14   | **Spark**         |          237 |           139,838 |
| 15   | **PySpark**       |           64 |           139,428 |
| 16   | **DynamoDB**      |           27 |           138,883 |
| 17   | **MongoDB**       |           32 |           138,569 |
| 18   | **Airflow**       |          151 |           138,518 |
| 19   | **Java**          |          139 |           138,087 |
| 20   | **Hadoop**        |           98 |           137,707 |
| 21   | **TypeScript**    |           19 |           137,207 |
| 22   | **NoSQL**         |           93 |           136,430 |
| 23   | **Shell**         |           34 |           135,499 |

**Key Insights**

* **Kubernetes dominates the top spot** - high demand and high salary confirm its essential role in modern data infrastructure.
* **Python ecosystem tools (NumPy, Pandas, PySpark, TensorFlow, PyTorch)** are heavily represented, reinforcing their versatility across data engineering and ML workflows.
* **Distributed systems like Kafka, Cassandra, Spark, and Airflow** are central to large-scale data operations - key for scalability and performance.
* **Cloud & DevOps crossovers (Terraform, Elasticsearch, Aurora)** show how infrastructure-as-code and data management expertise now go hand in hand.
* In short, **engineers who master both data frameworks and cloud-native infrastructure** stand at the sweet spot of demand, salary, and long-term career value. 

## What I Learned

Throughout this course and project, I've refreshed and improved my SQL toolkit by:

* **Structuring SQL code**: Learned and developed my own flavour of writing SQL code for easy readability and maintainability;
* **Complex Query Crafting**: Improved my ability to write and analyze complex queries with CTEs, subqueries, unions, multiple joins;
* **Understanding Analytical Result Sets**: Leveled-up my ability to aggregate relational data and extract insights for practical real-world problems; 

## Conclusions

### Insights

From the analysis, several general insights emerged for **remote Data Engineering roles**:

1. **Top-Paying Data Engineering Jobs**: The highest paying remote Data Engineering jobs show an even salary distribution, solidifying the stability and demand for senior data engineers across the world;
2. **Skills for Top-Paying Jobs**: Python dominates the Data Engineering fields with Big Data technologies (Spark, Hadoop) becoming essentials. There is also an emerging trend towards combining data engineering with ML and cloud technologies;
3. **Most In-Demand Skills**: SQL and Python remain the backbone of Data Engineering roles with big data (Spark) and cloud technologies following closely;
4. **Skills with Higher Salaries**: Specialized skills on niche, low-level programming languages, ML and infrastructures in combination with the data engineering fundamentals (Python, Spark, SQL, cloud) hold a premium salary in the industry;
5. **Optimal Skills for Job Market Value**: Distributed systems (Spark, Kafka, Airflow) and infrastructure (Kubernetes) are becoming the norm in the data engineering field, forecasting a growing demand for large-scale data processing.

### Closing Thoughts

This project enhanced my SQL skills, particularly around structuring SQL code, building complex queries with joins, subqueries, unions, CTEs, and analyzing aggregated result sets. It's built on top of a real 2023 jobs dataset, which provides practical insights for the most optimal skills and emerging trends in the remote Data Engineering field.

## Built With

* [PostgreSQL](https://www.postgresql.org/)
* [pgAdmin4](https://www.pgadmin.org/)
* [Docker](https://www.docker.com/) and [Docker Compose](https://github.com/docker/compose)
* [Git LFS](https://git-lfs.com/)

## License

This project is distributed under the [MIT license](LICENSE).

## Credits

* [Luke Barousse's free YouTube Course on SQL](https://www.youtube.com/watch?v=7mz73uXD9DA)
* [Luke Barousse's SQL for Data Analytics course](https://lukebarousse.com/sql)
* [Luke Barousse's SQL for Data Analytics GitHub Repository](https://github.com/lukebarousse/SQL_Project_Data_Job_Analysis)
