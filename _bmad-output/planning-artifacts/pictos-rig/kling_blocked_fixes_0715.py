import base64
import json
import pathlib
import time
import urllib.request

# Retente cat-cow et marichyasana-a avec prompts fortement renforces (07-15),
# apres 3 echecs cat-cow (2 modeles differents) et 2 echecs marichyasana-a
# (rouge a levres qui apparait). Meme recette que kb-swing/leg-extension
# (qui ont marche) : etat final tres explicite + contraintes negatives fortes.

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
B = pathlib.Path("ai-explo/batch")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

FIXES = {
    "cat-cow_v3": (B / "B_cat-cow.png",
        "On all fours (hands and knees), the woman performs cat-cow. She SLOWLY and "
        "DRAMATICALLY rounds her entire spine up toward the ceiling like an angry cat, her "
        "back clearly curving into a strong upward arch, chin tucked to chest — this curve "
        "must be LARGE and OBVIOUS. Then she slowly reverses into cow pose, her belly "
        "dropping down, her back arching the other way, chest and head lifting up. Her arms "
        "and legs NEVER leave the floor and NEVER change position, only her SPINE curves. "
        "Her leggings color NEVER changes. Slow, smooth, large-amplitude spine movement." + STYLE),
    "marichyasana-a_v3": (B / "B_marichyasana-a.png",
        "The woman gently deepens her seated fold with a slow exhale, then holds, breathing "
        "calmly. She HOLDS the pose, her legs never move. Her face NEVER changes at all — no "
        "makeup appears, her lips STAY EXACTLY the same natural color the entire video, no "
        "lipstick, no color change on her face or lips." + STYLE),
}


def kling(slug, src, prompt):
    dest = OUT / f"anim_{slug}.mp4"
    img = base64.b64encode(pathlib.Path(src).read_bytes()).decode()
    inputs = {"prompt": prompt, "start_image": f"data:image/png;base64,{img}",
              "duration": 5, "cfg_scale": 0.5}
    body = json.dumps({"version": VERSION, "input": inputs}).encode()
    pred = None
    for attempt in range(6):
        req = urllib.request.Request("https://api.replicate.com/v1/predictions", data=body,
            headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"})
        try:
            with urllib.request.urlopen(req, timeout=60) as r:
                pred = json.load(r)
            break
        except urllib.error.HTTPError as e:
            if e.code == 429:
                time.sleep(20 * (attempt + 1))
            else:
                print(f"FAIL {slug}: HTTP {e.code} {e.read()[:200]}", flush=True)
                return False
    if pred is None:
        return False
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(10)
        req = urllib.request.Request(pred["urls"]["get"], headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(req, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL {slug}: {pred.get('error')}", flush=True)
        return False
    out = pred["output"]
    url = out if isinstance(out, str) else out[-1]
    urllib.request.urlretrieve(url, dest)
    print(f"OK — {dest}", flush=True)
    return True


if __name__ == "__main__":
    for slug, (src, prompt) in FIXES.items():
        assert src.exists(), f"source manquante: {src}"
        kling(slug, src, prompt)
        time.sleep(3)
    print("FIXES TERMINÉS", flush=True)
