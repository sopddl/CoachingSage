import base64
import json
import pathlib

# Galerie finale OK/KO du batch pour Sophie (gate rendu uniquement).
# Lit manifest.json + batch_verdicts.json {slug: {"verdict": OK|PRESQUE|KO|A_REVOIR, "notes": [..]}}.
# Paires A (départ du type) → B (position clé), groupées par start_type.

BATCH = pathlib.Path("ai-explo/batch")
manifest = json.loads((BATCH / "manifest.json").read_text())
verdicts = json.loads((BATCH / "batch_verdicts.json").read_text()) if (BATCH / "batch_verdicts.json").exists() else {}
A_IMAGES = {"debout": "A_debout.png", "assis_sol": "A_assis_sol.png", "quadrupede": "A_quadrupede.png"}
COLORS = {"OK": "#3f8f5c", "PRESQUE": "#e8a93d", "KO": "#c65a37", "A_REVOIR": "#8a8a8a"}
TYPE_LABEL = {"debout": "Départ debout", "assis_sol": "Départ assis au sol",
              "quadrupede": "Départ à 4 pattes", "allonge_dos": "Départ allongé dos (à revoir)",
              "VENTRAL_EXCLU": "Poses ventrales (hors pipeline)"}


def b64(p):
    # vignette JPEG 512 en mémoire — la version PNG 1024 brute donnait un HTML de 71 MB
    import io
    from PIL import Image
    im = Image.open(p).convert("RGB").resize((512, 512))
    buf = io.BytesIO()
    im.save(buf, "JPEG", quality=82)
    return "data:image/jpeg;base64," + base64.b64encode(buf.getvalue()).decode()


html = ["""<!doctype html><html><head><meta charset="utf-8"><title>Batch illustrations — galerie OK/KO</title><style>
body{margin:0;padding:28px;background:#fafafa;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:22px;margin:0 0 4px;} h2{font-size:16px;margin:28px 0 10px;color:#555;}
.sub{color:#666;font-size:13px;margin-bottom:8px;max-width:860px;line-height:1.5;}
.grid{display:flex;flex-wrap:wrap;gap:14px;}
.card{background:#fff;border-radius:10px;padding:10px;box-shadow:0 1px 3px rgba(0,0,0,.08);width:330px;}
.card .imgs{display:flex;gap:4px;} .card img{width:160px;height:160px;object-fit:cover;border-radius:6px;}
.card .t{font-weight:600;font-size:13px;margin:8px 0 2px;display:flex;gap:8px;align-items:center;}
.v{font-size:11px;font-weight:600;color:#fff;border-radius:99px;padding:1px 8px;}
.n{font-size:11.5px;color:#555;line-height:1.4;}
.mod{font-size:11px;font-weight:700;color:#fff;background:#4a6fd4;border-radius:99px;padding:1px 8px;}
.card.is-mod{outline:3px solid #4a6fd4;outline-offset:-1px;}
.startimg{width:160px;height:160px;border-radius:6px;margin-right:8px;}
</style></head><body>
<h1>Batch illustrations — galerie OK/KO</h1>
<div class="sub">Paires départ → position clé. Gates passés : revue anti-bug (Fable) + expert doctrine + UX novice. Juge le RENDU.</div>
"""]
for st in ["debout", "assis_sol", "quadrupede", "allonge_dos", "VENTRAL_EXCLU"]:
    items = [m for m in manifest if m["start_type"] == st]
    if not items:
        continue
    html.append(f"<h2>{TYPE_LABEL[st]} · {len(items)} exos</h2><div class='grid'>")
    a_img = BATCH / A_IMAGES.get(st, "")
    for m in items:
        b_path = BATCH / f"B_{m['slug']}.png"
        v = verdicts.get(m["slug"], {})
        verdict = v.get("verdict", "A_REVOIR" if not b_path.exists() else "?")
        notes = " · ".join(v.get("notes", []))
        imgs = ""
        if st in A_IMAGES and b_path.exists():
            imgs = f'<div class="imgs"><img src="{b64(a_img)}"><img src="{b64(b_path)}"></div>'
        # Badge « MODIFIÉ » : image plus récente que last_round.txt (bumpé après chaque round Sophie)
        lr = pathlib.Path("last_round.txt")
        lr_ts = float(lr.read_text().strip()) if lr.exists() else 0.0
        is_mod = b_path.exists() and b_path.stat().st_mtime > lr_ts
        mod_badge = '<span class="mod">MODIFIÉ</span>' if is_mod else ""
        html.append(
            f'<div class="card{" is-mod" if is_mod else ""}">{imgs}<div class="t">{m["title_fr"]}'
            f'<span class="v" style="background:{COLORS.get(verdict, "#999")}">{verdict}</span>{mod_badge}</div>'
            f'<div class="n">{notes}</div></div>')
    html.append("</div>")
html.append("</body></html>")
out = pathlib.Path("galerie-batch.html")
out.write_text("\n".join(html))
print(f"OK — {out} ({out.stat().st_size // 1024} KB)")
