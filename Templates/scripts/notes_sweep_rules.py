#!/usr/bin/env python3
"""Chantier i18n « notes longues » (2026-06-21) — règles fr-only par sport issues du
sweep agent (1 agent/sport), NETTOYÉES : les noms de paliers (beginner/regular/
competitive/recreational) sont EXCLUS (systématiques dans les noms de templates de
TOUS les sports → passe cohérente cross-sport séparée). Écrit 10 fichiers de règles
puis l'appel applier se fait depuis le shell."""
import json, os

RULES = {
    "yoga": [
        {"old": "Pose #", "new": "Posture #"},
        {"old": "Balance (", "new": "Équilibre ("},
        {"old": "Blanket sous", "new": "Couverture sous"},
    ],
    "running": [
        {"old": "l'effort running", "new": "l'effort de course"},
        {"old": "Format au seuil (cruise) plus long", "new": "Format au seuil plus long"},
        {"old": "Descente de marche (step-down)", "new": "Descente de marche"},
        {"old": "semaine allégée week", "new": "semaine allégée"},
        {"old": "lactate threshold 1", "new": "seuil lactique 1"},
        {"old": "Marche-jogging", "new": "Marche-course"},
        {"old": "tu reviens au jogging", "new": "tu reviens à la course"},
        {"old": "strength", "new": "renforcement"},
    ],
    "cycling": [
        {"old": "pour flush lactate", "new": "pour évacuer le lactate"},
        {"old": "concentrate-toi", "new": "concentre-toi"},
    ],
    "swimming": [
        {"old": "Total Immersion Breath Stage", "new": "Total Immersion étape respiration"},
        {"old": "Total Immersion Catch Stage", "new": "Total Immersion étape prise d'appui"},
        {"old": "Total Immersion Balance Stage 1", "new": "Total Immersion étape équilibre 1"},
        {"old": "rythme respiratoire (breath control)", "new": "rythme respiratoire"},
        {"old": "Enfiler l'aiguille (thread the needle)", "new": "Enfiler l'aiguille"},
        {"old": "course week", "new": "semaine de course"},
        {"old": "en recovery", "new": "au retour de bras"},
        {"old": "(recovery, pas un test", "new": "(récupération, pas un test"},
        {"old": "épaules cross-body", "new": "épaules croisées"},
        {"old": "Glissé au mur push", "new": "Glissé au mur poussée"},
        {"old": "taille small / medium)", "new": "taille petite / moyenne)"},
    ],
    "hiking": [
        {"old": "vallonné-moderate-steep", "new": "vallonné à raide"},
        {"old": "vallonné à moderate", "new": "vallonné à modéré"},
        {"old": "vallonné-moderate", "new": "vallonné à modéré"},
        {"old": "altitude-low ou altitude-moderate", "new": "altitude basse ou modérée"},
        {"old": "altitude-low/moderate", "new": "altitude basse/modérée"},
        {"old": "(pente-moderate)", "new": "(pente modérée)"},
        {"old": "pente-moderate", "new": "pente modérée"},
        {"old": "pente-flat", "new": "pente plate"},
        {"old": "(pente-steep)", "new": "(pente raide)"},
        {"old": "pente-steep", "new": "pente raide"},
        {"old": "(altitude-moderate)", "new": "(altitude modérée)"},
        {"old": "altitude-moderate", "new": "altitude modérée"},
        {"old": "(altitude-low)", "new": "(altitude basse)"},
        {"old": "altitude-low", "new": "altitude basse"},
        {"old": "(pack-light)", "new": "(sac léger)"},
        {"old": "(knee-flare)", "new": "(genou rentrant)"},
        {"old": "Aerobic Threshold", "new": "seuil aérobie"},
        {"old": "effort proche threshold", "new": "effort proche du seuil"},
        {"old": "Muscular Endurance", "new": "endurance musculaire"},
        {"old": "active recovery", "new": "récupération active"},
        {"old": "Snacks", "new": "En-cas"},
        {"old": "snacks", "new": "en-cas"},
        {"old": "snack", "new": "en-cas"},
        {"old": "Mountain treks", "new": "treks en montagne"},
        {"old": "A-event", "new": "épreuve A"},
        {"old": "A-EVENT", "new": "ÉPREUVE A"},
        {"old": "altitude-intolerance", "new": "intolérance à l'altitude"},
        {"old": "pente-vallonné", "new": "pente vallonnée"},
        {"old": "Bi-day", "new": "Bi-journée"},
        {"old": "sortie hiking", "new": "sortie de randonnée"},
    ],
    "hiit": [
        {"old": "base aérobie polarized", "new": "base aérobie polarisée"},
        {"old": "distribution polarized", "new": "distribution polarisée"},
        {"old": "Soutien polarized", "new": "Soutien polarisé"},
        {"old": " (depth drop)", "new": ""},
        {"old": "depth drops", "new": "sauts en contrebas"},
        {"old": "back foot", "new": "pied arrière"},
        {"old": "shoulder tap", "new": "touches d'épaule"},
    ],
    "strength_training": [
        {"old": "Nordic hamstring curl", "new": "Nordic curl ischio-jambiers"},
        {"old": "Glute ham élévation", "new": "Élévation ischio-fessiers"},
        {"old": "Back extension", "new": "Extension lombaire"},
        {"old": "Étirement open book", "new": "Étirement ouverture de livre"},
        {"old": "Walking fente", "new": "Fente marchée"},
        {"old": "Ab wheel", "new": "Roue abdominale"},
        {"old": "ab wheel", "new": "roue abdominale"},
        {"old": "Cross-body haltères curl", "new": "Curl haltères croisé"},
        {"old": "deltoïde postérieur (cross-body)", "new": "deltoïde postérieur"},
        {"old": "Low-to-high écarté à la poulie", "new": "Écarté poulie de bas en haut"},
        {"old": " (low-to-high)", "new": ""},
        {"old": "Bûcheron à la poulie (woodchopper)", "new": "Bûcheron à la poulie"},
        {"old": "woodchopper avec élastique", "new": "Bûcheron avec élastique"},
        {"old": " (world's greatest stretch)", "new": ""},
        {"old": " (butt wink)", "new": ""},
        {"old": "squat cosaque (Cossack squat)", "new": "squat cosaque"},
        {"old": "As Many Répétitions As Possible", "new": "autant de répétitions que possible"},
        {"old": "swap ", "new": "remplace par "},
        {"old": "Soft tissue work", "new": "Massage des tissus mous"},
        {"old": "chest écarté avec élastique", "new": "Écarté poitrine avec élastique"},
        {"old": "buste droit (chest up)", "new": "buste droit"},
        {"old": " (lockout)", "new": ""},
        {"old": "triceps à la poulie (triceps pushdown)", "new": "triceps à la poulie"},
        {"old": "poulie, corde (triceps pushdown)", "new": "poulie, corde"},
    ],
    "tennis": [
        {"old": " (in-out : 2 pieds dedans, 2 pieds dehors)", "new": ""},
        {"old": " (in-out)", "new": ""},
        {"old": " (cross-over)", "new": ""},
        {"old": " (back-pedal)", "new": ""},
        {"old": " (skater)", "new": ""},
        {"old": " + back-pedal", "new": " + course arrière"},
        {"old": "A-event", "new": "épreuve A"},
        {"old": " (woodchopper)", "new": ""},
    ],
    "football": [
        {"old": " (« the bench » du FIFA 11+)", "new": ""},
    ],
    "triathlon": [
        {"old": "pour finisher ton premier sprint", "new": "pour finir ton premier sprint"},
        {"old": "La finishability prime", "new": "Le fait de finir prime"},
        {"old": " (« dismount line », règle de sécurité)", "new": " (règle de sécurité)"},
        {"old": "splits égaux", "new": "temps de passage égaux"},
    ],
}

if __name__ == "__main__":
    outdir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "notes_sweep")
    os.makedirs(outdir, exist_ok=True)
    for sport, rules in RULES.items():
        with open(os.path.join(outdir, f"{sport}.json"), "w") as f:
            json.dump(rules, f, ensure_ascii=False, indent=2)
        print(f"{sport}: {len(rules)} règles")
