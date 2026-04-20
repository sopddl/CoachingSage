# Spike 0.1 — GPS background tracking

Validation que le tracking GPS continu en arrière-plan fonctionne sur iPhone, comme une séance de course Apple Watch (Strava-style). Prérequis bloquant pour CoachingSage Epic 4 (tracking endurance).

## Critères PASS (Story 0.1)

- ✅ Tracking GPS continue quand l'app est en background
- ✅ Précision moyenne < 10 m en conditions urbaines
- ✅ First fix < 10 secondes
- ✅ Consommation batterie documentée (% par heure de tracking)
- ✅ Aucun crash après tracking continu

## Setup Xcode (≈ 5 min)

### 1. Créer le projet Xcode

1. **Xcode → File → New → Project** (⇧⌘N)
2. **iOS → App** → Next
3. Configuration :
   - Product Name : `GPSSpike`
   - Organization Identifier : `com.sopddl`
   - Bundle Identifier : `com.sopddl.GPSSpike` (auto)
   - Interface : **SwiftUI**
   - Language : **Swift**
   - Storage : **None**
   - Tests : **None**
4. **Save** dans : `/Users/sophieslama/CL3/CoachingSage/Spike/GPS/`
5. Décoche "Create Git repository"

### 2. Importer mes fichiers Swift

Ouvre Finder à : `/Users/sophieslama/CL3/CoachingSage/Spike/GPS/_source-files/`

Drag-drop dans Xcode (dossier bleu `GPSSpike` du navigator gauche) ces 2 fichiers :
- `LocationService.swift`
- `GPSSpikeView.swift`

⚠️ **Coche "Copy items if needed" + Add to target GPSSpike**.

### 3. Modifier GPSSpikeApp.swift

Click sur `GPSSpikeApp.swift` dans le navigator. Remplace `ContentView()` par `GPSSpikeView()`. Sauvegarde.

### 4. Supprimer ContentView.swift

Clic droit sur `ContentView` → Delete → Move to Trash.

### 5. Activer la capability "Background Modes" + Location

1. Click sur l'icône bleue **`GPSSpike`** en haut du navigator
2. Sélectionne sous **TARGETS** (pas PROJECT) → **GPSSpike**
3. Onglet **Signing & Capabilities**
4. Bouton **+ Capability** → cherche **Background Modes** → double-click
5. Dans la section Background Modes qui apparaît, **coche** :
   - ✅ **Location updates**
6. (Tu peux laisser tous les autres décochés)

### 6. Ajouter les usage descriptions à Info.plist

1. Toujours TARGETS → GPSSpike
2. Onglet **Info**
3. Survole une ligne existante → click le **+** → ajoute ces 2 clés :

| Key | Value |
|---|---|
| `Privacy - Location When In Use Usage Description` | `GPSSpike a besoin d'accéder à votre position pour valider le tracking GPS background du futur app CoachingSage.` |
| `Privacy - Location Always and When In Use Usage Description` | `GPSSpike a besoin d'un accès continu à votre position pour valider le tracking GPS en arrière-plan, comme une vraie séance de course/marche enregistrée par CoachingSage.` |

### 7. Régler le deployment target

Comme pour HealthKit : TARGETS → GPSSpike → General → Minimum Deployments → **iOS 17.0**

### 8. Lancer sur ton iPhone

1. Connecte ton iPhone par câble
2. Sélecteur de destination (top bar) → choisis ton iPhone
3. **Cmd+R**
4. Si erreur signing → choisis ta team Apple Developer

## Comment faire le test pendant ta balade

### Phase A — Avant de partir (chez toi)

1. L'app `GPSSpike` se lance sur ton iPhone
2. Section **Autorisation** → click **"Demander accès localisation"**
   - Popup iOS → choisis **"Autoriser pendant l'utilisation"**
3. Le statut affiche maintenant "Pendant utilisation ⚠️"
4. Click **"Demander accès \"Toujours\" (background)"**
   - Popup iOS → choisis **"Modifier en Toujours"** ou **"Autoriser toujours"**
5. Le statut doit afficher **"Toujours ✅"** en vert
6. **Note ton % de batterie actuel** dans `results.md`

### Phase B — Démarrer le tracking (sur le pas de la porte)

1. Click **"Démarrer le tracking"**
2. Le statut passe à **"Acquisition GPS..."** (orange) puis dès qu'il y a un fix, **"Tracking actif"** (vert)
3. Vérifie dans la section **Stats live** :
   - "First fix" doit s'afficher en moins de 10 secondes ✅
   - "Précision moyenne" doit être < 10 m (sauf si tu es dans un canyon urbain dense)
4. **Verrouille ton téléphone** (bouton power) — c'est CRITIQUE pour tester le background
5. Pars marcher / courir

### Phase C — Pendant la balade (15-60 min, à toi)

- **Marche / cours normalement** avec ton iPhone dans la poche
- iOS affichera une **barre bleue ou un point bleu en haut de l'écran** quand tu déverrouilleras → c'est NORMAL et c'est ce qu'on veut (preuve que la localisation tourne en background)
- **Ne touche pas à l'app**, laisse-la tourner verrouillée
- Tu peux faire d'autres trucs sur ton téléphone normalement (musique, messages, etc.)

### Phase D — Au retour (chez toi)

1. Déverrouille ton téléphone, ouvre l'app GPSSpike
2. Vérifie les stats :
   - **Temps écoulé** : ~le temps de ta balade
   - **Distance totale** : doit ressembler à la vraie distance parcourue (compare avec Apple Plans / Strava si tu en as un)
   - **Points GPS capturés** : > 50 idéalement (1 point tous les ~5m, donc dépend de la distance)
   - **Précision moyenne** : < 10 m si tout va bien
   - **Passé en background** : ✅ (CRUCIAL — confirme que le tracking a survécu au verrouillage)
   - **Drop batterie /h** : note la valeur — si < 15%/h c'est très bien, si > 25%/h c'est inquiétant
3. Click **"Arrêter et terminer"**
4. **Note tous les chiffres dans `results.md`**

### Phase E — Vérification crash

Si tu as l'impression que l'app a crashé pendant la balade :
- Le statut "App killée pendant tracking" en rouge t'avertira la prochaine fois que tu ouvriras l'app
- Si tu vois ça → SPIKE FAIL → on doit débugger

## Si ça plante

| Erreur | Cause probable | Fix |
|---|---|---|
| Pas de popup localisation | Clés Privacy manquantes dans Info.plist | Étape 6 |
| "Background updates not enabled" | Background Modes pas activée | Étape 5 |
| First fix > 30s ou jamais | Tu es à l'intérieur, pas de vue ciel | Sors dehors |
| Précision > 30m systématiquement | Buildings serrés / météo | Note-le, c'est une donnée du spike |
| App crash random | Note l'heure et regarde `Réglages → Confidentialité → Diagnostics` | Me reporter |

## Quand c'est fait

Reviens me voir avec les chiffres de Phase D, je remplirai `results.md` proprement et on clôturera officiellement le spike 0.1. Si tout est PASS, **les 3 spikes Epic 0 sont bouclés** et on peut passer à Epic 0.5 (templates) puis Epic 1 (Foundation).
