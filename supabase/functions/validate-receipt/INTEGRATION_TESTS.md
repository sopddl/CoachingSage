# Tests d'intégration runtime — validate-receipt

Léon+ V1. Ces tests sont à exécuter MANUELLEMENT quand l'Edge Function est
déployée et que la migration `010_leon_plus_subscription.sql` est appliquée.
Pas de harness Deno automatisé dans ce repo (même convention que
`sage-coaching-ai/INTEGRATION_TESTS.md`) — un vrai JWS StoreKit 2 ne peut être
généré qu'en simulateur (fichier `.storekit`) ou en sandbox App Store.

## Pré-requis déploiement

```bash
# 1. Appliquer la migration
# Supabase Dashboard → SQL Editor → coller supabase/migrations/010_leon_plus_subscription.sql

# 2. Deploy la function
supabase functions deploy validate-receipt
```

## Générer un JWS de test (sans StoreKit)

Un JWS StoreKit 2 est un JWT à 3 parties (header.payload.signature) non vérifié
signature ici (cf. dette documentée dans `index.ts`) — seul le payload base64url
compte pour ces tests manuels :

```bash
PAYLOAD=$(echo -n '{"transactionId":"1000000123456789","originalTransactionId":"1000000123456789","productId":"leon.plus.monthly","purchaseDate":1735000000000,"expiresDate":1737678400000,"type":"Auto-Renewable Subscription","environment":"Sandbox"}' | base64 | tr '+/' '-_' | tr -d '=')
JWS="eyJhbGciOiJFUzI1NiJ9.${PAYLOAD}.fake-signature-not-verified"
```

## Tests

### T1 — Achat Léon+ valide → tier "plus"

**Input** : `{ signed_transaction: $JWS, product_id: "leon.plus.monthly" }`,
header `Authorization: Bearer <jwt_user_valide>`.

**Expected** :
- HTTP 200, `{ status: "ok", tier: "plus", expires_at: "2026-01-24T..." }`
- `subscription_receipts` contient une ligne avec `original_transaction_id =
  "1000000123456789"`, `environment = "sandbox"`
- `core_profiles.subscription_tier = "plus"` pour ce user

### T2 — Rejeu du même transaction_id → idempotent, pas de doublon

**Input** : même requête que T1, envoyée 2 fois.

**Expected** : HTTP 200 les deux fois, `subscription_receipts` a toujours
exactement 1 ligne pour `original_transaction_id = "1000000123456789"` (upsert
`onConflict`, pas d'erreur de contrainte UNIQUE).

### T3 — product_id ne correspond pas au JWS → rejeté

**Input** : `{ signed_transaction: $JWS, product_id: "leon.plus.wrong" }`.

**Expected** : HTTP 400, `{ error: "invalid_receipt", reason: "Product ID mismatch" }`.
`core_profiles.subscription_tier` INCHANGÉ.

### T4 — Produit inconnu (hors TIER_MAP) → rejeté proprement

**Input** : JWS avec `productId: "leon.questions.50"` (pas encore dans
`TIER_MAP`, V1 = Léon+ seul).

**Expected** : HTTP 400, `{ error: "invalid_receipt", reason: "Unknown product: leon.questions.50" }`.
Le reçu est quand même stocké dans `subscription_receipts` (traçabilité), mais
`core_profiles` n'est PAS modifié.

### T5 — Sans Authorization header → 401

**Input** : requête sans header `Authorization`.

**Expected** : HTTP 401, `{ error: "Missing authorization" }`.

### T6 — JWS malformé → 400 sans crash

**Input** : `{ signed_transaction: "pas-un-jws", product_id: "leon.plus.monthly" }`.

**Expected** : HTTP 400, `{ error: "invalid_receipt", reason: "Failed to decode JWS" }`.

## Vérification quota post-achat

Après T1, vérifier que `checkQuota()` (`sage-coaching-ai/rate_limit.ts`) retourne
bien `{ allowed: true, limit: -1, tier: "plus" }` pour ce user — aucune
modification de ce fichier n'est nécessaire, il lit déjà `subscription_tier`.
