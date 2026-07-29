import base64
import json
import pathlib
import re
import subprocess
import sys
import time
import urllib.request

from PIL import Image

# PILOTE FLUX+ControlNet (tête de vague muscu, décision Sophie 07-11) :
# 4 poses des familles réfractaires yoga (0/N en SDXL+lineart et kontext).
# 2 recettes testées par pose : flux-canny-pro (BFL) et xlabs flux-dev-controlnet
# (canny). ≥2/4 poses OK → retenter les 26 à-revoir yoga ; sinon gel définitif.

TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
V3 = pathlib.Path("ai-explo/vague3")
OUT = pathlib.Path("ai-explo/pilot-flux")
OUT.mkdir(exist_ok=True)

FEMALE = ("flat vector illustration of a woman practicing yoga, {pose}, "
          "wearing a fitted white sleeveless top fully covering her torso and light blue leggings, "
          "barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, "
          "soft muted colors, plain warm light beige background, on a thin white exercise mat, "
          "full body visible, side view")

POSES = {
    "forearm-plank": "forearm plank, ELBOWS and FOREARMS flat on the floor under the shoulders, "
                     "body in one perfectly straight horizontal line from head to heels, toes tucked on the floor",
    "staff-pose": "staff pose, sitting with both legs stretched straight together in front of her "
                  "flat on the floor, toes up, back perfectly upright, palms flat on the floor beside her hips",
    "camel": "camel pose, KNEELING upright with knees and shins on the floor, thighs vertical, "
             "back arched backward, chest open toward the ceiling, hands reaching back to the heels",
    "low-lunge": "low lunge, front knee bent with the foot flat on the floor, BACK KNEE resting on "
                 "the floor with the shin flat behind, torso upright, arms raised overhead",
}


def replicate_run(url_or_version, inputs, dest, by_version=False):
    body = json.dumps({"version": url_or_version, "input": inputs} if by_version
                      else {"input": inputs}).encode()
    api = ("https://api.replicate.com/v1/predictions" if by_version
           else f"https://api.replicate.com/v1/models/{url_or_version}/predictions")
    pred = None
    for attempt in range(6):
        req = urllib.request.Request(api, data=body,
            headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json",
                     "Prefer": "wait=60"})
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                pred = json.load(r)
            break
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(15 * (attempt + 1))
            else:
                print(f"FAIL {dest}: HTTP {e.code} {e.read()[:200]}", flush=True)
                return False
    if pred is None:
        return False
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(3)
        req = urllib.request.Request(pred["urls"]["get"], headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(req, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL {dest}: {pred.get('error')}", flush=True)
        return False
    out = pred["output"]
    url = out if isinstance(out, str) else (next((u for u in out if "/out-" in u), out[-1]))
    urllib.request.urlretrieve(url, dest)
    print(f"OK — {dest}", flush=True)
    return True


def b64(path):
    return "data:image/png;base64," + base64.b64encode(pathlib.Path(path).read_bytes()).decode()


def canny_pro(slug, ctrl, seed=777):
    dest = OUT / f"{slug}_cannypro_s{seed}.png"
    if dest.exists():
        return True
    return replicate_run("black-forest-labs/flux-canny-pro",
        {"prompt": FEMALE.format(pose=POSES[slug]), "control_image": b64(ctrl),
         "guidance": 30, "steps": 50, "seed": seed, "output_format": "png",
         "safety_tolerance": 2}, dest)


def xlabs(slug, ctrl, seed=777, strength=0.55):
    dest = OUT / f"{slug}_xlabs_s{seed}.png"
    if dest.exists():
        return True
    return replicate_run(
        "9a8db105db745f8b11ad3afe5c8bd892428b2a43ade0b67edc4e0ccd52ff2fda",
        {"prompt": FEMALE.format(pose=POSES[slug]), "control_image": b64(ctrl),
         "control_type": "canny", "control_strength": strength, "steps": 28,
         "guidance_scale": 3.5, "seed": seed, "output_format": "png",
         "negative_prompt": "photo, photorealistic, 3d render, stick figure, skeleton, text, "
                            "watermark, extra limbs, deformed hands"},
        dest, by_version=True)


def make_low_lunge_control():
    """Extrait Anjaneyasana de lot8.html — même nettoyage que vague3_controls.py."""
    dest = V3 / "low-lunge_control.png"
    if dest.exists():
        return
    html = pathlib.Path("lot8.html").read_text()
    svg = None
    for m in re.finditer(r'<figure>(.*?)</figure>', html, re.S):
        block = m.group(1)
        t = re.search(r'<figcaption><b>([^<]+)</b>', block)
        s = re.search(r'(<svg.*?</svg>)', block, re.S)
        if t and s and "Anjaneyasana" in t.group(1):
            svg = s.group(1)
            break
    assert svg, "Anjaneyasana introuvable dans lot8.html"
    svg = re.sub(r'<circle[^>]*r="1\.5"[^>]*/>', "", svg)
    svg = re.sub(r'<[^>]*stroke-dasharray[^>]*/>', "", svg)
    svg = re.sub(r'<path[^>]*stroke="#8a8a8a"[^>]*/>', "", svg)
    svg = re.sub(r'<line[^>]*stroke="#e8a93d"[^>]*/>', "", svg)
    svg = svg.replace('r="3.0" fill="none"', 'r="3.0" fill="#1a1a1a"')
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
    svg_path = V3 / "low-lunge_control.svg"
    svg_path.write_text(full)
    tmp = V3 / "low-lunge_control_raw.png"
    subprocess.run(["rsvg-convert", "-w", "1024", str(svg_path), "-o", str(tmp)], check=True)
    im = Image.open(tmp).convert("RGB")
    side = max(im.size)
    sq = Image.new("RGB", (side, side), "white")
    sq.paste(im, ((side - im.width) // 2, (side - im.height) // 2))
    sq.resize((1024, 1024)).save(dest)
    tmp.unlink()
    print("OK — contrôle low-lunge extrait", flush=True)


if __name__ == "__main__":
    make_low_lunge_control()
    for slug in POSES:
        ctrl = V3 / f"{slug}_control.png"
        assert ctrl.exists(), f"contrôle manquant: {ctrl}"
        canny_pro(slug, ctrl)
        time.sleep(2)
        xlabs(slug, ctrl)
        time.sleep(2)
    print("PILOTE TERMINÉ", flush=True)
