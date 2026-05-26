-- Project: Product Analytics - GA4 Ecommerce
-- Layer: fact
-- Grain: 1 row = 1 cohort_week x activated_flag x week_number
-- Retention definition: weekly shopping activity after first_visit cohort

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.fct_retention_weekly` AS

WITH user_cohorts AS (
  SELECT
    user_pseudo_id,
    DATE_TRUNC(first_visit_date, WEEK(MONDAY)) AS cohort_week,
    activated_flag
  FROM `projet2-494122.ecommerce_analytics.fct_activation_status`
),

shopping_activity AS (
  SELECT DISTINCT
    user_pseudo_id,
    DATE_TRUNC(event_date, WEEK(MONDAY)) AS activity_week
  FROM `projet2-494122.ecommerce_analytics.stg_events_base`
  WHERE event_name IN (
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'purchase',
    'view_search_results',
    'select_item'
  )
),

retention AS (
  SELECT
    uc.user_pseudo_id,
    uc.cohort_week,
    uc.activated_flag,
    sa.activity_week,
    DATE_DIFF(sa.activity_week, uc.cohort_week, WEEK(MONDAY)) AS week_number
  FROM user_cohorts uc
  LEFT JOIN shopping_activity sa
    ON uc.user_pseudo_id = sa.user_pseudo_id
   AND sa.activity_week >= uc.cohort_week
)

SELECT
  cohort_week,
  activated_flag,
  week_number,
  COUNT(DISTINCT user_pseudo_id) AS retained_users
FROM retention
WHERE week_number BETWEEN 0 AND 12
GROUP BY
  cohort_week,
  activated_flag,
  week_number;
