-- Step 8: Create Priority Mart Tables

DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

SELECT '===== Creating and Loading priority roles table... =====' AS info;
CREATE TABLE priority_mart.priority_roles
(
    role_id         INTEGER     PRIMARY KEY,
    role_name       VARCHAR,
    priority_lvl    INTEGER
);

INSERT INTO priority_mart.priority_roles(role_id, role_name, priority_lvl)
VALUES
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

SELECT '===== Priority Roles Table Data: =====' AS info;
SELECT * FROM priority_mart.priority_roles;


SELECT '===== Creating and Loading priority Jobs Snapshot table... =====' AS info;
CREATE TABLE priority_mart.priority_jobs_snapshot
(
    job_id              INTEGER PRIMARY KEY,
    job_title_short     VARCHAR,
    company_name        VARCHAR,
    job_posted_date     TIMESTAMP,
    salary_year_avg     DOUBLE,
    priority_lvl        INTEGER,
    updated_at          TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot
SELECT
    f.job_id,
    f.job_title_short,
    c.name AS company_name,
    f.job_posted_date,
    f.salary_year_avg,
    p.priority_lvl,
    CURRENT_TIMESTAMP
FROM
    job_postings_fact AS f
    LEFT JOIN company_dim AS c ON c.company_id = f.company_id
    INNER JOIN priority_mart.priority_roles AS p ON p.role_name = f.job_title_short;

SELECT '===== Priority Jobs Snapshot Table Data: =====' AS info;
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
