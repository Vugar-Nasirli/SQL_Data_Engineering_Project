-- Step 9: Update Priority Mart Roles

SELECT '====== Updating Priority Roles =====' AS info;

-- Update Date Engineer to Priority 1
UPDATE priority_mart.priority_roles
SET 
    priority_lvl = 1
WHERE
    role_name = 'Data Engineer';

-- Add Data Scienctist with priority 3
INSERT INTO priority_mart.priority_roles(role_id, role_name, priority_lvl)
VALUES
    (4, 'Data Scientist', 3);

-- Data Validation
SELECT * FROM priority_mart.priority_roles;



-- Incremental Update: MERGE

SELECT '===== Create Temp Source Table for Priority Mart Roles =====' AS info;
-- 1. Create Temporary Source Table
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs
AS
SELECT
    f.job_id,
    f.job_title_short,
    c.name AS company_name,
    f.job_posted_date,
    f.salary_year_avg,
    p.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    job_postings_fact AS f
    LEFT JOIN company_dim AS c ON c.company_id = f.company_id
    INNER JOIN priority_mart.priority_roles AS p ON p.role_name = f.job_title_short;


SELECT '===== Merge Updated Data Into Priority Mart Snapshot =====' AS info;
-- 2. MERGE from Source to Target
MERGE INTO
    priority_mart.priority_jobs_snapshot AS trgt
USING
    src_priority_jobs AS src
ON
    trgt.job_id = src.job_id 
WHEN MATCHED AND trgt.priority_lvl IS DISTINCT FROM src.priority_lvl
THEN UPDATE
SET
    priority_lvl = src.priority_lvl,
    updated_at = CURRENT_TIMESTAMP
WHEN NOT MATCHED
THEN INSERT 
(
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
VALUES
(
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
)
WHEN NOT MATCHED BY SOURCE
THEN DELETE;

-- Checking for Data
SELECT
    job_title_short,
    COUNT(job_id) AS job_count,
    MIN(priority_lvl),
    MIN(updated_at)
FROM
    priority_mart.priority_jobs_snapshot
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;