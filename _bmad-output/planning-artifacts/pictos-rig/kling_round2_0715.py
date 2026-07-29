import base64
import json
import pathlib
import time
import urllib.request

# Round 2 des blocages 07-15 :
# - cat-cow_v4 : la v3 a corrige la courbure "chat" (enfin visible) mais la phase
#   "vache" (dos creuse, tete relevee) n'apparait jamais sur la boucle -> prompt
#   qui met la VACHE en premier et la decrit explicitement.
# - triceps-overhead_v4 : image de depart FRAICHE (_triceps-canny_s42, pose enfin
#   non-ambigue : un haltere derriere la tete, coudes vers le plafond) -> animer
#   avec le prompt qui avait PASSE le gate expert sur la v2 (seuls les avant-bras
#   bougent, coudes fixes).

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
B = pathlib.Path("ai-explo/batch")
PT = pathlib.Path("puppet_triceps")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

FIXES = {
    "cat-cow_v4": (B / "B_cat-cow.png",
        "On all fours (hands and knees), the woman performs cat-cow, showing BOTH phases "
        "clearly. FIRST the COW phase: her belly drops down toward the mat, her back arches "
        "downward into a hollow U-shape, her head and chest LIFT UP, her gaze rises toward "
        "the ceiling. THEN the CAT phase: she slowly reverses, rounding her spine up toward "
        "the ceiling in a big upward arch, chin tucking to her chest. She alternates slowly "
        "between these two opposite spine curves, large obvious movement in both directions. "
        "Her hands and knees NEVER leave the floor and never slide. Her leggings color never "
        "changes." + STYLE),
    "triceps-overhead_v4": (PT / "_triceps-canny_s42.png",
        "The man performs overhead triceps extensions. Starting with the dumbbell lowered "
        "behind his head and his elbows bent pointing up, he slowly straightens his arms, "
        "raising the single dumbbell straight up overhead until his arms are almost fully "
        "extended, then slowly bends his elbows again lowering the dumbbell back down behind "
        "his head. His elbows stay high and pointed up the whole time, close to his head — "
        "ONLY his forearms move. His torso, legs and feet stay completely still. Two slow "
        "controlled repetitions." + STYLE),
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
    print("ROUND2 TERMINÉ", flush=True)
