import base64
import json
import pathlib
import sys
import time
import urllib.request

# Édition d'image flux-kontext-pro (~0,04 $/appel) — brique du batch illustrations.
# Usage : python3 kontext_edit.py <src.png> <dest.png> "<prompt>"
# Le suffixe style/perso/décor est ajouté automatiquement (recette validée 07-11).

TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
SUFFIX = (" Keep the exact same person, same outfit, same flat vector illustration "
          "style, same background and same mat.")


def kontext(src, dest, prompt, retries=6):
    img = base64.b64encode(pathlib.Path(src).read_bytes()).decode()
    inputs = {"prompt": prompt + SUFFIX,
              "input_image": f"data:image/png;base64,{img}",
              "aspect_ratio": "1:1", "output_format": "png", "safety_tolerance": 2}
    body = json.dumps({"input": inputs}).encode()
    pred = None
    for attempt in range(retries):
        req = urllib.request.Request(
            "https://api.replicate.com/v1/models/black-forest-labs/flux-kontext-pro/predictions",
            data=body, headers={"Authorization": f"Bearer {TOKEN}",
                                "Content-Type": "application/json", "Prefer": "wait=60"})
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                pred = json.load(r)
            break
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(15 * (attempt + 1))
            else:
                print(f"FAIL {dest}: HTTP {e.code} {e.read()[:200]}")
                return False
    if pred is None:
        print(f"FAIL {dest}: 429 persistant")
        return False
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(3)
        req = urllib.request.Request(pred["urls"]["get"],
                                     headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(req, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL {dest}: {pred.get('error')}")
        return False
    out = pred["output"]
    url = out if isinstance(out, str) else out[-1]
    urllib.request.urlretrieve(url, dest)
    print(f"OK — {dest}")
    return True


if __name__ == "__main__":
    src, dest, prompt = sys.argv[1], sys.argv[2], sys.argv[3]
    sys.exit(0 if kontext(src, dest, prompt) else 1)
