import pathlib
from review_widget import CSS as REV_CSS, JS as REV_JS

# Galerie de re-jugement des 75 schémas Canvas harmonisés (07-16) — 1 passe
# OK/KO, image fixe (pas de vidéo à attendre). Regroupés yoga / muscu pour
# faciliter le survol.

SRC = pathlib.Path("vague7")

YOGA_TITLES = {
    "warrior2": "Guerrier II", "cobra": "Cobra", "child": "Enfant", "boat": "Bateau",
    "savasana": "Savasana", "dirgha": "Dirgha (respiration)", "catCowForearms": "Chat-vache (avant-bras)",
    "sarvangasana": "Chandelle", "setuBandha": "Pont (Setu Bandha)", "ujjayi": "Ujjayi (souffle océan)",
    "suptaBaddhaKonasana": "Papillon allongé", "januSirsasana": "Tête au genou",
    "marichyasanaA": "Marichyasana A", "matsyasana": "Poisson", "viparitaKarani": "Jambes au mur",
    "halasana": "Charrue", "kurmasana": "Tortue", "anjaneyasana": "Fente basse (Anjaneyasana)",
    "urdhvaDhanurasana": "Roue", "dolphinPose": "Dauphin", "garudasana": "Aigle",
    "warrior3": "Guerrier III", "nadiShodhana": "Respiration alternée", "sirsasana": "Poirier",
    "salabhasana": "Sauterelle", "ustrasana": "Chameau", "dhanurasana": "Arc",
    "phalakasana": "Planche (yoga)", "upavisthaKonasana": "Angle assis grand écart",
    "bakasana": "Corbeau", "purvottanasana": "Planche inversée", "uttanaPadasana": "Uttana Padasana",
    "prasaritaPadottanasana": "Flexion jambes écartées", "kapotasana": "Pigeon royal",
    "bhujapidasana": "Pression épaule", "garbhaPindasana": "Embryon (Garbha Pindasana)",
    "karnapidasana": "Genoux aux oreilles", "utthitaHastaPadangusthasana": "Main au gros orteil debout",
    "ardhaBaddhaPadmottanasana": "Demi-lotus debout",
}
MUSCU_TITLES = {
    "side-plank": "Planche latérale", "mobility-quad": "Étirement quadriceps",
    "bird-dog": "Bird-dog", "hinge-rdl-barbell": "RDL barre", "pull-vertical": "Tirage vertical",
    "push-horizontal-dumbbell": "Développé couché haltères", "push-horizontal-dips": "Dips",
    "pull-horizontal-row": "Rowing", "lunge-bodyweight": "Fente (poids du corps)",
    "plyo-burpee": "Burpee", "plyo-jumpsquat": "Jump squat", "hip-thrust": "Hip thrust",
    "calf-raise": "Mollets", "ytw-activation": "Activation Y-T-W", "pallof-press": "Pallof press",
    "nordic-curl": "Nordic curl", "dead-bug": "Dead-bug", "clamshell": "Clamshell",
    "face-pull": "Face pull", "biceps-curl-barbell": "Curl biceps barre",
    "triceps-pushdown": "Triceps pushdown", "hanging-leg-raise": "Relevé de jambes suspendu",
    "woodchopper": "Woodchopper", "pullover": "Pullover", "cable-fly": "Écarté poulie",
    "leg-curl": "Leg curl", "leg-press": "Leg press", "reverse-hyper": "Reverse hyper",
    "mountain-climber": "Mountain climbers", "jumping-jack": "Jumping jack",
    "tibialis-raise": "Tibialis raise", "turkish-getup": "Turkish get-up",
    "power-clean": "Power clean", "sled-push": "Sled push", "farmer-carry": "Farmer carry",
    "double-unders": "Double-unders",
}

def cards(titles, code):
    out = []
    for slug in sorted(titles):
        f = SRC / f"{slug}.png"
        if not f.exists():
            continue
        out.append(
            f'<div class="card" data-slug="{code}-{slug}"><img src="{f.as_posix()}" loading="lazy">'
            f'<div class="t">{titles[slug]}<span class="n" style="opacity:.5;font-weight:400"> · {slug}</span></div></div>'
        )
    return out

html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Schémas Canvas harmonisés — re-jugement</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} h2{font-size:16px;margin:26px 0 10px;color:#333;}
.sub{color:#666;font-size:13px;margin-bottom:16px;max-width:860px;}
.grid{display:flex;flex-wrap:wrap;gap:14px;}
.card{background:#fff;border-radius:10px;padding:8px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:200px;}
img{width:100%;border-radius:6px;background:#eee;display:block;}
.t{font-weight:600;font-size:12.5px;margin:6px 0 2px;}
""" + REV_CSS + """
</style></head><body>
<h1>Schémas Canvas harmonisés — re-jugement</h1>
<div class="sub"><b>75 schémas</b> (39 poses yoga + 36 patterns muscu/mobilité), tous en dessin de code
(déterministe — plus de génération IA), rendu avec la palette harmonisée du 07-16. Une passe OK/KO suffit,
ce sont des images fixes. « Exporter mes retours » en bas à droite quand tu as fini.</div>
<h2>Yoga (39)</h2><div class="grid">"""]
html.extend(cards(YOGA_TITLES, "yoga"))
html.append('</div><h2>Muscu / mobilité (36)</h2><div class="grid">')
html.extend(cards(MUSCU_TITLES, "muscu"))
html.append("</div>")
html.append(REV_JS)
html.append("</body></html>")

out = pathlib.Path("galerie-canvas-harmonises.html")
out.write_text("".join(html))
print(f"OK — {out} ({len(YOGA_TITLES)+len(MUSCU_TITLES)} cartes)")
