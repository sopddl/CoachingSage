import json
import pathlib
import sys
import time
import urllib.request

# "Repartir de zero" 07-15 : meme methode que downdog (qui a marche du 1er coup) —
# texte seul, aucune image/controlnet de reference, pour les 2 autres blocages
# post-gate : foam-rolling-legs (style contours casse depuis toujours, kontext
# n'arrivait pas a l'enlever) et plank-f (aucune source feminine correcte n'existe
# dans tout le catalogue, tous les planks droits sont sur le perso masculin).

TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("puppet_triceps")

STYLE = (" Minimalist flat vector illustration, absolutely NO outlines or stroke lines around "
         "any shape — pure solid flat color silhouettes only, like a modern flat icon. Soft muted "
         "colors, plain warm light beige background, on a thin white exercise mat, full body "
         "visible, no text, no watermark.")
FEMALE = ("a woman, wearing a fitted white sleeveless top and light blue leggings, barefoot, "
          "short brown hair in a low bun, side view, ")

PROMPTS = {
    "foam-rolling-legs": (
        "Flat vector illustration of " + FEMALE +
        "sitting on the floor with both legs stretched straight out in front of her, resting "
        "on top of an elongated cylindrical foam roller placed under her calves — the roller "
        "is clearly a long cylinder lying horizontally, not round or ball-shaped. Her torso is "
        "upright, both hands flat on the floor beside her hips for support, head tilted slightly "
        "up." + STYLE),
    "plank-f": (
        "Flat vector illustration of " + FEMALE +
        "in a high plank position: body forming one perfectly straight line from head to heels, "
        "both arms fully straight with hands flat on the floor directly under her shoulders, "
        "both legs fully straight and together, only her toes touching the floor, hips level "
        "with shoulders and heels, core engaged, looking down." + STYLE),
}


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
    seeds = [101, 202, 303]
    for slug, prompt in PROMPTS.items():
        for seed in seeds:
            dest = OUT / f"_{slug}_fresh_s{seed}.png"
            replicate_run("black-forest-labs/flux-1.1-pro",
                {"prompt": prompt, "aspect_ratio": "1:1", "output_format": "png",
                 "seed": seed, "safety_tolerance": 2}, dest)
            time.sleep(2)
