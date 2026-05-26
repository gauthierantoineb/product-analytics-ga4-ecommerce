-- Project: Product Analytics - GA4 Ecommerce
-- Layer: fact
-- Grain: 1 row = 1 new observed user
-- Funnel type: user-level, non-strict sequence after first_visit

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.fct_funnel_steps` AS

WITH new_users AS (
  SELECT
    user_pseudo_id,
    first_visit_ts,
    first_visit_date,
    first_device_category,
    first_country,
    first_user_source,
    first_user_medium
  FROM `projet2-494122.ecommerce_analytics.dim_users_first_touch`
  WHERE has_first_visit = TRUE
),

step_times AS (
  SELECT
    nu.user_pseudo_id,
    nu.first_visit_ts,
    nu.first_visit_date,
    nu.first_device_category,
    nu.first_country,
    nu.first_user_source,
    nu.first_user_medium,

    MIN(IF(e.event_name = 'view_item' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_view_item_ts,
    MIN(IF(e.event_name = 'add_to_cart' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_add_to_cart_ts,
    MIN(IF(e.event_name = 'begin_checkout' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_begin_checkout_ts,
    MIN(IF(e.event_name = 'purchase' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_purchase_ts

  FROM new_users nu
  LEFT JOIN `projet2-494122.ecommerce_analytics.stg_events_base` e
    ON nu.user_pseudo_id = e.user_pseudo_id
  GROUP BY
    nu.user_pseudo_id,
    nu.first_visit_ts,
    nu.first_visit_date,
    nu.first_device_category,
    nu.first_country,
    nu.first_user_source,
    nu.first_user_medium
)

SELECT
  user_pseudo_id,
  first_visit_ts,
  first_visit_date,
  first_device_category,
  first_country,
  first_user_source,
  first_user_medium,

  TRUE AS reached_first_visit,
  first_view_item_ts IS NOT NULL AS reached_view_item,
  first_add_to_cart_ts IS NOT NULL AS reached_add_to_cart,
  first_begin_checkout_ts IS NOT NULL AS reached_begin_checkout,
  first_purchase_ts IS NOT NULL AS reached_purchase,

  first_view_item_ts,
  first_add_to_cart_ts,
  first_begin_checkout_ts,
  first_purchase_ts

FROM step_times;
