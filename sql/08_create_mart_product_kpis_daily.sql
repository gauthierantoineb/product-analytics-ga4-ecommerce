-- Project: Product Analytics - GA4 Ecommerce
-- Layer: mart
-- Grain: 1 row = 1 day
-- Purpose: daily product KPIs

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.mart_product_kpis_daily` AS

SELECT
  event_date,

  COUNT(DISTINCT user_pseudo_id) AS active_users,
  COUNT(DISTINCT session_key) AS sessions,
  COUNT(*) AS events,

  COUNTIF(event_name = 'view_item') AS view_item_events,
  COUNTIF(event_name = 'add_to_cart') AS add_to_cart_events,
  COUNTIF(event_name = 'begin_checkout') AS begin_checkout_events,
  COUNTIF(event_name = 'purchase') AS purchase_events,

  COUNT(DISTINCT IF(event_name = 'view_item', user_pseudo_id, NULL)) AS product_viewers,
  COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)) AS add_to_cart_users,
  COUNT(DISTINCT IF(event_name = 'begin_checkout', user_pseudo_id, NULL)) AS checkout_users,
  COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)) AS purchasers,

  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'add_to_cart', user_pseudo_id, NULL)),
    COUNT(DISTINCT user_pseudo_id)
  ) AS daily_add_to_cart_rate,

  SAFE_DIVIDE(
    COUNT(DISTINCT IF(event_name = 'purchase', user_pseudo_id, NULL)),
    COUNT(DISTINCT user_pseudo_id)
  ) AS daily_purchase_rate

FROM `projet2-494122.ecommerce_analytics.stg_events_base`
GROUP BY event_date;
