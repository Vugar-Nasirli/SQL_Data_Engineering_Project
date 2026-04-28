-- Step 5: Validating Flat Mart Data
SELECT '===== Flat Mart Entry Count: =====' AS info;
SELECT COUNT(*) AS entry_count FROM flat_mart.job_postings;

SELECT '===== Flat Mart Sample: =====' AS info;
SELECT * FROM flat_mart.job_postings LIMIT 3;