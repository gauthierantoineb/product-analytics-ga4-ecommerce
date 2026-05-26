-- Project: Product Analytics - GA4 Ecommerce
-- Layer: mart
-- Grain: 1 row = 1 cohort_week x activated_flag x week_number
-- Purpose: report-ready weekly retention rates

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.mart_retention_weekly` AS

WITH cohort_sizes AS (
  SELECT
    DATE_TRUNC(first_visit_date, WEEK(MONDAY)) AS cohort_week,
    activated_flag,
    COUNT(DISTINCT user_pseudo_id) AS cohort_users
  FROM `projet2-494122.ecommerce_analytics.fct_activation_status`
  GROUP BY
    cohort_week,
    activated_flag
)

SELECT
  r.cohort_week,
  r.activated_flag,
  r.week_number,
  cs.cohort_users,
  r.retained_users,
  SAFE_DIVIDE(r.retained_users, cs.cohort_users) AS retention_rate
FROM `projet2-494122.ecommerce_analytics.fct_retention_weekly` r
LEFT JOIN cohort_sizes cs
  ON r.cohort_week = cs.cohort_week
 AND r.activated_flag = cs.activated_flag;
