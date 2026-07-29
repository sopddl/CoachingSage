import base64
import json
import pathlib
import time
import urllib.request

# Round 3 (dernier de la session, regle 2-3 tentatives) :
# - cat-cow_v5 : depart sur image VACHE (tete relevee, kontext 2 passes) -> meme
#   recette que goblet-squat v3 (Kling ancre sur l'image de depart, donc on lui
#   donne la phase qui manquait). L'anim doit aller vache -> chat -> vache.
# - triceps-overhead_v5 : reroll depuis _triceps-canny_s42 en martelant ONE
#   dumbbell (la contrainte qui avait fait passer la v2 au gate expert) —
#   la v4 dedoublait l'haltere pendant les transitions.

VERSION = "e6f571e8d6990da3c96abf8d3082894024d652822f0ca3cd244acece84a1cc3e"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/anim")
PT = pathlib.Path("puppet_triceps")

STYLE = " Flat vector illustration style stays constant, character and background unchanged."

FIXES = {
    "cat-cow_v5": (PT / "_catcow_cow_start_v2.png",
        "On all fours in cow pose (head up, belly dropped, back hollow), the woman slowly "
        "transitions to cat pose: she tucks her chin to her chest, lowers her head, and "
        "rounds her entire spine UP toward the ceiling in a big arch. Then she slowly "
        "reverses back to cow: head lifting up to look forward, belly dropping, back "
        "hollowing. One slow full cat-cow cycle ending back in cow exactly like the start. "
        "Her hands and knees NEVER leave the floor and never slide. Only her spine, neck "
        "and head move." + STYLE),
    "triceps-overhead_v5": (PT / "_triceps-canny_s42.png",
        "The man performs overhead triceps extensions holding ONE SINGLE dumbbell with BOTH "
        "hands together — there is only ONE dumbbell in the entire video, his two hands stay "
        "joined on the same single dumbbell at all times, the dumbbell NEVER splits or "
        "duplicates into two. Starting with the single dumbbell lowered behind his head and "
        "elbows bent pointing up, he slowly straightens both arms raising it straight up "
        "overhead, then slowly bends his elbows lowering it back behind his head. Elbows "
        "stay high, close to his head, pointing up the whole time — only the forearms move. "
        "Torso, legs and feet completely still. Two slow controlled repetitions." + STYLE),
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
    print("ROUND3 TERMINÉ", flush=True)
