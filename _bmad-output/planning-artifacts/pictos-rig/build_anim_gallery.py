import json
import pathlib

from review_widget import CSS as REV_CSS, JS as REV_JS

# Galerie vidéos des animations vitrines — vidéos référencées en RELATIF
# (pas de base64 : 10 mp4 ≈ trop lourd inline). À ouvrir depuis pictos-rig/.

ANIM = pathlib.Path("ai-explo/anim")
verdicts = {}
vp = ANIM / "anim_verdicts.json"
if vp.exists():
    verdicts = json.loads(vp.read_text())

TITRES = {
    "goblet-squat": "Squat gobelet", "lunge-dumbbell": "Fente haltères",
    "biceps-curl": "Curl biceps", "ohp-barbell": "Développé militaire",
    "pushup-incline-chair": "Pompes inclinées (chaise)", "warrior1": "Guerrier 1",
    "tree": "Arbre", "chair": "Chaise", "cat-cow": "Chat-vache", "staff-pose": "Bâton",
}
COLORS = {"OK": "#3f8f5c", "PRESQUE": "#e8a93d", "KO": "#c65a37", "?": "#999"}

# Badge « MODIFIÉ » : tout mp4 plus récent que le dernier round de jugement Sophie.
# Bumper la date dans last_round.txt (epoch) quand un round est terminé.
LAST_ROUND = pathlib.Path("last_round.txt")
last_round_ts = float(LAST_ROUND.read_text().strip()) if LAST_ROUND.exists() else 0.0

html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Animations vitrines</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} .sub{color:#666;font-size:13px;margin-bottom:16px;max-width:860px;}
.grid{display:flex;flex-wrap:wrap;gap:16px;}
.card{background:#fff;border-radius:10px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:340px;}
video{width:320px;border-radius:6px;background:#eee;}
.t{font-weight:600;font-size:13px;margin:8px 0 2px;display:flex;gap:8px;align-items:center;}
.v{font-size:11px;font-weight:600;color:#fff;border-radius:99px;padding:1px 8px;}
.n{font-size:11.5px;color:#555;line-height:1.4;}
.mod{font-size:11px;font-weight:700;color:#fff;background:#4a6fd4;border-radius:99px;padding:1px 8px;}
.card.is-mod{outline:3px solid #4a6fd4;outline-offset:-1px;}
""" + REV_CSS + """
</style></head><body>
<h1>Animations vitrines — Kling v1.6</h1>
<div class="sub">10 exos (5 muscu homme + 5 yoga femme), démarrage sur l'image validée du catalogue.
Boucle : survole/clique pour lire. Si le lot te va, on élargit aux autres exos validés.</div>
<div class="grid">"""]
import re
# RÈGLE D'AFFICHAGE (incident r12, 2026-07-16 : Sophie a re-jugé 3 clips cassés
# jamais bodycheckés parce que « affiché » ne voulait pas dire « vérifié ») :
#   - section « À JUGER » = UNIQUEMENT les clips avec ready_for_sophie=True dans
#     les verdicts (posé à la main quand le pipeline complet est PASS :
#     bodycheck zones×frames + expert sourcé web + UX).
#   - section « Validés » = verdict OK (déjà jugés par Sophie).
#   - TOUT LE RESTE (?, CANDIDAT sans flag, A_REVOIR) n'apparaît PAS — juste un
#     compteur « en travaux ». Sophie n'a jamais à deviner quoi vérifier.
to_judge, validated, hidden = [], [], []
for mp4 in sorted(ANIM.glob("anim_*.mp4")):
    slug = mp4.stem.replace("anim_", "")
    v = verdicts.get(slug, {})
    if not isinstance(v, dict):
        v = {}
    verdict = v.get("verdict", "?")
    if verdict == "KO":
        continue
    note = v.get("note", "")
    base = re.sub(r"_v\d+$", "", slug)
    if v.get("ready_for_sophie"):
        card = (f'<div class="card is-mod" data-slug="{slug}"><video src="{mp4.as_posix()}" autoplay loop muted playsinline onclick="this.paused?this.play():this.pause()"></video>'
                f'<div class="t">{TITRES.get(base, base)}<span class="mod">À JUGER — pipeline ✓</span></div>'
                f'<div class="n">{note}</div></div>')
        to_judge.append(card)
    elif verdict == "OK":
        card = (f'<div class="card" data-slug="{slug}"><video src="{mp4.as_posix()}" autoplay loop muted playsinline onclick="this.paused?this.play():this.pause()"></video>'
                f'<div class="t">{TITRES.get(base, base)}<span class="v" style="background:#3f8f5c">OK</span></div>'
                f'<div class="n">{note}</div></div>')
        validated.append(card)
    else:
        hidden.append(slug)

# Page principale = UNIQUEMENT ce que Sophie doit juger (retour r13 : « je ne
# sais jamais quoi regarder quand il y a 500 images sur la page »). Les validés
# vivent sur une page séparée, en lien.
html[-1] = html[-1].replace('<div class="grid">',
    f'<div class="sub"><b>{len(to_judge)} clip(s) à juger — c\'est tout ce qu\'il y a sur cette page.</b> '
    f'Chacun a passé le pipeline complet (anatomie zones×frames + expert sourcé web + UX), tu ne juges que le rendu. '
    f'{len(hidden)} en travaux (non montrés) · '
    f'<a href="galerie-validees.html">{len(validated)} déjà validés →</a></div><div class="grid">')
html.extend(to_judge if to_judge else ['<div class="n" style="font-size:15px;padding:30px">Rien à juger pour l\'instant — reviens quand je te préviens. 🎉</div>'])
html.append("</div>")

vhtml = ['<!doctype html><html><head><meta charset="utf-8"><title>Animations validées</title><style>',
         'body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}',
         'h1{font-size:22px;margin:0 0 4px;} .sub{color:#666;font-size:13px;margin-bottom:16px;}',
         '.grid{display:flex;flex-wrap:wrap;gap:16px;}',
         '.card{background:#fff;border-radius:10px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:340px;}',
         'video{width:320px;border-radius:6px;background:#eee;}',
         '.t{font-weight:600;font-size:13px;margin:8px 0 2px;display:flex;gap:8px;align-items:center;}',
         '.v{font-size:11px;font-weight:600;color:#fff;border-radius:99px;padding:1px 8px;}',
         '.n{font-size:11.5px;color:#555;line-height:1.4;}',
         '</style></head><body><h1>Déjà validés</h1>',
         f'<div class="sub">{len(validated)} clips validés par Sophie — page de référence, rien à faire ici. <a href="galerie-animations.html">← retour au jugement</a></div><div class="grid">']
vhtml.extend(validated)
vhtml.append('</div></body></html>')
pathlib.Path("galerie-validees.html").write_text("".join(vhtml))
html.append(REV_JS)
html.append("</body></html>")
out = pathlib.Path("galerie-animations.html")
out.write_text("".join(html))
print(f"OK — {out}")
