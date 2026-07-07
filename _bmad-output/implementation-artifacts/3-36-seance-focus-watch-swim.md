# Story 3.36 — Séance FOCUS au poignet : app Apple Watch swim (EXÉCUTER hors de portée)

Status: **draft** — à scoper finement (chantier infra séparé, spike d'abord)
Branche cible : `epic-3/story-3.36-watch-swim`
Effort estimé : **~6-10j** (création d'une cible Apple Watch = nouveau socle app)
Source : Party 2026-06-02 (T2). Dépendances : **3.32 (HUB) + 3.33 (modèle `SessionStep`)** ; **nouvelle cible watchOS**.

> **Pourquoi à part** : en natation le téléphone est inaccessible. Le mode EXÉCUTER swim vit donc **sur la montre**. Cela suppose une **app Apple Watch** — qui n'existe pas encore dans le projet. C'est un **chantier infra** (nouvelle cible, partage de modèle, sync), plus lourd que les autres modes. À scoper finement avant dev.

## Story

**As a** nageur·se (téléphone au bord du bassin),
**I want** voir/égrener ma séance **au poignet** (la séance « dans la tête » + relais montre, haptique entre séries),
**so that** j'exécute mes séries sans toucher mon téléphone dans l'eau.

## Contexte produit

- **4ᵉ façon d'avancer** : **Au poignet**. Le FOCUS swim ne vit pas sur l'iPhone pendant la séance.
- **V1 réaliste (T2 figé)** : **Apple Watch uniquement** (Garmin/Coros/Polar = écosystèmes fermés, hors de notre contrôle ; pour ces montres l'utilisateur s'appuie sur la **pré-lecture mémorisable** du HUB iPhone).
- **Le HUB iPhone (3.32) reste le socle PRÉPARER** : il doit déjà rendre la séance swim **ultra-mémorisable** (séries claires) — ça, c'est livré sans la montre.
- **Lien Story 3.16** : l'analytics natation (records/tendances/autoprofil, fenêtre 1 an) est livrée (Phase 2.E). Ici on parle **exécution**, pas analytics.

## Décisions (Party + réalité tech)

1. **Apple Watch only** en V1. Autres montres = hors scope (documenté), couverts par « PRÉPARER mémorisable » sur iPhone.
2. **Relais minimal d'abord** : afficher la séance série par série au poignet + **haptique** au changement de série/repos. Pas de capteurs/Workout HealthKit complets en première itération (peut suivre).
3. **Partage du modèle** : `SessionStep`/`AdaptedSession` partagés iPhone ↔ Watch (cible partagée / package). Transfert via `WatchConnectivity`.
4. **Dégradé sans montre** : si pas d'Apple Watch appairée, le bouton « ▶ Démarrer » d'une séance swim ouvre le **FOCUS iPhone Manuel** (3.33) au bord du bassin — pas de cul-de-sac.

## Acceptance Criteria (préliminaires — à affiner au scoping)

1. **AC1** — Nouvelle cible **watchOS** dans le projet, build OK, icône, partage du modèle séance.
2. **AC2** — La séance swim active est **envoyée à la montre** (`WatchConnectivity`) depuis l'iPhone.
3. **AC3** — Sur la montre : liste/égrenage des séries (distance, style, repos) + navigation simple (Digital Crown / tap) + **haptique** sur transition série/repos.
4. **AC4** — Complétion au poignet **remontée à l'iPhone** (séance marquée terminée, cohérent avec 3.33).
5. **AC5** — Dégradé : pas de montre → fallback FOCUS iPhone Manuel pour swim.
6. **AC6** — i18n FR/EN (ES chantier). Test device réel (Sophie : iPhone + Apple Watch, séance swim).

## Hypothèses / Risques (élevés)
- **R1 — Coût d'une 1ʳᵉ cible Watch** : signing, provisioning, partage de code, build CI → **sous-estimer = piège**. Scoper finement, possiblement spike d'abord.
- **R2 — WatchConnectivity** : fiabilité du transfert (séance pas trop grosse), états offline.
- **R3 — HealthKit Workout sur Watch** (mesures réelles) : **hors V1** (sinon explose le scope) ; ici relais d'affichage + haptique seulement.

## Out of scope
- Montres non-Apple. Capture HealthKit Workout complète sur Watch (V2). Localisation ES.

## Fichiers / cibles (preview)
**Nouveaux :**
- Cible **`CoachingSageWatch`** (app watchOS) + ses vues (liste séries, haptique).
- Couche **`WatchConnectivity`** des deux côtés (envoi séance / retour complétion).
- Package/cible partagée pour `SessionStep`/`AdaptedSession`.

**Modifiés :**
- `SessionDetailView`/`SessionFocusViewModel` — router swim vers la montre si appairée, sinon fallback iPhone.

## Jalons (indicatifs — à confirmer après spike)
- **J0 (spike ~1j)** — Créer la cible Watch, faire transiter une séance factice, valider build/signing.
- **J1 (~2-3j)** — Partage modèle + envoi séance + UI liste séries au poignet.
- **J2 (~2j)** — Haptique transitions + retour complétion iPhone.
- **J3 (~1-2j)** — Dégradé sans montre + i18n + device-test Sophie.

Total : **~6-10j**. **Recommandation : faire 3.32→3.35 d'abord** ; 3.36 en dernier (le plus lourd, le plus risqué).
