# CoachingSage — Supabase

## Setup initial (Story 1.1a.4)

1. **Créer le projet Supabase** :
   - https://supabase.com/dashboard → New Project
   - Name : `sagecoach-dev`
   - Region : **EU (Frankfurt)** — obligatoire RGPD
   - Password : générer fort, stocker 1Password

2. **Activer l'extension pg_cron** :
   - Dashboard → Database → Extensions → chercher `pg_cron` → Enable

3. **Appliquer la migration initiale** :
   - Dashboard → SQL Editor → New query
   - Copier/coller le contenu de `migrations/001_initial_schema.sql`
   - Run

4. **Activer Apple Sign In** (Apple Sign In pour Story 1.1b) :
   - Dashboard → Authentication → Providers → Apple → Enable
   - Suivre la doc Supabase pour configurer Services ID + clé JWT

5. **Récupérer les credentials** :
   - Dashboard → Project Settings → API
   - Copier `Project URL` (host seulement, sans https://) → `SUPABASE_HOST`
   - Copier `anon public` key → `SUPABASE_ANON_KEY`

6. **Remplir les xcconfig locaux** :
   - Éditer `Config-Debug.xcconfig`, `Config-Staging.xcconfig`, `Config-Release.xcconfig`
   - Remplacer les placeholders par les vraies valeurs
   - (Pour dev en local : Debug et Staging peuvent pointer vers `sagecoach-dev`, Release attend `sagecoach-prod` — à créer plus tard)

7. **Relancer l'app dans Xcode** :
   - Cmd+B puis Cmd+R
   - Le fatalError `"Credentials Supabase introuvables"` doit disparaître

## Staging + Prod

- `sagecoach-staging` : à créer avant la beta TestFlight
- `sagecoach-prod` : à créer avant App Store release

Chacun aura sa propre `001_initial_schema.sql` appliquée via dashboard.
