-- Project: Product Analytics - GA4 Ecommerce
-- Layer: staging
-- Grain: 1 row = 1 event

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.stg_events_base` AS

SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_date,
  TIMESTAMP_MICROS(event_timestamp) AS event_ts,
  event_name,
  user_pseudo_id,

  (
    SELECT ep.value.int_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'ga_session_id'
  ) AS ga_session_id,

  (
    SELECT ep.value.int_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'ga_session_number'
  ) AS ga_session_number,

  CONCAT(
    user_pseudo_id,
    '-',
    CAST((
      SELECT ep.value.int_value
      FROM UNNEST(event_params) ep
      WHERE ep.key = 'ga_session_id'
    ) AS STRING)
  ) AS session_key,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'page_location'
  ) AS page_location,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'page_title'
  ) AS page_title,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'page_referrer'
  ) AS page_referrer,

  (
    SELECT ep.value.int_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'engagement_time_msec'
  ) AS engagement_time_msec,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'search_term'
  ) AS search_term,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'transaction_id'
  ) AS transaction_id,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'payment_type'
  ) AS payment_type,

  COALESCE(
    (
      SELECT ep.value.double_value
      FROM UNNEST(event_params) ep
      WHERE ep.key = 'value'
    ),
    CAST((
      SELECT ep.value.int_value
      FROM UNNEST(event_params) ep
      WHERE ep.key = 'value'
    ) AS FLOAT64),
    (
      SELECT ep.value.float_value
      FROM UNNEST(event_params) ep
      WHERE ep.key = 'value'
    )
  ) AS purchase_value,

  (
    SELECT ep.value.string_value
    FROM UNNEST(event_params) ep
    WHERE ep.key = 'coupon'
  ) AS coupon,

  platform,
  device.category AS device_category,
  device.web_info.browser AS browser,
  geo.country AS country,
  traffic_source.source AS user_source,
  traffic_source.medium AS user_medium,
  traffic_source.name AS user_campaign

FROM `projet2-494122.ecommerce_analytics.events_all`;
