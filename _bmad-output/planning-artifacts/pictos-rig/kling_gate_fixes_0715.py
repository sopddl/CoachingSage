import base64
import json
import pathlib
import time
import urllib.request

# Fixes post-gate expert/persona/UX 07-15 : kb-swing (pas de lockout hanche en haut)
# et leg-extension (aucune flexion visible, video figee). Prompts renforces,
# tres explicites sur l'etat final attendu a chaque extreme du mouvement.

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
V4 = pathlib.Path("ai-explo/vague4")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

FIXES = {
    "kb-swing_v2": (V4 / "L_kb-swing_1.png",
        "The man performs a kettlebell swing. He explosively snaps his hips forward and "
        "STANDS COMPLETELY UPRIGHT, torso perfectly vertical, hips fully extended, glutes "
        "squeezed, arms and kettlebell swinging up to chest height in front of him, head up "
        "looking forward — this is the clear TOP of the movement, he is NOT bent over at all "
        "at this point. Then he hinges back down, hips pushing far back, torso leaning "
        "forward, the kettlebell swinging back down between his legs. Two full repetitions, "
        "each one reaching the fully upright standing lockout at the top." + STYLE),
    "leg-extension_v2": (V4 / "M_leg-extension_regen8.png",
        "Seated on the leg extension machine, starting with his leg fully extended straight "
        "and horizontal. He slowly bends his knee, letting his foot and the padded roller "
        "drop down to a 90 degree bent-knee position, then powerfully extends his knee "
        "straight again, raising his foot back up to the fully horizontal extended starting "
        "position. Two full clear repetitions with LARGE VISIBLE knee movement between fully "
        "bent and fully straight — his lower leg swings up and down a large amount each rep." + STYLE),
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
