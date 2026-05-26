-- Project: Product Analytics - GA4 Ecommerce
-- Layer: fact
-- Grain: 1 row = 1 new observed user

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.fct_activation_status` AS

WITH new_users AS (
  SELECT
    user_pseudo_id,
    first_visit_ts,
    first_visit_date,
    first_device_category,
    first_country,
    first_user_source,
    first_user_medium,
    first_user_campaign
  FROM `projet2-494122.ecommerce_analytics.dim_users_first_touch`
  WHERE has_first_visit = TRUE
),

user_events AS (
  SELECT
    nu.user_pseudo_id,

    MIN(IF(e.event_name = 'add_to_cart' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_add_to_cart_ts,
    MIN(IF(e.event_name = 'purchase' AND e.event_ts >= nu.first_visit_ts, e.event_ts, NULL)) AS first_purchase_ts,

    COUNTIF(e.event_name = 'view_item' AND e.event_ts >= nu.first_visit_ts) AS view_item_events,
    COUNTIF(e.event_name = 'add_to_cart' AND e.event_ts >= nu.first_visit_ts) AS add_to_cart_events,
    COUNTIF(e.event_name = 'begin_checkout' AND e.event_ts >= nu.first_visit_ts) AS begin_checkout_events,
    COUNTIF(e.event_name = 'purchase' AND e.event_ts >= nu.first_visit_ts) AS purchase_events

  FROM new_users nu
  LEFT JOIN `projet2-494122.ecommerce_analytics.stg_events_base` e
    ON nu.user_pseudo_id = e.user_pseudo_id
  GROUP BY nu.user_pseudo_id
)

SELECT
  nu.user_pseudo_id,
  nu.first_visit_ts,
  nu.first_visit_date,
  nu.first_device_category,
  nu.first_country,
  nu.first_user_source,
  nu.first_user_medium,
  nu.first_user_campaign,

  ue.first_add_to_cart_ts,
  DATE(ue.first_add_to_cart_ts) AS first_add_to_cart_date,

  CASE
    WHEN ue.first_add_to_cart_ts >= nu.first_visit_ts
     AND ue.first_add_to_cart_ts < TIMESTAMP_ADD(nu.first_visit_ts, INTERVAL 7 DAY)
    THEN TRUE
    ELSE FALSE
  END AS activated_flag,

  CASE
    WHEN ue.first_add_to_cart_ts >= nu.first_visit_ts
     AND ue.first_add_to_cart_ts < TIMESTAMP_ADD(nu.first_visit_ts, INTERVAL 7 DAY)
    THEN TIMESTAMP_DIFF(ue.first_add_to_cart_ts, nu.first_visit_ts, HOUR) / 24.0
    ELSE NULL
  END AS days_to_activation,

  ue.first_purchase_ts,
  DATE(ue.first_purchase_ts) AS first_purchase_date,

  ue.first_purchase_ts IS NOT NULL AS purchased_flag,

  ue.view_item_events,
  ue.add_to_cart_events,
  ue.begin_checkout_events,
  ue.purchase_events

FROM new_users nu
LEFT JOIN user_events ue
  ON nu.user_pseudo_id = ue.user_pseudo_id;
