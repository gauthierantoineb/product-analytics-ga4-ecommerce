-- Project: Product Analytics - GA4 Ecommerce
-- Layer: mart
-- Grain: 1 row = 1 funnel step
-- Purpose: report-ready global activation funnel

CREATE OR REPLACE TABLE `projet2-494122.ecommerce_analytics.mart_funnel_global` AS

WITH funnel AS (
  SELECT
    COUNT(*) AS first_visit_users,
    COUNTIF(reached_view_item) AS view_item_users,
    COUNTIF(reached_add_to_cart) AS add_to_cart_users,
    COUNTIF(reached_begin_checkout) AS begin_checkout_users,
    COUNTIF(reached_purchase) AS purchase_users
  FROM `projet2-494122.ecommerce_analytics.fct_funnel_steps`
),

base AS (
  SELECT 1 AS step_order, 'First visit' AS step_name, first_visit_users AS users FROM funnel
  UNION ALL
  SELECT 2, 'View item', view_item_users FROM funnel
  UNION ALL
  SELECT 3, 'Add to cart', add_to_cart_users FROM funnel
  UNION ALL
  SELECT 4, 'Begin checkout', begin_checkout_users FROM funnel
  UNION ALL
  SELECT 5, 'Purchase', purchase_users FROM funnel
),

with_previous AS (
  SELECT
    step_order,
    step_name,
    users,
    FIRST_VALUE(users) OVER (ORDER BY step_order) AS first_step_users,
    LAG(users) OVER (ORDER BY step_order) AS previous_step_users
  FROM base
)

SELECT
  step_order,
  step_name,
  users,

  SAFE_DIVIDE(users, first_step_users) AS pct_from_start,

  CASE
    WHEN step_order = 1 THEN 1
    ELSE SAFE_DIVIDE(users, previous_step_users)
  END AS pct_from_previous_step,

  CASE
    WHEN step_order = 1 THEN 0
    ELSE 1 - SAFE_DIVIDE(users, previous_step_users)
  END AS dropoff_from_previous_step

FROM with_previous;
