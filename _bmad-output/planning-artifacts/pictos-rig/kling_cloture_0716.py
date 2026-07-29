import base64
import json
import pathlib
import time
import urllib.request

# Batch de cloture 07-16 (plan valide Sophie) :
# - marichyasana-a_v6 : re-Kling depuis la source CORRIGEE (_mari_final_v3 :
#   jambe tendue visible + 3e pied orphelin retire au pixel).
# - rdl-dumbbell_v12 : decision Sophie « retenter via Kling » — recette
#   forward-fold v6 : UN seul mouvement lent (remontee), palindrome ensuite.
# - ohp-barbell_v2 : decision Sophie « polish micro-flexion » — meme presse
#   stricte mais genoux legerement naturels.

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
PT = pathlib.Path("puppet_triceps")
V4 = pathlib.Path("ai-explo/vague4")
M = pathlib.Path("ai-explo/muscu")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

CLIPS = {
    "marichyasana-a_v6": (PT / "_mari_final_v3.png",
        "The woman holds this seated yoga preparation pose, breathing calmly — her chest "
        "gently rises and falls, she deepens very slightly with an exhale. Her legs NEVER "
        "move: the extended leg stays flat on the mat with its flexed foot still, the bent "
        "knee stays up with its foot flat. Only ONE foot rests on the mat under her bent "
        "knee — no extra feet appear anywhere. Her face NEVER changes — no makeup, her lips "
        "stay the same natural skin tone the entire video." + STYLE),
    "rdl-dumbbell_v12": (V4 / "M_rdl-dumbbell_pilote2.png",
        "ONE single, very slow, smooth movement and nothing else: from this hinged position, "
        "the man slowly stands up COMPLETELY straight, the dumbbell sliding up along his legs "
        "to his thighs, his back staying FLAT the whole way, hips driving forward until he is "
        "fully upright. The movement takes the entire video, calm and continuous. His feet "
        "never move, his arms stay straight, ONE single dumbbell held in both hands the whole "
        "time, never two." + STYLE),
    "ohp-barbell_v2": (M / "B_ohp-barbell_v2.png",
        "The man slowly lowers the barbell from overhead down to his shoulders, then presses "
        "it back up overhead. Slow controlled overhead press repetitions. His knees soften "
        "VERY SLIGHTLY and naturally with the effort — a subtle, barely visible flex as the "
        "bar moves, never a squat, never a jump — so his legs look engaged but not rigid. His "
        "feet never move, ONE barbell the whole time." + STYLE),
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
    for slug, (src, prompt) in CLIPS.items():
        assert src.exists(), f"source manquante: {src}"
        kling(slug, src, prompt)
        time.sleep(3)
    print("BATCH CLOTURE TERMINÉ", flush=True)
