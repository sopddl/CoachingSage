import base64
import json
import pathlib
import sys
import time
import urllib.request

# ============================================================
# PLANCHE — génération Replicate, recette validée 07-10 :
# fofr/sdxl-multi-controlnet-lora + controlnet lineart 0.45,
# contrôle = stick-figure sans ronds ni sol (gen_planche_controls.py).
# Usage : python3 gen_planche_replicate.py [slug seed] — sans args,
# génère les 5 poses au seed par défaut ; avec args, relance UNE pose
# à un seed donné (curation).
# ============================================================

VERSION = "89eb212b3d1366a83e949c12a4b45dfe6b6b313b594cb8268e864931ac9ffb16"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/planche")

# Décor UNIQUE catalogue (review UX 07-11) : même fond + même tapis fin gris partout.
SCENE = ("minimalist flat design, clean simple shapes, soft muted colors, plain light "
         "blue-grey background, on a thin flat light grey exercise mat, full body visible")
FEMALE = ("flat vector illustration of a woman practicing yoga, {pose}, "
          "wearing a fitted long-sleeve white top fully covering her torso and light blue leggings, "
          f"barefoot, short brown hair in a low bun, {SCENE}")
MALE = ("flat vector illustration of a man exercising at the gym, {pose}, "
        "wearing a fitted white t-shirt fully covering his torso and long dark blue pants, "
        f"athletic sneakers, short dark hair, clean shaven, {SCENE}")
NEGATIVE = ("bare midriff, crop top, exposed stomach, photo, photorealistic, 3d render, "
            "realistic skin texture, stick figure, skeleton, text, watermark, "
            "extra limbs, missing limbs, deformed hands, distorted face")

# (template perso, description pose, negative additionnel par pose)
POSES = {
    "warrior1": (FEMALE, "warrior one yoga lunge pose, side view, torso upright vertical, both arms fully "
                         "extended straight up overhead above her head, front knee bent, back leg "
                         "straight stretched behind her, BOTH feet planted flat on the floor, back heel down",
                 "dancer, ballet, arabesque, lifted leg, leg in the air, jumping, arms down, leaning forward, hands on knee"),
    "cobra": (FEMALE, "cobra yoga pose, side view, pelvis and legs pressed flat on the floor, "
                      "chest and head lifted up high, back arched, arms straight with hands on "
                      "the floor directly under the shoulders",
              "lying on back, face up, sleeping, pillow, cushion, blanket, hips raised, buttocks up, downward dog"),
    "downdog": (FEMALE, "downward facing dog pose, side view, body folded at the hips in a "
                        "perfect inverted V shape, straight arms and straight legs, hands and "
                        "feet flat on the floor, hips at the highest point, head hanging down "
                        "between the upper arms",
                "backbend, bridge pose, wheel pose, standing, lifted leg"),
    "goblet_squat": (MALE, "goblet squat, side view, deep squat with both knees bent, both feet "
                           "flat on the floor, holding one single dumbbell vertically with both "
                           "hands close to his chest",
                     "boxing, punching, hat, cap"),
    "deadlift": (MALE, "barbell deadlift at the bottom of the lift, side view, hips hinged back, FLAT "
                       "straight back leaning forward, arms hanging straight down gripping a long "
                       "barbell with large round weight plates, the barbell close to his shins "
                       "just below the knees",
                 "overhead press, barbell in the air, snatch, giant wheel, rounded back, dumbbell"),
    # positions de DÉPART (paire départ → position clé, retour Sophie 07-11)
    "start_stand": (FEMALE, "standing upright in a relaxed neutral position, side view, arms "
                            "resting along her sides, feet together flat on the floor, looking "
                            "straight ahead",
                    "raised arms, lunge, bent knees, jumping"),
    "start_prone": (FEMALE, "lying face down flat on the floor, side view, completely flat prone "
                            "position, legs stretched straight behind her, hands placed on the "
                            "floor under her shoulders with elbows bent close to the body, "
                            "forehead near the floor",
                    "lying on back, face up, chest lifted, arched back, pillow, legs lifted off the floor, superman pose"),
    "start_stand_dumbbell": (MALE, "standing upright, side view, holding one single dumbbell "
                                   "vertically with both hands in front of his chest, elbows bent, "
                                   "feet flat on the floor",
                             "squat, bent knees, lunge, overhead"),
    "start_stand_barbell": (MALE, "standing fully upright at the top of a deadlift, side view, holding a long "
                                  "barbell with large round weight plates with both straight arms, the bar "
                                  "resting against his thighs, shoulders back, head up",
                            "bent over, squat, barbell overhead, barbell on shoulders, dumbbell"),
}
DEFAULT_SEED = 777


def generate(slug, seed, scale=0.45, pair_from=None, strength=0.85):
    """pair_from : chemin d'une image A — génère B en img2img depuis A (même
    personnage/tenue/décor garantis, review 07-11) + controlnet pose de B."""
    tpl, pose, neg_extra = POSES[slug]
    control_b64 = base64.b64encode((OUT / f"{slug}_control.png").read_bytes()).decode()
    inputs = {
        "prompt": tpl.format(pose=pose),
        "negative_prompt": f"{neg_extra}, {NEGATIVE}",
        "controlnet_1": "lineart",
        "controlnet_1_image": f"data:image/png;base64,{control_b64}",
        "controlnet_1_conditioning_scale": scale,
        "width": 1024, "height": 1024,
        "num_inference_steps": 30, "guidance_scale": 7.5,
        "num_outputs": 1, "apply_watermark": False,
        "seed": seed,
    }
    if pair_from:
        img_b64 = base64.b64encode(pathlib.Path(pair_from).read_bytes()).decode()
        inputs["image"] = f"data:image/png;base64,{img_b64}"
        inputs["prompt_strength"] = strength
        inputs["sizing_strategy"] = "input_image"
    body = json.dumps({"version": VERSION, "input": inputs}).encode()
    pred = None
    for attempt in range(6):  # throttle compte petit crédit : backoff sur 429
        req = urllib.request.Request(
            "https://api.replicate.com/v1/predictions", data=body,
            headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json",
                     "Prefer": "wait=60"})
        try:
            with urllib.request.urlopen(req, timeout=90) as r:
                pred = json.load(r)
            break
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = 15 * (attempt + 1)
                print(f"  429 — retry dans {wait}s ({slug})")
                time.sleep(wait)
            else:
                print(f"FAIL — {slug} seed {seed}: HTTP {e.code} {e.read()[:300]}")
                return
    if pred is None:
        print(f"FAIL — {slug} seed {seed}: 429 persistant")
        return
    # poll si pas fini dans la fenêtre sync
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(3)
        req = urllib.request.Request(pred["urls"]["get"],
                                     headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(req, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL — {slug} seed {seed}: {pred.get('error')}")
        return
    # output = [control-0.png, out-0.png] — prendre l'image générée, pas la carte de contrôle
    outs = pred["output"] if isinstance(pred["output"], list) else [pred["output"]]
    url = next((u for u in outs if "/out-" in u), outs[-1])
    suffix = "_pair" if pair_from else ""
    dest = OUT / f"{slug}_flat_s{seed}_c{int(scale * 100)}{suffix}.png"
    urllib.request.urlretrieve(url, dest)
    print(f"OK — {dest}")


if len(sys.argv) >= 3:
    generate(sys.argv[1], int(sys.argv[2]),
             float(sys.argv[3]) if len(sys.argv) > 3 else 0.45,
             pair_from=sys.argv[4] if len(sys.argv) > 4 else None,
             strength=float(sys.argv[5]) if len(sys.argv) > 5 else 0.85)
else:
    for slug in POSES:
        generate(slug, DEFAULT_SEED)
        time.sleep(2)  # throttle doux
