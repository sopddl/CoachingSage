import base64
import pathlib

# Planche d'échantillons — contrôle rig vs illustration IA, pour tranchage Sophie.
# Images embarquées en base64 (fichier autonome, ouvrable n'importe où).

D = pathlib.Path("ai-explo/planche")
REF = pathlib.Path("ai-explo/flat_triangle_v3.png")

ROWS = [
    ("Triangle (référence validée hier)", "femme · debout · frontal", REF, None,
     "OK", "La recette d'origine — rappel du style validé."),
    ("Guerrier 1", "femme · debout · fente", D / "warrior1_flat_s3007_c48.png", D / "warrior1_control.png",
     "PRESQUE", "Fente et pieds au sol fidèles. Les bras devraient être LEVÉS (le modèle les baisse 1 fois sur 2) — se règle en curation de seed au batch."),
    ("Cobra", "femme · au sol · ventral", D / "cobra_flat_s2025_c48.png", D / "cobra_control.png",
     "OK", "Ventre au sol lisible, tapis. Buste un peu bas (sphinx) vs squelette bras tendus."),
    ("Chien tête en bas", "femme · inversée", D / "downdog_flat_s2025_c55.png", D / "downdog_control.png",
     "À REVOIR", "5 essais, jamais lisible : la pose pliée en V troue la recette lineart (tête/corps abstraits). Piste batch : contrôle depth ou openpose en 2e ControlNet pour les poses inversées."),
    ("Squat gobelet", "homme · muscu · haltère", D / "goblet_squat_flat_s3007_c48.png", D / "goblet_squat_control.png",
     "OK", "Personnage homme posé, squat lisible. Haltère double au lieu du gobelet unique — affinable par prompt."),
    ("Soulevé de terre", "homme · muscu · barre", D / "deadlift_flat_s777_c48.png", D / "deadlift_control.png",
     "OK", "Hinge lisible, charge à hauteur genoux. La barre profilée est approximative (pas de disques ronds nets) — affinable."),
]

VERDICT_COLORS = {"OK": "#3f8f5c", "PRESQUE": "#e8a93d", "À REVOIR": "#c65a37"}


def b64(p):
    return "data:image/png;base64," + base64.b64encode(p.read_bytes()).decode()


html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Planche d'échantillons — illustrations IA</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} .sub{color:#666;font-size:13px;margin-bottom:24px;}
.row{display:flex;gap:18px;align-items:center;background:#fff;border-radius:12px;padding:16px;margin-bottom:14px;box-shadow:0 1px 3px rgba(0,0,0,.08);}
.row img{border-radius:8px;background:#fff;}
.gen{width:300px;height:300px;object-fit:cover;}
.ctrl{width:130px;height:130px;object-fit:contain;border:1px solid #eee;}
.meta{flex:1;min-width:220px;}
.meta h2{font-size:16px;margin:0 0 2px;} .tag{font-size:12px;color:#888;margin-bottom:8px;}
.verdict{display:inline-block;font-size:12px;font-weight:600;color:#fff;border-radius:99px;padding:2px 10px;margin-bottom:8px;}
.note{font-size:13px;line-height:1.45;color:#444;max-width:420px;}
.lbl{font-size:10px;color:#aaa;text-align:center;margin-top:4px;}
</style></head><body>
<h1>Planche d'échantillons — illustrations IA (flat design)</h1>
<div class="sub">Recette : rig lineart 0.48 + tête pleine + ligne de sol → SDXL multi-controlnet · ~0,015&nbsp;$/image · 5 poses variées + 2 personnages (femme yoga / homme muscu)</div>
"""]
for title, tag, gen_p, ctrl_p, verdict, note in ROWS:
    ctrl_html = (f'<div><img class="ctrl" src="{b64(ctrl_p)}"><div class="lbl">squelette (contrôle)</div></div>'
                 if ctrl_p else '<div style="width:130px"></div>')
    html.append(
        f'<div class="row"><img class="gen" src="{b64(gen_p)}">{ctrl_html}'
        f'<div class="meta"><h2>{title}</h2><div class="tag">{tag}</div>'
        f'<span class="verdict" style="background:{VERDICT_COLORS[verdict]}">{verdict}</span>'
        f'<div class="note">{note}</div></div></div>')
html.append("</body></html>")
out = pathlib.Path("planche-echantillons.html")
out.write_text("\n".join(html))
print(f"OK — {out} ({out.stat().st_size // 1024} KB)")
