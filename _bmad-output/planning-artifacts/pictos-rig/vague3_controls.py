import json
import pathlib
import re
import subprocess

from PIL import Image

# VAGUE 3 — contrôles lineart extraits des SVG DÉJÀ VALIDÉS des lots HTML :
# on nettoie (ronds d'articulation retirés, tête pleine, annotations retirées,
# sol plein) au lieu de recoder les chaînes. Puis SDXL structure + restyle kontext.

SLUG2FIG = {
    "headstand": ("lot5.html", "Sirsasana"),
    "dolphin": ("lot4.html", "DolphinPose"),
    "warrior2": ("lot1.html", "Warrior2"),
    "tree": ("lot1.html", "Tree"),
    "staff-pose": ("lot2.html", "Dandasana"),
    "seated-forward-fold": ("lot2.html", "Paschimottanasana"),
    "wide-angle-seated-fold": ("lot2.html", "UpavisthaKonasana"),
    "warrior3": ("lot5.html", "Warrior3"),
    "half-moon": ("lot5.html", "ArdhaChandrasana"),
    "boat": ("lot6.html", "Boat"),
    "camel": ("lot8.html", "Ustrasana"),
    "wide-legged-forward-fold": ("lot8.html", "PrasaritaPadottanasana"),
    "forearm-tabletop": ("lot9.html", "CatCowForearms"),
    "side-plank": ("lot10.html", "CoreLateral"),
    "forearm-plank": ("lot10.html", "ForearmPlank"),
}

OUT = pathlib.Path("ai-explo/vague3")
OUT.mkdir(exist_ok=True)


def clean_svg(svg):
    # ronds d'articulation (r="1.5" fill="#fff")
    svg = re.sub(r'<circle[^>]*r="1\.5"[^>]*/>', "", svg)
    # sol pointillé + toute annotation en pointillé (motion arcs)
    svg = re.sub(r'<[^>]*stroke-dasharray[^>]*/>', "", svg)
    svg = re.sub(r'<path[^>]*stroke="#8a8a8a"[^>]*/>', "", svg)  # trajectoires
    svg = re.sub(r'<line[^>]*stroke="#e8a93d"[^>]*/>', "", svg)  # marques contact
    # tête pleine (cercles r="3.0" fill="none" -> remplis)
    svg = svg.replace('r="3.0" fill="none"', 'r="3.0" fill="#1a1a1a"')
    return svg


def extract_figures(html_path):
    html = pathlib.Path(html_path).read_text()
    figs = {}
    for m in re.finditer(r'<figure>(.*?)</figure>', html, re.S):
        block = m.group(1)
        t = re.search(r'<figcaption><b>([^<]+)</b>', block)
        s = re.search(r'(<svg.*?</svg>)', block, re.S)  # 1er svg = dessin principal (pas le zoom)
        if t and s:
            figs[t.group(1)] = s.group(1)
    return figs


results = {}
for slug, (html_file, fig_title) in SLUG2FIG.items():
    figs = extract_figures(html_file)
    if fig_title not in figs:
        print(f"MANQUE {slug}: {fig_title} pas dans {html_file} (titres: {list(figs)[:6]}…)")
        continue
    svg = clean_svg(figs[fig_title])
    # viewBox d'origine (80x48 en général) → fond blanc + sol plein sous le point bas
    vb = re.search(r'viewBox="([\d\.\s-]+)"', svg)
    x0, y0, w, h = map(float, vb.group(1).split())
    ys = [float(v) for v in re.findall(r'[ML](?:[\d\.-]+),([\d\.-]+)', svg)]
    ground_y = min(max(ys) + 1.5, y0 + h - 0.5) if ys else y0 + h - 2
    inner = re.sub(r'^<svg[^>]*>', "", svg).rsplit("</svg>", 1)[0]
    full = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x0} {y0} {w} {h}" '
            f'stroke-linecap="round" stroke-linejoin="round">'
            f'<rect x="{x0}" y="{y0}" width="{w}" height="{h}" fill="#ffffff"/>'
            f'<line x1="{x0 + 2}" y1="{ground_y:.1f}" x2="{x0 + w - 2}" y2="{ground_y:.1f}" '
            f'stroke="#555555" stroke-width="1.2"/>{inner}</svg>')
    svg_path = OUT / f"{slug}_control.svg"
    svg_path.write_text(full)
    png_tmp = OUT / f"{slug}_control_raw.png"
    subprocess.run(["rsvg-convert", "-w", "1024", str(svg_path), "-o", str(png_tmp)], check=True)
    # pad carré 1024 fond blanc (préserve l'aspect — pas d'étirement)
    im = Image.open(png_tmp).convert("RGB")
    side = max(im.size)
    sq = Image.new("RGB", (side, side), "white")
    sq.paste(im, ((side - im.width) // 2, (side - im.height) // 2))
    sq.resize((1024, 1024)).save(OUT / f"{slug}_control.png")
    png_tmp.unlink()
    results[slug] = True
    print(f"OK — {slug}")
print(f"{len(results)}/{len(SLUG2FIG)} contrôles")
