-- CASE Practice
WITH base_query
AS
(
    SELECT
        job_id,
        job_title_short,
        salary_rate,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) < 75000 THEN 'Low'
            WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) BETWEEN 75000 AND 150000 THEN 'Medium'
            WHEN COALESCE(salary_year_avg, salary_hour_avg * 2080) > 150000 THEN 'High'
            ELSE 'Missing'
        END salary_category
    FROM
        job_postings_fact
)

SELECT
    job_title_short,
    salary_category,
    COUNT(*) AS job_count,
    ROUND(MEDIAN(COALESCE(salary_year_avg, salary_hour_avg * 2080)), 0) AS median_category_salary
FROM
    base_query
WHERE
    job_title_short = 'Data Engineer'
GROUP BY
    job_title_short,
    salary_category
ORDER BY
    median_category_salary DESC;

-----------------------------------------------------------------
-- DATE TIME ZONE Functions
SELECT
    local_time,
    COUNT(job_id) AS job_count
FROM
(
    SELECT
        job_id,
        EXTRACT(HOUR FROM job_posted_date::TIMESTAMPTZ AT TIME ZONE 'CET') AS local_time
    FROM
        job_postings_fact
    WHERE
        job_country = 'Norway'
)
GROUP BY
    local_time;

---------------------------------------------------------------------
-- SET Operators

-- 2023 Records
CREATE TEMPORARY TABLE jobs_2023
AS
SELECT
    * EXCLUDE (job_id, job_posted_date)
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023;

-- 2024 Records
CREATE TEMPORARY TABLE jobs_2024
AS
SELECT
    * EXCLUDE (job_id, job_posted_date)
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2024;

-- Total Record Counts
SELECT
    '2023' AS table_name,
    COUNT(*) AS records
FROM jobs_2023
UNION
SELECT
    '2024',
    COUNT(*)
FROM jobs_2024;

-- UNION
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2023
UNION
SELECT * FROM jobs_2024
);

-- UNION ALL
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2023
UNION ALL
SELECT * FROM jobs_2024
);

-- EXCEPT
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2024
EXCEPT
SELECT * FROM jobs_2023
);

-- EXCEPT ALL
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2024
EXCEPT ALL
SELECT * FROM jobs_2023
);

-- INTERSECT
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2024
INTERSECT
SELECT * FROM jobs_2023
);

-- INTERSECT ALL
SELECT
    COUNT(*)
FROM
(
SELECT * FROM jobs_2024
INTERSECT ALL
SELECT * FROM jobs_2023
);

-- Nested Data Types and Functions

-- ARRAYS
SELECT ['sql', 'python', 'r'] AS array;
SELECT ['sql', 'python', 'r'][2] AS index_2;

WITH skills AS
(
SELECT 'sql' AS skill
UNION
SELECT 'python'
UNION
SELECT 'statistics'
UNION
SELECT 'r'
),

skills_array AS
(
SELECT
    array_agg(skill ORDER BY skill) AS skill_list
FROM
    skills
)

SELECT
    skill_list,
    ARRAY_LENGTH(skill_list) AS length,
    ARRAY_CONTAINS(skill_list, 'sql') AS contains,
    skill_list[1] AS index_1,
    skill_list[2] AS index_2,
    skill_list[3] AS index_3,
    skill_list[4] AS index_4
FROM
    skills_array;

-- STRUCT
SELECT {skill: 'python', lvl: 'advanced', type: 'programming', used: TRUE, price: 600} AS skill_struct;
SELECT {skill: 'python', lvl: 'advanced', type: 'programming', used: TRUE, price: 600}.lvl AS skill_lvl;

WITH details AS
(
SELECT
    STRUCT_PACK(
        skill := 'python',
        used := TRUE,
        price := 600,
        lvl := 'advanced',
        type := 'programming'
    ) AS skill_struct
)

SELECT
    skill_struct,
    skill_struct.skill AS skill,
    skill_struct.type AS type,
    skill_struct.lvl AS level
FROM
    details;

WITH skill_details AS
(
SELECT 'sql' AS skill, 'query' AS type, 'intermediate' AS lvl, TRUE AS used, 500 AS price
UNION
SELECT 'python', 'programming', 'advanced', TRUE, 600
UNION
SELECT 'statistics', 'math', 'advanced', TRUE, 700
UNION
SELECT 'r', 'programming', 'advanced', FALSE, 1000
)

SELECT
    STRUCT_PACK(
        skill := skill,
        type := type,
        level := lvl,
        used := used,
        price := price
    ) AS skill_struct
FROM
    skill_details
WHERE
    used = TRUE;

-- ARRAY OF STRUCTS
WITH array_of_structs
AS
(
SELECT
[
    {skill: 'sql', type: 'scripting', lvl: 'intermediate'},
    {skill: 'python', type: 'progrmming', lvl: 'advanced'},
    {skill: 'statistics', type: 'math', lvl: 'advanced'}
] AS skills_details
)

SELECT
    skills_details,
    skills_details[1] AS index_1,
    skills_details[1].lvl AS skill_type
FROM
    array_of_structs;

WITH skill_details
AS
(
SELECT 'sql' AS skill, 'scripting' AS type, 'advanced' AS lvl
UNION
SELECT 'r', 'programming', 'advanced'
UNION
SELECT 'python', 'programming', 'advanced'
),

array_of_structs_skills
AS
(
SELECT
    ARRAY_AGG
    (
        STRUCT_PACK
        (
            skill := skill,
            type := type,
            lvl := lvl
        )
    ORDER BY skill
    ) AS skills
FROM
    skill_details
)

SELECT
    --UNNEST(skills),
    skills,
    skills[2] AS index_2,
    skills[2].skill AS skill_name,
    skills[2].lvl AS skill_level
FROM
    array_of_structs_skills;


-- MAP (Dictionary)
SELECT MAP {'skill':'python', 'type':'programming', 'level':'advanced'};
SELECT MAP (['skill', 'type', 'level'],['r', 'programming', 'advanced']);
SELECT MAP {'skill':'python', 'type':'programming', 'level':'advanced'}['skill'];
SELECT MAP_KEYS(MAP {'skill':'python', 'type':'programming', 'level':'advanced'});
SELECT MAP_VALUES(MAP {'skill':'python', 'type':'programming', 'level':'advanced'});

-- JSON
WITH skills
AS
(
SELECT '{"skill" : ["python", "sql"], "type" : ["programming", "scripting"], "salary" : {"amount" : 120000, "currency" : "USD"}}'::JSON AS j
)

SELECT
    j,
    JSON_EXTRACT(j, '$.skill'),
    JSON_EXTRACT(j, '$.salary')
FROM
    skills;


-- Example of Arrays and UNNEST

WITH base_query
AS
(
SELECT
    f.job_id,
    f.job_title_short,
    f.salary_year_avg,
    ARRAY_AGG(s.skills ORDER BY s.skill_id) AS skill_list
FROM
    job_postings_fact AS f
    LEFT JOIN skills_job_dim AS b ON b.job_id = f.job_id
    LEFT JOIN skills_dim AS s ON s.skill_id = b.skill_id
WHERE
    s.skill_id IS NOT NULL
GROUP BY
    f.job_id,
    f.job_title_short,
    f.salary_year_avg
ORDER BY
    salary_year_avg DESC
),
skills AS
(
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skill_list) AS skills
FROM
    base_query
)

SELECT
    skills,
    MEDIAN(salary_year_avg) AS median_salary,
    COUNT(job_id) AS job_count,
    ROUND(LN(MEDIAN(salary_year_avg) * COUNT(job_id) / 10_000_000), 2) AS skill_score
FROM
    skills
GROUP BY
    skills
ORDER BY
    skill_score DESC;



-- Example of ARRAY of STRUCTs
WITH base_query AS
(
SELECT
    f.job_id,
    f.job_title_short,
    f.salary_year_avg,
    ARRAY_AGG
    (
        STRUCT_PACK
        (
            skill := s.skills,
            type := s.type
        )
        ORDER BY s.type
    ) AS skill_type
FROM
    job_postings_fact AS f
    LEFT JOIN skills_job_dim AS b ON b.job_id = f.job_id
    LEFT JOIN skills_dim AS s ON s.skill_id = b.skill_id
WHERE
    s.skill_id IS NOT NULL
GROUP BY
    f.job_id,
    f.job_title_short,
    f.salary_year_avg
),

types AS
(
SELECT
    job_id,
    job_title_short,
    salary_year_avg,
    UNNEST(skill_type).type AS skill_type,
    UNNEST(skill_type).skill AS skill_name
FROM
    base_query
)

SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary,
    COUNT(job_id) AS job_count,
    ROUND(LN(MEDIAN(salary_year_avg) * COUNT(job_id) / 100_000_000), 2) AS skill_type_score
FROM
    types
GROUP BY
    skill_type
ORDER BY
    skill_type_score DESC;
