# Spike 0.2 — HealthKit

Validation des assomptions architecturales sur HealthKit comme "hub universel" pour CoachingSage.

## Objectifs (Story 0.2)

- ✅ Demander l'autorisation HealthKit sans crash
- ✅ Lire les pas (iPhone seul, FR43)
- ✅ Lire la fréquence cardiaque (Apple Watch ou autre source via HealthKit, FR41/FR42)
- ✅ Lire les workouts toutes sources (FR41 — le test crucial du "hub universel")
- ✅ Écrire un workout (running) dans Apple Santé (FR45)

## Ce que tu dois faire (5 minutes Xcode)

### 1. Créer le projet Xcode

1. **Xcode → File → New → Project**
2. **iOS → App** → Next
3. **Configuration** :
   - Product Name : `HealthKitSpike`
   - Team : ton équipe Apple Developer (ou Personal Team)
   - Organization Identifier : `com.sopddl`
   - Bundle Identifier : `com.sopddl.coachingsage.healthkitspike` (auto)
   - Interface : **SwiftUI**
   - Language : **Swift**
   - Storage : **None** (pas de SwiftData/CoreData)
   - Use Tests : décoché
4. **Save** dans : `/Users/sophieslama/CL3/CoachingSage/Spike/HealthKit/`
   - Quand le wizard te demande où sauvegarder, choisis le dossier `HealthKit/`
   - Décoche "Create Git repository on my Mac"

### 2. Remplacer les fichiers générés par les fichiers du spike

Xcode a créé un dossier `HealthKitSpike/` à l'intérieur de `HealthKit/`. Il contient :
- `HealthKitSpikeApp.swift` (généré)
- `ContentView.swift` (généré)
- `Assets.xcassets`
- `Preview Content/`

Tu dois :
1. **Supprimer** `ContentView.swift` du projet (clic droit → Delete → Move to Trash)
2. **Drag-drop** dans Xcode mes 3 fichiers depuis Finder (le dossier `HealthKitSpike/` à côté de cette README) :
   - `HealthKitService.swift`
   - `HealthKitSpikeView.swift`
3. **Remplacer** le contenu de `HealthKitSpikeApp.swift` par le mien (ou laisser le miens écraser via drag-drop avec "Replace files in destination")

⚠️ **Quand tu drag-drop, COCHE** "Copy items if needed" ET "Add to targets : HealthKitSpike".

### 3. Activer HealthKit (Capabilities)

1. Sélectionne le **projet** dans Xcode (icône bleue tout en haut du navigator)
2. Onglet **Signing & Capabilities**
3. Bouton **+ Capability** → **HealthKit**
4. Une fois ajouté, **NE COCHE PAS** "Clinical Health Records" ni "Background Delivery" pour ce spike — on n'en a pas besoin

Cela crée automatiquement un fichier `HealthKitSpike.entitlements` que Xcode lie au projet. Si tu vois mon fichier `HealthKitSpike.entitlements` que j'ai mis dans le dossier, tu peux le **supprimer** (Xcode a créé le sien).

### 4. Ajouter les usage descriptions à Info.plist

Sans ces 2 clés, l'app crashera quand tu cliques sur "Demander l'autorisation".

**Méthode A (recommandée, Xcode 15+)** :
1. Sélectionne le projet → **TARGET HealthKitSpike** → onglet **Info**
2. Dans la section "Custom iOS Target Properties", clic droit → **Add Row**
3. Ajoute la clé : `Privacy - Health Share Usage Description`
   - Valeur : `HealthKitSpike a besoin de lire vos données d'activité pour valider l'intégration HealthKit du futur app CoachingSage.`
4. Ajoute une 2e clé : `Privacy - Health Update Usage Description`
   - Valeur : `HealthKitSpike a besoin d'écrire vos workouts dans Apple Santé pour tester l'export vers Health.`

**Méthode B (édition directe)** : ouvre `Info-additions.plist` dans ce dossier, copie les `<key>` et `<string>` et colle-les dans ton Info.plist.

### 5. Choisir le destination et lancer

**Pour tester sur simulateur** (validation rapide des autorisations + steps + write workout) :
1. Top bar Xcode → choisir un simulateur **iPhone 15 Pro** ou similaire
2. **Cmd+R** pour build & run
3. Quand l'app demande l'autorisation HealthKit, **autorise tout**
4. Tape les boutons :
   - "Lire mes pas" → 0 (normal sur simu sans données)
   - "Écrire un faux workout running" → vérifie le ✅
   - "Lire mes workouts" → tu dois voir le workout que tu viens d'écrire
5. **Vérifie dans l'app Santé du simulateur** : Cmd+Shift+H pour aller au home, ouvre Santé → Parcourir → Activité → Workouts → tu dois voir le running 30min/5km

**Pour tester complètement** (sur ton iPhone avec Apple Watch) :
1. Connecte ton iPhone par câble
2. Top bar Xcode → choisir ton iPhone
3. Cmd+R
4. Si erreur de signature, va dans Signing & Capabilities et choisis ton équipe Apple Developer
5. Sur l'iPhone, autorise tout dans le prompt HealthKit (coche les 5 catégories : Heart Rate, Steps, Active Energy, Distance, Workouts)
6. Tape les 4 boutons un par un :
   - **Pas** : doit afficher tes vrais pas
   - **FC** : doit afficher tes BPM récents (depuis Apple Watch)
   - **Workouts** : doit afficher tes vrais workouts (Apple Watch + autres sources si tu en as comme Garmin/Strava/Nike)
   - **Écrire workout** : ajoute un faux running, vérifie qu'il apparaît dans l'app Santé

### 6. Valider chaque critère et reporter

Pour chaque critère, note dans un fichier `Spike/HealthKit/results.md` :

```markdown
- [ ] Autorisation HealthKit accordée sans crash
- [ ] Steps lus (avec data injectée sur simu OR vraies sur device)
- [ ] HR lue (sur device avec Watch — note la source)
- [ ] Workouts d'autres sources visibles (note les sources : "Apple Watch", "Garmin Connect", "Strava"...)
- [ ] Workout running écrit visible dans l'app Santé
```

## Ce que je peux pré-valider sans toi

Rien — HealthKit n'est testable que sur iOS, donc tu dois faire l'étape Xcode au minimum. Mais une fois le projet créé, tout le reste devrait être plug-and-play.

## Si ça plante

| Erreur | Cause probable | Fix |
|---|---|---|
| `[Authorization] HKHealthStore: Unauthorized access` | Tu n'as pas mis les usage descriptions dans Info.plist | Étape 4 |
| `[HealthKit] HealthKit is not available on this device` | Tu testes sur Mac Catalyst ou simulateur très ancien | Utilise un iPhone simulator iOS 17+ |
| Code signing failed | Pas de team Apple Developer configurée | Signing & Capabilities → choisis "Personal Team" si tu n'as pas d'org |
| Entitlement HealthKit grayed out | Capability HealthKit pas ajoutée | Étape 3 |

## Quand c'est fait

Ping-moi avec le résultat (passe / fail / quels critères OK et lesquels KO) et je documente le findings du spike. On pourra ensuite enchaîner sur Spike 0.1 GPS.
