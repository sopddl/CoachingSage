import json
import pathlib
import sys

from PIL import Image

# Feuilles de contact par lot pour la revue anti-bug (gate 1, Fable) :
# grille des B générées (titre = slug) + bande zoom du bas de chaque image
# (extrémités/appuis — les bugs pieds/mains ne se voient pas à taille vignette).
# Usage : python3 batch_sheets.py <lot_index 0..n> [taille_lot=12]

BATCH = pathlib.Path("ai-explo/batch")
manifest = json.loads((BATCH / "manifest.json").read_text())
gen = [m for m in manifest if (BATCH / f"B_{m['slug']}.png").exists()]
lot_size = int(sys.argv[2]) if len(sys.argv) > 2 else 12
lot_i = int(sys.argv[1])
lot = gen[lot_i * lot_size:(lot_i + 1) * lot_size]
if not lot:
    print("lot vide")
    sys.exit(1)

from PIL import ImageDraw

cols = 4
rows = (len(lot) + cols - 1) // cols
CELL, ZOOM_H = 300, 110
sheet = Image.new("RGB", (cols * (CELL + 10) + 10, rows * (CELL + ZOOM_H + 34) + 10), "white")
draw = ImageDraw.Draw(sheet)
for i, m in enumerate(lot):
    im = Image.open(BATCH / f"B_{m['slug']}.png").convert("RGB")
    x = 10 + (i % cols) * (CELL + 10)
    y = 10 + (i // cols) * (CELL + ZOOM_H + 34)
    sheet.paste(im.resize((CELL, CELL)), (x, y))
    w, h = im.size
    zoom = im.crop((0, int(h * 0.62), w, int(h * 0.95))).resize((CELL, ZOOM_H), Image.LANCZOS)
    sheet.paste(zoom, (x, y + CELL + 2))
    draw.text((x + 4, y + CELL + ZOOM_H + 6), f"{lot_i * lot_size + i}: {m['slug']}", fill="black")
out = BATCH / f"_lot{lot_i}_sheet.png"
sheet.save(out)
print(f"OK — {out} ({len(lot)} images, indices {lot_i * lot_size}-{lot_i * lot_size + len(lot) - 1})")
