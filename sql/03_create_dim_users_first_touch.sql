-- Project: Product Analytics - GA4 Ecommerce
-- Layer: dimension
-- Grain: 1 row = 1 user

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.dim_users_first_touch` AS

WITH first_observed_event AS (
  SELECT
    user_pseudo_id,
    event_ts,
    event_date,
    event_name,
    device_category,
    browser,
    country,
    user_source,
    user_medium,
    user_campaign,
    ga_session_number,
    ROW_NUMBER() OVER (
      PARTITION BY user_pseudo_id
      ORDER BY event_ts, event_name
    ) AS rn
  FROM `projet2-494122.ecommerce_analytics.stg_events_base`
),

first_visit AS (
  SELECT
    user_pseudo_id,
    event_ts AS first_visit_ts,
    event_date AS first_visit_date
  FROM `projet2-494122.ecommerce_analytics.stg_events_base`
  WHERE event_name = 'first_visit'
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY user_pseudo_id
    ORDER BY event_ts
  ) = 1
)

SELECT
  foe.user_pseudo_id,
  foe.event_ts AS first_seen_ts,
  foe.event_date AS first_seen_date,
  foe.event_name AS first_observed_event_name,

  fv.first_visit_ts,
  fv.first_visit_date,

  fv.first_visit_ts IS NOT NULL AS has_first_visit,

  CASE
    WHEN fv.first_visit_ts IS NOT NULL THEN 'new_user_observed'
    ELSE 'pre_existing_or_unknown'
  END AS user_cohort_type,

  foe.device_category AS first_device_category,
  foe.browser AS first_browser,
  foe.country AS first_country,
  foe.user_source AS first_user_source,
  foe.user_medium AS first_user_medium,
  foe.user_campaign AS first_user_campaign,
  foe.ga_session_number AS first_ga_session_number

FROM first_observed_event foe
LEFT JOIN first_visit fv
  ON foe.user_pseudo_id = fv.user_pseudo_id
WHERE foe.rn = 1;
