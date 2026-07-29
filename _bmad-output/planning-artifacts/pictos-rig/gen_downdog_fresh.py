import json
import pathlib
import sys
import time
import urllib.request

# Downward-dog "repartir de zero" 07-15 : texte SEUL, aucune image/controlnet de
# reference (6 tentatives conditionnees ont echoue avant : kontext + SDXL-lineart).
# Hypothese Sophie : la pose est ultra-standard, un flux text-to-image pur devrait
# la sortir juste sans qu'on ait besoin de forcer via une image cassee.

TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("puppet_triceps")

PROMPT = (
    "Flat vector illustration of a woman doing a downward-facing dog yoga pose, side view. "
    "Her hips are the single highest point of her body, forming a sharp inverted V / triangle "
    "shape. Both arms are perfectly straight, planted on the floor directly under her shoulders. "
    "Both legs are perfectly straight, feet flat on the floor, hip-width apart, far behind her "
    "hands. Her spine forms one long straight diagonal line from her hands, through her raised "
    "hips, down to her heels. Her head hangs relaxed and loose between her upper arms, looking "
    "down toward her legs. She wears a fitted white sleeveless top and light blue leggings, "
    "barefoot, short brown hair in a low bun. Minimalist flat design, clean simple shapes, soft "
    "muted colors, plain warm light beige background, on a thin white exercise mat, full body "
    "visible, no text, no watermark."
)


def replicate_run(model, inputs, dest):
    body = json.dumps({"input": inputs}).encode()
    api = f"https://api.replicate.com/v1/models/{model}/predictions"
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
                print(f"FAIL {dest}: HTTP {e.code} {e.read()[:300]}", flush=True)
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


if __name__ == "__main__":
    seeds = [int(s) for s in sys.argv[1:]] or [101, 202, 303]
    for seed in seeds:
        dest = OUT / f"_downdog_fresh_s{seed}.png"
        replicate_run("black-forest-labs/flux-1.1-pro",
            {"prompt": PROMPT, "aspect_ratio": "1:1", "output_format": "png",
             "seed": seed, "safety_tolerance": 2}, dest)
        time.sleep(2)
