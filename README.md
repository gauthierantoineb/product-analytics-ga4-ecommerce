# Product Analytics — Activation et conversion utilisateur e-commerce

## Objectif

Ce projet analyse le parcours utilisateur d’un site e-commerce à partir d’événements GA4 stockés dans BigQuery.

L’objectif est d’identifier :

- où les nouveaux utilisateurs décrochent dans le parcours produit ;
- si l’activation est liée à la conversion ;
- si les utilisateurs activés reviennent davantage ;
- quelles actions produit prioriser.

---

## Dataset

Dataset public utilisé :

`bigquery-public-data.ga4_obfuscated_sample_ecommerce`

Période analysée :

**2020-11-01 → 2021-01-31**

Volume observé :

| Métrique | Valeur |
|---|---:|
| Événements | 4 295 584 |
| Utilisateurs observés | 270 154 |
| Nouveaux utilisateurs observés | 257 314 |
| Sessions reconstruites | 360 129 |

---

## Stack

- BigQuery
- SQL
- GitHub

---

## Projet BigQuery

Toutes les tables ont été créées dans :

`projet2-494122.ecommerce_analytics`

Tables principales :

| Table | Grain | Rôle |
|---|---|---|
| `events_all` | événement | Vue source unifiée sur les tables GA4 journalières |
| `stg_events_base` | 1 ligne = 1 événement | Table staging avec les champs GA4 utiles extraits |
| `dim_users_first_touch` | 1 ligne = 1 utilisateur | Première visite observée et informations utilisateur |
| `fct_activation_status` | 1 ligne = 1 nouvel utilisateur | Statut d’activation, achat et délai d’activation |
| `fct_funnel_steps` | 1 ligne = 1 nouvel utilisateur | Étapes atteintes dans le funnel |
| `fct_retention_weekly` | cohorte x semaine | Utilisateurs retenus par semaine |
| `mart_retention_weekly` | cohorte x semaine | Taux de rétention calculés |
| `mart_product_kpis_daily` | 1 ligne = 1 jour | KPIs produit quotidiens |
| `mart_funnel_global` | 1 ligne = 1 étape | Funnel global |
| `mart_funnel_by_device` | device x étape | Funnel segmenté par device |

---

## Problématique

Le site attire un volume important de nouveaux utilisateurs, mais peu d’entre eux atteignent un signal fort d’intention d’achat.

Question principale :

> Comment les nouveaux utilisateurs progressent-ils vers l’activation, et dans quelle mesure cette activation est-elle liée à la conversion et à la rétention ?

---

## Définition de l’activation

Un utilisateur est considéré comme activé s’il réalise un événement :

`add_to_cart`

dans les **7 jours suivant son `first_visit`**.

Cette définition est utilisée car l’ajout au panier représente un signal fort d’intention d’achat, plus engageant qu’une simple consultation produit, mais situé avant l’achat final.

---

## Résultats clés

### 1. L’activation est faible

| Métrique | Valeur |
|---|---:|
| Nouveaux utilisateurs observés | 257 314 |
| Utilisateurs activés | 10 280 |
| Taux d’activation | 4,0 % |

Seulement **4,0 %** des nouveaux utilisateurs atteignent l’étape d’activation.

---

### 2. L’activation est fortement liée à la conversion

| Segment | Utilisateurs | Acheteurs | Taux d’achat |
|---|---:|---:|---:|
| Activés | 10 280 | 2 061 | 20,0 % |
| Non activés | 247 034 | 1 450 | 0,6 % |

Les utilisateurs activés convertissent environ **34 fois plus** que les utilisateurs non activés.

---

### 3. Le principal décrochage se situe en début de parcours

Funnel utilisateur :

| Étape | Utilisateurs | % depuis le départ |
|---|---:|---:|
| First visit | 257 314 | 100,0 % |
| View item | 55 749 | 21,7 % |
| Add to cart | 11 258 | 4,4 % |
| Begin checkout | 8 307 | 3,2 % |
| Purchase | 3 509 | 1,4 % |

Le plus fort décrochage se produit entre `first_visit` et `view_item`.

Seulement **21,7 %** des nouveaux utilisateurs consultent une fiche produit.

---

### 4. Les utilisateurs activés reviennent davantage

Rétention hebdomadaire basée sur une activité shopping :

| Semaine après acquisition | Non activés | Activés |
|---|---:|---:|
| W1 | 0,9 % | 9,2 % |
| W2 | 0,5 % | 2,7 % |
| W4 | 0,3 % | 1,4 % |
| W8 | 0,1 % | 0,5 % |

Les utilisateurs activés sont environ **10 fois plus susceptibles de revenir en W1** avec une activité shopping.

---

### 5. La friction ne semble pas limitée à un device

| Device | Taux d’activation | Taux d’achat |
|---|---:|---:|
| Desktop | 4,0 % | 1,3 % |
| Mobile | 4,0 % | 1,4 % |
| Tablet | 3,8 % | 1,3 % |

Les performances sont proches entre desktop, mobile et tablet.
La friction semble donc liée au parcours produit global plutôt qu’à un device spécifique.

---

## Diagnostic produit

Le problème principal n’est pas uniquement le checkout.

Une fois qu’un utilisateur ajoute un produit au panier, **73,8 %** démarrent le checkout.

Le principal enjeu se situe plus tôt dans le parcours :

> trop peu de nouveaux utilisateurs consultent une fiche produit, puis ajoutent un produit au panier.

L’activation est donc le levier prioritaire, car elle est fortement associée à la conversion et à la rétention.

---

## Recommandation

Prioriser l’amélioration du parcours d’entrée pour exposer plus rapidement les nouveaux utilisateurs à des produits pertinents.

Actions recommandées :

1. améliorer la navigation vers les pages produit ;
2. mettre en avant des produits populaires dès les pages d’entrée ;
3. tester des recommandations produit personnalisées ou contextuelles ;
4. analyser les landing pages avec beaucoup de trafic mais peu de vues produit ;
5. suivre comme KPI principal le passage `first_visit → view_item → add_to_cart`.

---

## Limites

- Les données couvrent seulement **92 jours**, ce qui limite l’analyse de rétention long terme.
- La rétention est mesurée comme une activité shopping récurrente, pas comme une fidélité client complète.
- Certaines sources d’acquisition sont obfusquées ou peu exploitables : `&lt;Other&gt;`, `(data deleted)`.
- L’analyse repose sur `user_pseudo_id`, qui n’est pas un identifiant client réel.
- Le funnel est calculé au niveau utilisateur, sur les événements observés après `first_visit`.
- Le nombre de sessions reconstruites via `user_pseudo_id + ga_session_id` est légèrement supérieur au nombre d’événements `session_start`, ce qui suggère quelques incohérences de tracking.

---

## Structure du repo

```text
product-analytics-ga4-ecommerce/
│
├── README.md
│
├── sql/
│   ├── 01_create_events_all.sql
│   ├── 02_create_stg_events_base.sql
│   ├── 03_create_dim_users_first_touch.sql
│   ├── 04_create_fct_activation_status.sql
│   ├── 05_create_fct_funnel_steps.sql
│   ├── 06_create_fct_retention_weekly.sql
│   ├── 07_create_mart_retention_weekly.sql
│   ├── 08_create_mart_product_kpis_daily.sql
│   ├── 09_create_mart_funnel_global.sql
│   └── 10_create_mart_funnel_by_device.sql
│
├── docs/
│   ├── note_synthese.md
│   ├── definitions_kpi.md
│   └── data_model.md
│
└── assets/
    └── screenshots/
```

---

## Compétences démontrées

- Analyse d’un dataset événementiel GA4
- Modélisation analytique dans BigQuery
- Extraction de paramètres GA4 imbriqués
- Construction d’un funnel utilisateur
- Définition et mesure de l’activation produit
- Analyse activés vs non activés
- Cohortes de rétention hebdomadaire
- Segmentation par device et source d’acquisition
- Transformation d’analyses SQL en recommandations produit

---

## Conclusion

Le principal levier produit n’est pas l’optimisation isolée du checkout, mais l’amélioration du parcours initial.

Augmenter la proportion de nouveaux utilisateurs qui consultent une fiche produit puis ajoutent un produit au panier est le levier le plus crédible pour améliorer à la fois la conversion et la rétention.
