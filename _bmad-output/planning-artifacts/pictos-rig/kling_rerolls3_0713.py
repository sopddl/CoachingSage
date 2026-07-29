import base64
import json
import pathlib
import sys
import time
import urllib.request

sys.path.insert(0, ".")
from kling_animate import STYLE, TOKEN, kling

B = pathlib.Path("ai-explo/batch")
M = pathlib.Path("ai-explo/muscu")

REROLLS3 = {
    "embryo_v2": (B / "B_embryo.png",
        "She rests curled up, perfectly still, breathing slowly — her back gently rises "
        "and falls. Her FEET stay exactly as in the first frame, both feet pointing in "
        "the SAME direction as her body, toes never rotating or flipping." + STYLE),
    "downward-dog_v2": (B / "B_downward-dog.png",
        "She holds downward dog while breathing DEEPLY and VISIBLY: her chest and belly "
        "clearly expand and contract with each slow breath, her back gently lengthens on "
        "each exhale, her heels press a little further toward the mat. The motion is "
        "gentle but clearly visible. She never walks, never lowers to the floor." + STYLE),
    "lunge-dumbbell_v6": (M / "A_m_stand_db.png",
        "TWO complete lunge repetitions: he steps forward into a deep lunge with the "
        "dumbbells at his sides, pushes back up and RETURNS COMPLETELY TO STANDING with "
        "feet together, then steps forward into a second deep lunge, and finishes by "
        "returning to standing again. Clear full return to standing between each "
        "repetition." + STYLE),
}


def minimax(slug, src, prompt):
    dest = pathlib.Path("ai-explo/anim") / f"anim_{slug}.mp4"
    if dest.exists():
        return True
    img = base64.b64encode(pathlib.Path(src).read_bytes()).decode()
    body = json.dumps({"input": {"prompt": prompt,
                                 "first_frame_image": f"data:image/png;base64,{img}"}}).encode()
    req = urllib.request.Request(
        "https://api.replicate.com/v1/models/minimax/video-01/predictions",
        data=body, headers={"Authorization": f"Bearer {TOKEN}",
                            "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            pred = json.load(r)
    except urllib.error.HTTPError as e:
        print(f"FAIL {slug}: HTTP {e.code} {e.read()[:300]}", flush=True)
        return False
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(15)
        rq = urllib.request.Request(pred["urls"]["get"], headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(rq, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL {slug}: {pred.get('error')}", flush=True)
        return False
    out = pred["output"]
    urllib.request.urlretrieve(out if isinstance(out, str) else out[-1], dest)
    print(f"OK — {dest}", flush=True)
    return True


if __name__ == "__main__":
    for slug, (src, prompt) in REROLLS3.items():
        assert src.exists(), f"source manquante: {src}"
        kling(slug, src, prompt)
        time.sleep(3)
    minimax("cat-cow_mm1", B / "B_cat-cow.png",
        "Flat vector illustration animation: on all fours on her mat, the woman slowly "
        "ROUNDS her spine up toward the ceiling tucking her chin (cat), then slowly "
        "ARCHES her belly down lifting her chest and gaze (cow), flowing smoothly and "
        "continuously between the two with her breath, ending in a neutral flat back. "
        "Smooth gentle looping motion, character and style unchanged, she stays on all "
        "fours the entire time.")
    print("REROLLS3 TERMINÉS", flush=True)
