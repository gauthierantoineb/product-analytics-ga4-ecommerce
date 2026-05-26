# Définitions des KPIs

## Périmètre principal

Population principale utilisée pour l’activation, le funnel et la rétention :

> utilisateurs ayant un événement `first_visit` observé dans la période analysée.

Nombre de nouveaux utilisateurs observés : **257 314**

---

## Utilisateur observé

Un utilisateur observé correspond à un `user_pseudo_id` présent dans les événements GA4.

Limite : `user_pseudo_id` est un identifiant anonymisé GA4, pas un identifiant client réel.

---

## Nouvel utilisateur observé

Un nouvel utilisateur observé est un utilisateur ayant au moins un événement :

`first_visit`

dans la période analysée.

---

## Session

Une session est reconstruite avec :

`user_pseudo_id + ga_session_id`

Le nombre de sessions reconstruites est légèrement supérieur au nombre d’événements `session_start`, ce qui suggère quelques incohérences de tracking.

---

## Activation

Un utilisateur est considéré comme activé s’il réalise :

`add_to_cart`

dans les **7 jours suivant son `first_visit`**.

Formule :

```text
activated_users / new_users_observed
```

Résultat observé :

```text
10 280 / 257 314 = 4,0 %
```

---

## Taux d’achat

Le taux d’achat mesure la part des nouveaux utilisateurs observés ayant réalisé au moins un événement :

`purchase`

Formule :

```text
purchasers / new_users_observed
```

Résultat observé :

```text
3 511 / 257 314 = 1,36 %
```

---

## Taux d’achat des activés

Part des utilisateurs activés ayant réalisé au moins un achat.

Formule :

```text
purchasers_activated / activated_users
```

Résultat observé :

```text
2 061 / 10 280 = 20,0 %
```

---

## Taux d’achat des non activés

Part des utilisateurs non activés ayant réalisé au moins un achat.

Formule :

```text
purchasers_non_activated / non_activated_users
```

Résultat observé :

```text
1 450 / 247 034 = 0,6 %
```

---

## Funnel utilisateur

Funnel principal :

```text
first_visit → view_item → add_to_cart → begin_checkout → purchase
```

Le funnel est calculé au niveau utilisateur.

Un utilisateur est compté dans une étape s’il a réalisé l’événement correspondant après son `first_visit`.

---

## % depuis le départ

Pour chaque étape du funnel :

```text
users_at_step / first_visit_users
```

Exemple :

```text
view_item_users / first_visit_users
55 749 / 257 314 = 21,7 %
```

---

## Taux de passage entre étapes

Pour chaque étape :

```text
users_at_step_n / users_at_step_n-1
```

Exemples observés :

```text
First visit → View item: 21,7 %
View item → Add to cart: 20,2 %
Add to cart → Begin checkout: 73,8 %
Begin checkout → Purchase: 42,2 %
```

---

## Rétention hebdomadaire

La rétention est mesurée par cohorte hebdomadaire de `first_visit`.

Un utilisateur est considéré comme retenu s’il génère une activité shopping dans une semaine ultérieure.

Événements d’activité shopping retenus :

```text
view_item
add_to_cart
begin_checkout
purchase
view_search_results
select_item
```

Formule :

```text
retained_users_week_n / cohort_users
```

Limite : cette métrique mesure une activité shopping récurrente, pas une fidélité client complète.
