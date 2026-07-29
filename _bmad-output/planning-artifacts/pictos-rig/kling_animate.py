import base64
import json
import pathlib
import time
import urllib.request

# ANIMATIONS VITRINES — Kling v1.6 standard (recette validée 07-10 sur Triangle).
# start_image = image plate validée ; prompt = mouvement (entrée posture / répétitions
# lentes) puis tenue respirée. ~0,25-0,50 $/vidéo, durée 5 s.

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
OUT.mkdir(exist_ok=True)
M = pathlib.Path("ai-explo/muscu")
B = pathlib.Path("ai-explo/batch")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

VITRINES = {
    # ---- muscu (répétitions lentes depuis la position clé) ----
    "goblet-squat": (M / "B_goblet-squat_fix2.png",
        "The man slowly stands up from the squat, keeping the dumbbell vertical at his "
        "chest, then slowly squats back down. Slow controlled squat repetitions." + STYLE),
    "lunge-dumbbell": (M / "B_lunge-dumbbell_fix.png",
        "The man slowly pushes back up from the lunge to standing upright with the "
        "dumbbells at his sides, then steps forward again into the lunge. Slow controlled "
        "lunge repetitions." + STYLE),
    "biceps-curl": (M / "B_biceps-curl_fix2.png",
        "The man slowly curls the dumbbells up toward his shoulders and lowers them back "
        "down, alternating arms. Slow controlled biceps curls." + STYLE),
    "ohp-barbell": (M / "B_ohp-barbell_v2.png",
        "The man slowly lowers the barbell from overhead down to his shoulders, then "
        "presses it back up overhead. Slow controlled overhead press repetitions." + STYLE),
    "pushup-incline-chair": (M / "B_pushup-incline-chair.png",
        "The man slowly bends his elbows lowering his chest toward the chair seat, then "
        "pushes back up to straight arms. Slow controlled incline push-up repetitions." + STYLE),
    # ---- yoga (installation dans la posture + respiration) ----
    "warrior1": (B / "B_warrior1.png",
        "The woman settles into warrior one pose, grounding her back heel and reaching "
        "her arms higher, then holds the pose breathing calmly and deeply." + STYLE),
    "tree": (B / "B_tree.png",
        "The woman steadies her balance in tree pose, pressing her palms together at her "
        "chest, then holds the pose breathing calmly, perfectly still." + STYLE),
    "chair": (B / "B_chair.png",
        "The woman sinks a little deeper into chair pose, arms reaching forward, then "
        "holds the pose breathing calmly and steadily." + STYLE),
    "cat-cow": (B / "B_cat-cow.png",
        "On all fours, the woman slowly rounds her spine up toward the ceiling, then "
        "slowly arches it down, flowing gently between cat and cow with her breath." + STYLE),
    "staff-pose": (B / "B_staff-pose.png",
        "The woman lengthens her spine upward in staff pose, legs active and straight, "
        "then holds the pose breathing calmly and quietly." + STYLE),
}


def kling(slug, src, prompt):
    dest = OUT / f"anim_{slug}.mp4"
    if dest.exists():
        return True
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


# Re-rolls retours Sophie 07-11 : amplitude/alternance/retour debout martelés.
# Fichiers _v2 — l'original est gardé pour comparaison.
REROLLS = {
    "goblet-squat_v2": (M / "B_goblet-squat_fix2.png",
        "The man stands up COMPLETELY from the squat until his legs are fully straight "
        "and he is standing tall upright, then slowly squats all the way back down. "
        "FULL RANGE squat repetitions, large visible movement." + STYLE),
    "biceps-curl_v2": (M / "B_biceps-curl_fix2.png",
        "The man performs ALTERNATING biceps curls: his right arm curls its dumbbell up "
        "to the shoulder while the left arm lowers its dumbbell down, then they SWAP — "
        "the left arm curls up while the right lowers. BOTH arms clearly move, one "
        "after the other." + STYLE),
    "lunge-dumbbell_v2": (M / "B_lunge-dumbbell_fix.png",
        "The man pushes back COMPLETELY out of the lunge and RETURNS TO STANDING fully "
        "upright with his feet together and the dumbbells at his sides, then steps "
        "forward again into the deep lunge. FULL repetitions with a clear return to "
        "standing between each lunge." + STYLE),
}

if __name__ == "__main__":
    for slug, (src, prompt) in {**VITRINES, **REROLLS}.items():
        assert src.exists(), f"source manquante: {src}"
        kling(slug, src, prompt)
        time.sleep(3)
    print("ANIMATIONS TERMINÉES", flush=True)
