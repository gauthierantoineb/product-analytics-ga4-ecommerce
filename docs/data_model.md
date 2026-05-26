# Data Model

## Source

Dataset public utilisé :

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

Les données source sont des événements GA4 stockés dans des tables journalières :

`events_YYYYMMDD`

Une vue source a été créée pour unifier ces tables :

`projet2-494122.ecommerce_analytics.events_all`

---

## Architecture

Le modèle suit une logique en couches :

```text
source view → staging → dimensions / facts → marts
```

---

## Tables

### `events_all`

**Type :** vue  
**Grain :** 1 ligne = 1 événement GA4 brut

Rôle :

- unifier les tables journalières `events_*` ;
- servir de point d’entrée unique vers les données source.

---

### `stg_events_base`

**Type :** table  
**Grain :** 1 ligne = 1 événement

Rôle :

- nettoyer les dates et timestamps ;
- extraire les paramètres GA4 utiles ;
- reconstruire une clé de session ;
- préparer les dimensions d’analyse.

Champs clés :

- `event_date`
- `event_ts`
- `event_name`
- `user_pseudo_id`
- `ga_session_id`
- `ga_session_number`
- `session_key`
- `device_category`
- `browser`
- `country`
- `user_source`
- `user_medium`
- `user_campaign`

---

### `dim_users_first_touch`

**Type :** table  
**Grain :** 1 ligne = 1 utilisateur

Rôle :

- identifier le premier événement observé ;
- identifier la première visite GA4 (`first_visit`) ;
- distinguer les nouveaux utilisateurs observés des utilisateurs préexistants ou inconnus.

Champs clés :

- `user_pseudo_id`
- `first_seen_ts`
- `first_seen_date`
- `first_visit_ts`
- `first_visit_date`
- `has_first_visit`
- `user_cohort_type`
- `first_device_category`
- `first_country`
- `first_user_source`
- `first_user_medium`

---

### `fct_activation_status`

**Type :** table  
**Grain :** 1 ligne = 1 nouvel utilisateur observé

Rôle :

- calculer le statut d’activation ;
- mesurer le délai vers activation ;
- identifier les utilisateurs acheteurs ;
- comparer activés vs non activés.

Définition de l’activation :

```text
add_to_cart dans les 7 jours suivant first_visit
```

Champs clés :

- `user_pseudo_id`
- `first_visit_ts`
- `first_add_to_cart_ts`
- `activated_flag`
- `days_to_activation`
- `first_purchase_ts`
- `purchased_flag`

---

### `fct_funnel_steps`

**Type :** table  
**Grain :** 1 ligne = 1 nouvel utilisateur observé

Rôle :

- identifier les étapes atteintes dans le funnel utilisateur.

Funnel :

```text
first_visit → view_item → add_to_cart → begin_checkout → purchase
```

Champs clés :

- `reached_first_visit`
- `reached_view_item`
- `reached_add_to_cart`
- `reached_begin_checkout`
- `reached_purchase`

---

### `fct_retention_weekly`

**Type :** table  
**Grain :** cohorte x statut d’activation x semaine

Rôle :

- calculer les utilisateurs retenus par semaine ;
- préparer la base de calcul de la rétention.

Champs clés :

- `cohort_week`
- `activated_flag`
- `week_number`
- `retained_users`

---

### `mart_retention_weekly`

**Type :** table  
**Grain :** cohorte x statut d’activation x semaine

Rôle :

- ajouter la taille de cohorte ;
- calculer le taux de rétention.

Champs clés :

- `cohort_week`
- `activated_flag`
- `week_number`
- `cohort_users`
- `retained_users`
- `retention_rate`

---

### `mart_product_kpis_daily`

**Type :** table  
**Grain :** 1 ligne = 1 jour

Rôle :

- suivre les KPIs produit quotidiens.

Champs clés :

- `event_date`
- `active_users`
- `sessions`
- `events`
- `product_viewers`
- `add_to_cart_users`
- `checkout_users`
- `purchasers`
- `daily_add_to_cart_rate`
- `daily_purchase_rate`

---

### `mart_funnel_global`

**Type :** table  
**Grain :** 1 ligne = 1 étape du funnel

Rôle :

- fournir un funnel global prêt pour analyse ou reporting.

Champs clés :

- `step_order`
- `step_name`
- `users`
- `pct_from_start`
- `pct_from_previous_step`
- `dropoff_from_previous_step`

---

### `mart_funnel_by_device`

**Type :** table  
**Grain :** device x étape du funnel

Rôle :

- comparer le funnel selon le device.

Champs clés :

- `device_category`
- `step_order`
- `step_name`
- `users`
- `pct_from_start`
- `pct_from_previous_step`
- `dropoff_from_previous_step`

---

## Remarques importantes

### Population principale

Les analyses d’activation, de funnel et de rétention utilisent uniquement les utilisateurs ayant un `first_visit` observé dans la période.

Les utilisateurs sans `first_visit` sont classés comme :

```text
pre_existing_or_unknown
```

Ils sont exclus du dénominateur principal d’activation.

---

### Session

La clé de session est reconstruite avec :

```text
user_pseudo_id + ga_session_id
```

Le nombre de sessions reconstruites est légèrement supérieur au nombre d’événements `session_start`, ce qui suggère quelques incohérences de tracking.

---

### Funnel

Le funnel est calculé au niveau utilisateur.

Un utilisateur est compté dans une étape s’il a réalisé l’événement correspondant après son `first_visit`.

---

### Rétention

La rétention est hebdomadaire et basée sur une activité shopping.

Événements utilisés :

```text
view_item
add_to_cart
begin_checkout
purchase
view_search_results
select_item
```

Cette métrique mesure un retour avec activité shopping, pas une fidélité client complète.
