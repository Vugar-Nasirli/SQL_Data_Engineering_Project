-- Step 4: Marts - Create Flat Mart Table

SELECT '===== Dropping Flat Mart Schema and Creating from scratch... =====' AS info;

DROP SCHEMA IF EXISTS flat_mart CASCADE;
CREATE SCHEMA flat_mart;

CREATE OR REPLACE TABLE flat_mart.job_postings
AS
SELECT
    f.job_id,
    f.job_title_short,
    f.job_title,
    f.job_location,
    f.job_via,
    f.job_schedule_type,
    f.job_work_from_home,
    f.search_location,
    f.job_posted_date,
    f.job_no_degree_mention,
    f.job_health_insurance,
    f.job_country,
    f.salary_rate,
    f.salary_year_avg,
    f.salary_hour_avg,
    -- Company dimension fields
    c.company_id,
    c.name AS company_name,
    -- Skills dimension fields
    ARRAY_AGG
    (
        STRUCT_PACK
        (
            skill := s.skills,
            type  := s.type
        )
    ORDER BY s.skill_id
    ) AS skills_and_type
FROM
    job_postings_fact AS f
    LEFT JOIN company_dim AS c ON c.company_id = f.company_id
    LEFT JOIN skills_job_dim AS b ON b.job_id = f.job_id
    LEFT JOIN skills_dim AS s ON s.skill_id = b.skill_id
GROUP BY
    f.job_id,
    f.job_title_short,
    f.job_title,
    f.job_location,
    f.job_via,
    f.job_schedule_type,
    f.job_work_from_home,
    f.search_location,
    f.job_posted_date,
    f.job_no_degree_mention,
    f.job_health_insurance,
    f.job_country,
    f.salary_rate,
    f.salary_year_avg,
    f.salary_hour_avg,
    -- Company dimension fields
    c.company_id,
    c.name;