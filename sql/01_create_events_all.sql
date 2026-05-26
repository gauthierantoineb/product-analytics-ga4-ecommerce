-- Project: Product Analytics - GA4 Ecommerce
-- Layer: source view
-- Source: bigquery-public-data.ga4_obfuscated_sample_ecommerce

CREATE OR REPLACE VIEW `projet2-494122.ecommerce_analytics.events_all` AS

SELECT *
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`;
