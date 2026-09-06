# <Nom du produit> : brief produit

Rédigé le <date>. Mis à jour à chaque décision (table « Décisions », avec la date).
Lu en premier par `/design-prototypes` et `/create-plan`.

## Pitch

<Une phrase : pour qui, quel problème, quelle promesse.>

## Utilisateur et problème

- **Qui** : <persona en une phrase>
- **Aujourd'hui** : <ce qu'il fait sans l'app, ce que ça coûte>
- **Pourquoi natif iOS** : <la raison qui justifie une app plutôt que le web>

## Le flow qui vaut tout

<Du lancement à « fait », trois écrans au plus. Ce que fait un utilisateur qui revient en dix secondes.>

## Écrans v1

| Écran | Rôle | États à prototyper | Action primaire |
|---|---|---|---|
| <slug> | <une phrase> | loading / empty / error / <spécifiques> | <une seule> |

## Hors périmètre v1

| Idée | Pourquoi plus tard |
|---|---|
| <…> | <…> |

## Modèle et App Store

- **Modèle** : <gratuit / payant / abonnement / achat intégré / payé ailleurs> et la règle du store qui s'applique.
- **Compte** : <aucun / requis / optionnel>, fournisseur, Sign in with Apple si tiers.
- **Données collectées** : <liste> → étiquette de confidentialité, `PrivacyInfo.xcprivacy`.
- **Classification d'âge** : <…>
- **Risque de première soumission** : <…>

## Décisions techniques

| Sujet | Choix | Pourquoi | Date |
|---|---|---|---|
| iOS minimum | 18.0, Liquid Glass sur 26 via `GlassCompat` | <…> | <date> |
| Appareils | iPhone <, iPad> | <…> | <date> |
| Hors ligne | <…> | <…> | <date> |
| Données | <aucune / SwiftData / API / BaaS> | <…> | <date> |
| Auth | <…> | <…> | <date> |
| Notifications, widgets, liens universels | <…> | <…> | <date> |
| Langues | en + fr | <…> | <date> |
| Analytics, crash | <aucun / …> | <…> | <date> |
| Dépendances | SPM uniquement : <liste justifiée> | <…> | <date> |

## Direction design

- **Mots** : <trois>
- **Références** : <app 1 : ce qu'on prend> ; <app 2 : ce qu'on prend>
- **Accent** : <couleur ou neutre> ; **typo** : <système / police de marque> ; **densité** : <…> ; **mouvement** : <…>
- **Marque** : <wordmark / icône : ce qui existe, ce qui manque>

## Risques et vérifications préalables

| Risque | Vérification | Quand |
|---|---|---|
| <…> | <…> | <avant la phase N> |

## Impacts hors repo

| Où | Quoi |
|---|---|
| <API / infra / design / store> | <…> |

## Identité

- **Nom du produit (module Swift)** : <ProductName>
- **Bundle id** : <com.company.product>
- **Nom affiché** : <Display Name>
