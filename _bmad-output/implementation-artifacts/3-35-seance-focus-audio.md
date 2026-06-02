# Story 3.35 — Séance FOCUS : avance Audio-mené (run / vélo / rando) + voix TTS

Status: **ready-for-dev** (chantier)
Branche cible : `epic-3/story-3.35-seance-focus-audio`
Effort estimé : **~4-6j** (le plus lourd des modes — audio session, TTS, écran verrouillé)
Source : Party 2026-06-02 (T3 ducking + D2 voix). Dépendances : **3.33 (shell) + 3.34 (`SessionAudioCues`/timer) livrées AVANT**.

## Story

**As a** coureur·se / cycliste / randonneur·se en mouvement (téléphone en poche, écran verrouillé),
**I want** que l'app m'**annonce à la voix** le bloc en cours et les transitions, **par-dessus ma propre musique**,
**so that** je suis ma séance mains et yeux libres, sans sortir le téléphone.

## Contexte produit

- **3ᵉ façon d'avancer** du FOCUS : **Audio-mené**. La séance avance au temps (ou distance) ; une **voix** annonce les blocs/transitions, des **bips** ponctuent. L'écran reste **glançable** (gros chiffres) mais l'usage normal = poche / verrouillé.
- **Principe T3 (figé)** : **l'app ne joue jamais la musique**. Le user joue la sienne (Spotify/Apple Music/podcast) ; on glisse voix + bips **par audio ducking** (`AVAudioSession` `.duckOthers`) puis on remonte son son.
- **D2 (figé)** : **voix ON par défaut, discrète** ; l'utilisateur **choisit homme ou femme**.
- **Voix** : `AVSpeechSynthesizer` (gratuit, on-device). FR + EN natifs OK ; **ES** ajouté avec le chantier localisation. Voix Premium/Enhanced si téléchargées (invite au 1ᵉʳ usage).

## Décisions (Party, figées)

1. **Ducking, zéro intégration musicale** : on ne contrôle pas la source du user, on se contente de baisser/relever (`setActive` + `.duckOthers`).
2. **Voix ON discret + sélecteur H/F** : réglage persistant (`@AppStorage`) ; coupure facile (toggle « voix ») accessible.
3. **Réutilise l'avance Minuté (3.34)** pour le séquencement temps ; la couche audio = voix + ducking en plus des bips.
4. **Écran verrouillé / app en poche** : `isIdleTimerDisabled` pendant la séance ; audio continue en arrière-plan (capability *Audio* + `.playback`). Pas de Now Playing/contrôles lock-screen riches en V1 (peut venir après).
5. **Pré-annonce vocale anti-Decathlon** : la voix dit « Prochain : <bloc>. C'est parti » avant chaque bloc, 1ᵉʳ inclus.

## Acceptance Criteria

### (a) Couche voix + ducking
1. **AC1** — Un `SessionVoiceGuide` (nouveau) lit des phrases d'étape via `AVSpeechSynthesizer` ; chaque prise de parole **duck** l'audio tiers puis le **restaure** (`AVAudioSession.setActive(false, .notifyOthersOnDeactivation)`).
2. **AC2** — Sélecteur **voix homme / femme** (réglage persistant), appliqué à la voix selon la langue courante (FR/EN ; ES quand dispo).
3. **AC3** — Toggle **voix ON/OFF** ; OFF = bips seuls (mode 3.34). Défaut = ON.
4. **AC4** — Invite **« télécharger la voix premium »** (lien réglages iOS) au 1ᵉʳ usage si seule la voix compacte est dispo. Non bloquant.

### (b) Séquencement + écran glançable
5. **AC5** — La séance avance au temps (réutilise `SessionTimerEngine`) ; pré-annonce vocale + bips à chaque transition, **1ᵉʳ bloc inclus** (anti-Decathlon).
6. **AC6** — Écran FOCUS « glançable » : **bloc courant + temps restant en très gros**, lisible bras tendu ; reste fonctionnel mais pensé pour un coup d'œil.
7. **AC7** — Audio continue **app en arrière-plan / écran verrouillé** ; reprise propre après interruption (appel, autre app) sans crash ni double-lecture.

### (c) Prononciation + zéro jargon non expliqué (review P0.1)
8. **AC8** — **Les phrases vocales utilisent le langage de tous les jours** : on annonce le **nom de bloc lisible** + format (« Prochain : 4 fois 800 mètres »), **pas** un terme technique non glossarié à l'oral. Un terme jargon (« Daniels », « fartlek », « EN2 ») n'est **prononcé que s'il est déjà expliqué au glossaire** (chantier glossaire termes, cf `v2_chantiers_pedagogie_simu`) ; sinon on lit l'équivalent grand public. Une **table de prononciation de secours** corrige les mots techniques mal dits par le TTS quand ils sont effectivement prononcés. Extensible.

### (d) Tests
9. **AC9** — `SessionVoiceGuideTests.swift` (≥8) : séquence d'annonces (pré-annonce avant chaque bloc), toggle OFF = aucune voix, changement H/F sélectionne la bonne voix, mapping langue→voix, prononciation override appliqué. (Audio session mockée.)
10. **AC10** — i18n FR/EN des phrases vocales **et** des libellés UI. Test localisation EN. (ES = chantier localisation.)
11. **AC11** — Test device manuel (Sophie) : courir avec musique perso + voix par-dessus, écran verrouillé. *(Le device-test est la vraie validation — simu ne reproduit pas l'audio session/poche.)*

## Hypothèses / Risques
- **R1 — Background audio** : nécessite la capability *Audio, AirPlay, PiP* + `AVAudioSession.playback`. **Mitigation** : config soignée ; tester interruptions tôt.
- **R2 — Distance vs temps** : V1 = **temps** (pas de séquencement à la distance GPS, plus complexe). Distance = amélioration ultérieure. **Log** la limite.
- **R3 — Qualité voix variable** : compacte = robotique. **Mitigation** : invite download premium ; ne pas promettre studio.

## Out of scope
- Contrôles lock-screen / Now Playing riches (post-V1).
- Séquencement à la distance GPS.
- Montre swim (3.36). Localisation ES (chantier).

## Fichiers touchés (preview)
**Nouveaux :**
- `Coaching/Session/SessionVoiceGuide.swift` — TTS + ducking + sélection voix.
- `Coaching/Session/VoicePronunciationOverrides.swift` — table de secours.
- `Views/Components/Session/VoiceSettingsControls.swift` — toggle + sélecteur H/F + invite download.
- Tests `SessionVoiceGuideTests.swift`.

**Modifiés :**
- `Coaching/Session/SessionAudioCues.swift` (créé en 3.34, interface ducking déjà prévue) — brancher la voix sur la session audio partagée.
- `Coaching/Session/SessionFocusViewModel.swift` — brancher voix selon réglage + mode audio.
- `Views/Screens/Coaching/SessionFocusView.swift` — écran glançable + contrôles voix.
- Capabilities projet (Background Modes : Audio).
- `Resources/Localizable.xcstrings` (FR/EN).

## Jalons
- **J1 (~1.5j)** — `SessionVoiceGuide` + ducking + sélecteur H/F + tests.
- **J2 (~1.5j)** — Background audio + écran verrouillé + interruptions + écran glançable.
- **J3 (~1j)** — Pré-annonce vocale anti-Decathlon + prononciation de secours.
- **J4 (~1j)** — i18n FR/EN + ui-reviewer + **hand-off device-test Sophie**.

Total : **~4-6j**. Garde-fou EU MDR : la voix ne donne pas d'instruction médicale ; effort indicatif.
