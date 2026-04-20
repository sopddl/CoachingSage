# Adaptability : hiit-avance-10sem + p5-low-energy-week

## Rigidity score
**7/10**

Le template offre une structure suffisamment modulable (cutback weeks W5 et W8 existent déjà) pour absorber une semaine ad hoc de déload. Cependant, le plan est construit sur une **progression linéaire stricte alternant volumes/intensités paires-impaires**, ce qui crée une rigidité logique : déplacer une semaine de fatigue ailleurs dans le cycle casse cet équilibre savant.

## Patch approach

Insérer un **cutback adaptatif** à la semaine actuelle (supposons W3-W6, période "normale") en réduisant les charges de 20-25%, les volumes EMOM/AMRAP de 5-10 min, et le RPE work à 6-7. Contrairement aux cutbacks programmés W5/W8 (déload stratégique), celui-ci est **réactif** : il protège les adaptations neuromusculaires sans compromettre les acquis, puis la semaine suivante reprend la progression W+1 originale avec charges à -5% (compromise). Aucun "rattrapage" n'est nécessaire si la fatigue disparaît en 48-72h post-semaine.

## Concrete modifications

- **J1 (EMOM)** : réduire de **EMOM 30 min → EMOM 20 min** (2 stations alternées au lieu de 3). Charges -20% (ex : KB swings 16-20 kg au lieu de 20-24 kg, push-press 40-45% 1RM au lieu de 50-60%). RPE 6-7.
- **J2 (For Time)** : passer de **chipper 5 exercices → circuit 3 exercices × 3 rounds**. Format : 10 KB swings + 8 pull-ups + 200 m run × 3 (durée ~15 min vs ~18-20 min W3-W6). RPE 6-7.
- **J3 (AMRAP)** : réduire de **AMRAP 20 min → AMRAP 15 min** avec format simplifié (5 thrusters légers 30 kg + 8 box step-ups + 12 sit-ups). RPE 6-7.
- **J5 (40/20)** : remplacer par **Tabata 20/10 × 3 blocs uniquement** (12 min vs 55 min W3-W6). Charges à 50% 1RM, RPE 6-7.
- **J6 (mobilité/force gymnique)** : conserver **inchangé** (mobilité active, skills techniques à faible intensité). Ajouter 5 min de respiration/relaxation supplémentaires.

## Rigidity issues

- **Progression alternée paires/impaires** (énoncée dans `progression_logic`) : cette semaine low-energy s'insère mal dans la logique "volumes semaines impaires, intensités semaines paires". Si actuellement en W3 (pic volume), le cutback adaptatif désynchronise W4 (censée être intensité pic). **Mitigation** : reporter W4 intensité maximale à J1 de la semaine suivante seulement ; W4 entière passe à RPE 7-8 (au lieu de 8-9).
- **Cutback W5 et W8 programmées** : deux cutbacks existent déjà. Insérer un 3e cutback non planifié casse la surcompensation programmée. **Risque** : si cutback W3 ET cutback W5 se succèdent (2 semaines légères consécutives), la courbe de progression plate et les adaptations s'enrayent.
- **Safety notes sur surcharge neuromusculaire** : le template cite "3+ signes simultanés → cutback immédiat" (fc repos +8-10 bpm, perf -15%, sommeil dégradé, irritabilité). Cette contrainte (grosse semaine travail/sommeil dégradé) **valide** un cutback ; le template prévoit donc cette situation et la documente. **Pas de contradiction majeure**, mais l'insertion ad hoc n'est pas explicitée dans le plan écrit.

## Contradictions

- **Aucune contradiction directe** entre la réduction RPE 6-7 et les safety_notes (qui mentionnent RPE 8-9 seulement sur les work intervals, RPE 2-3 sur rest). Un RPE 6-7 soutenu est sûr.
- **Volume allégé vs progression_logic** : le plan énonce "ne jamais augmenter les deux [volume + intensité] simultanément". La semaine low-energy réduit volume ET intensité, ce qui est **inverse** de la règle ACSM, donc cohérent avec le principe de précaution.
- **Pas de contradiction sur les movementspatterns** : Nordic curls W3 J3 restent inchangés (prévention non négociable). External rotation bande maintenues fin de session (prévention épaule sur overhead même à RPE réduit).

---

## Notes d'implémentation

**Timing critique** : si la semaine fatigue survient en W4 (pic intensité planifié), le patch force un décalage : W4 devient W3-like (RPE 7-8, volume modéré), W5 reprend à RPE 8-9 avec charges -5% vs W4 original pour re-synchroniser. La progression globale perd ~2-3% de volume sur 10 semaines, impact négligeable si la cause (sommeil/stress) disparaît après W4.

**Post-cutback adaptatif** : semaine suivante, reprendre à **charges -5% de la semaine nominale suivante**, pas à -0%. Exemple : après W3 low-energy, W4 réelle utilise charges 95% de W4 nominal (au lieu de 100%), RPE 8-8.5 (au lieu de 8-9). Cela permet une progression douce sans overreach.

**Signe de régression chronique** : si low-energy se produit > 2 fois en 10 semaines ou si la fatigue persiste > 1 semaine après le cutback, **arrêter le plan** et consulter (overtraining syndrome possible = hors scope du template).