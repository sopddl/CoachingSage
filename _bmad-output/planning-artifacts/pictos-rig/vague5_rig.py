import pathlib
import re
import subprocess
import sys
import time

from PIL import Image

from pilot_flux import replicate_run, b64, FEMALE

# VAGUE 5 — completion du catalogue yoga (decision Sophie 07-16 « coherence »).
# La voie texte-seul a fait 0/24 (poses fausses, lipstick, persos casses) ->
# retour a la chaine qui a produit le catalogue valide : rig SVG des lots
# lot1-10.html (les ~60 poses dessinees a l'epoque) -> controle lineart carre
# -> flux-canny-pro + prompt FEMALE valide (pilot_flux).

OUT = pathlib.Path("vague5")
OUT.mkdir(exist_ok=True)

# figure des lots -> (slug, description pose pour le prompt)
POSES = {
    "Warrior2": ("warrior2", "warrior two pose, wide lunge stance, front knee bent, back leg straight, "
                 "both arms extended horizontally in opposite directions at shoulder height"),
    "Cobra": ("cobra", "cobra pose, lying on her belly, pelvis and legs flat on the floor, chest and "
              "head lifted, back gently arched, arms straight with hands flat under the shoulders"),
    "Child": ("child", "child's pose, kneeling folded forward, buttocks on her heels, forehead resting "
              "on the mat, arms extended forward on the mat"),
    "Savasana": ("savasana", "corpse pose, lying flat on her back, completely relaxed, legs extended, "
                 "arms alongside the body palms up"),
    "Boat": ("boat", "boat pose, balancing on her sit bones, straight legs raised forming a V with the "
             "torso, arms extended forward parallel to the floor"),
    "SetuBandha": ("setu-bandha", "bridge pose, lying on her back, knees bent feet flat on the mat, "
                   "hips lifted high, chest open, arms on the mat alongside the body"),
    "Anjaneyasana": ("anjaneyasana", "low lunge, back knee and shin resting on the mat, front knee bent "
                     "with the foot flat, torso upright, both arms raised straight overhead"),
    "DolphinPose": ("dolphin", "dolphin pose, forearms flat on the mat, elbows under the shoulders, "
                    "hips raised high forming an inverted V, legs straight, head between the arms"),
    "Salabhasana": ("salabhasana", "locust pose, lying on her belly, chest and head lifted, both "
                    "straight legs lifted off the mat behind her, arms extended back alongside the body"),
    "PrasaritaPadottanasana": ("prasarita", "wide-legged standing forward fold, feet wide apart, legs "
                               "straight, torso folded forward and down, hands on the mat"),
    "ViparitaKarani": ("viparita-karani", "legs-up pose, lying on her back, both legs raised straight "
                       "up vertically, arms relaxed alongside the body"),
    "Ustrasana": ("ustrasana", "camel pose, kneeling upright, thighs vertical, back arched backward, "
                  "chest open, hands reaching back to the heels"),
}


def clean_svg(svg):
    svg = re.sub(r'<circle[^>]*r="1\.5"[^>]*/>', "", svg)
    svg = re.sub(r'<[^>]*stroke-dasharray[^>]*/>', "", svg)
    svg = re.sub(r'<path[^>]*stroke="#8a8a8a"[^>]*/>', "", svg)
    svg = re.sub(r'<line[^>]*stroke="#e8a93d"[^>]*/>', "", svg)
    svg = svg.replace('r="3.0" fill="none"', 'r="3.0" fill="#1a1a1a"')
    return svg


def find_figure(fig_name):
    for html_file in sorted(pathlib.Path(".").glob("lot*.html")):
        html = html_file.read_text()
        for m in re.finditer(r'<figure>(.*?)</figure>', html, re.S):
            t = re.search(r'<figcaption><b>([^<]+)</b>', m.group(1))
            s = re.search(r'(<svg.*?</svg>)', m.group(1), re.S)
            if t and s and t.group(1) == fig_name:
                return clean_svg(s.group(1)), html_file.name
    return None, None


def make_control(fig_name, slug):
    dest = OUT / f"{slug}_control.png"
    if dest.exists():
        return dest
    svg, src = find_figure(fig_name)
    assert svg, f"figure {fig_name} introuvable dans les lots"
    vb = re.search(r'viewBox="([\d\.\s-]+)"', svg)
    x0, y0, w, h = map(float, vb.group(1).split())
    ys = [float(v) for v in re.findall(r'[ML](?:[\d\.-]+),([\d\.-]+)', svg)]
    gy = min(max(ys) + 1.5, y0 + h - 0.5) if ys else y0 + h - 2
    inner = re.sub(r'^<svg[^>]*>', "", svg).rsplit("</svg>", 1)[0]
    full = (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{x0} {y0} {w} {h}" '
            f'stroke-linecap="round" stroke-linejoin="round">'
            f'<rect x="{x0}" y="{y0}" width="{w}" height="{h}" fill="#ffffff"/>'
            f'<line x1="{x0 + 2}" y1="{gy:.1f}" x2="{x0 + w - 2}" y2="{gy:.1f}" '
            f'stroke="#555555" stroke-width="1.2"/>{inner}</svg>')
    sp = OUT / f"{slug}_control.svg"
    sp.write_text(full)
    tmp = OUT / f"{slug}_raw.png"
    subprocess.run(["rsvg-convert", "-w", "1024", str(sp), "-o", str(tmp)], check=True)
    im = Image.open(tmp).convert("RGB")
    side = max(im.size)
    sq = Image.new("RGB", (side, side), "white")
    sq.paste(im, ((side - im.width) // 2, (side - im.height) // 2))
    sq.resize((1024, 1024)).save(dest)
    tmp.unlink()
    print(f"controle {slug} <- {src}", flush=True)
    return dest


if __name__ == "__main__":
    for fig, (slug, pose) in POSES.items():
        ctrl = make_control(fig, slug)
        for seed in [777, 778]:
            dest = OUT / f"YR_{slug}_s{seed}.png"
            if dest.exists():
                continue
            replicate_run("black-forest-labs/flux-canny-pro",
                {"prompt": FEMALE.format(pose=pose), "control_image": b64(ctrl),
                 "guidance": 30, "steps": 50, "seed": seed, "output_format": "png",
                 "safety_tolerance": 2}, dest)
            time.sleep(2)
    print("VAGUE5 RIG TERMINÉ", flush=True)
