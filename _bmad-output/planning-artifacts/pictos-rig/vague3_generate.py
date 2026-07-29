import base64
import json
import pathlib
import sys
import time
import urllib.request

sys.path.insert(0, ".")
from kontext_edit import kontext

# VAGUE 3 : SDXL+lineart (contrôle = pose du rig) puis restyle kontext systématique
# vers le personnage/décor catalogue — brique validée sur A_quadrupede.

VERSION = "89eb212b3d1366a83e949c12a4b45dfe6b6b313b594cb8268e864931ac9ffb16"
TOKEN = pathlib.Path("~/.replicate_token").expanduser().read_text().strip()
OUT = pathlib.Path("ai-explo/vague3")

FEMALE = ("flat vector illustration of a woman practicing yoga, {pose}, "
          "wearing a fitted white sleeveless top fully covering her torso and light blue leggings, "
          "barefoot, short brown hair in a low bun, minimalist flat design, clean simple shapes, "
          "soft muted colors, plain warm light beige background, on a thin white exercise mat, "
          "full body visible")
NEGATIVE = ("bare midriff, crop top, photo, photorealistic, 3d render, stick figure, skeleton, "
            "text, watermark, extra limbs, missing limbs, deformed hands, distorted face")
RESTYLE = ("Keep the exact same pose, but make the person a woman with short brown hair in a low "
           "bun, wearing a fitted white sleeveless top and light blue leggings, barefoot, her face "
           "simple and calm, flat vector illustration style, thin white exercise mat on the floor, "
           "plain warm light beige background.")

PROMPTS = {
    "headstand": ("supported headstand, the crown of the head resting on the floor BETWEEN her "
                  "FOREARMS, both forearms flat on the floor with elbows bent and hands clasped "
                  "behind the head, legs together pointing straight up vertical, body fully inverted",
                  "straight arms, palms flat wide, hands on floor beside head"),
    "dolphin": ("dolphin pose, side view, ELBOWS and FOREARMS flat on the floor, hips lifted UP "
                "high toward the ceiling, legs straight, feet flat on the floor, an inverted V "
                "resting on the forearms, head between the arms", "straight arms, plank, all fours"),
    "warrior2": ("warrior two pose, side view, deep lunge with front knee bent above the ankle, back "
                 "leg straight, both feet flat on the floor, torso UPRIGHT vertical, one arm extended "
                 "straight forward horizontal at shoulder height", "leaning forward, bent torso"),
    "tree": ("tree pose, standing balanced on one straight leg, the other foot pressed against the "
             "INNER THIGH of the standing leg well above the knee, knee opened to the side, hands "
             "in prayer at the chest", "foot on knee, sitting"),
    "staff-pose": ("staff pose, side view, sitting with both legs stretched straight together in "
                   "front of her flat on the floor, toes up, back perfectly upright, palms flat on "
                   "the floor beside her hips", "crossed legs, bent knees, standing"),
    "seated-forward-fold": ("seated forward fold, side view, sitting with legs stretched straight in "
                            "front, torso folded forward over the legs, chest on thighs, hands "
                            "reaching the feet", "crossed legs, kneeling, standing"),
    "wide-angle-seated-fold": ("wide angle seated forward fold, FRONT view, sitting with both legs "
                               "stretched straight and spread wide apart in a V, torso leaning "
                               "forward between the legs, hands on the floor", "crossed legs, side view"),
    "warrior3": ("warrior three pose, side view, balancing on one straight leg with the foot flat on "
                 "the floor, torso horizontal leaning forward, back leg lifted straight behind at hip "
                 "height, arms stretched forward past the ears", "both feet on floor, jumping"),
    "half-moon": ("half moon pose, side view, balancing on one straight leg with one hand touching "
                  "the floor below the shoulder, the other leg lifted straight horizontal behind at "
                  "hip height, top arm pointing straight up", "both feet on floor, dancer pose"),
    "boat": ("boat pose, side view, balancing on the sitting bones, legs lifted straight at 45 "
             "degrees off the floor, torso leaning slightly back forming a V shape, arms stretched "
             "forward parallel to the floor", "sitting flat, feet on floor, lying down"),
    "camel": ("camel pose, side view, KNEELING upright with knees and shins on the floor, thighs "
              "vertical, back arched backward, chest open toward the ceiling, hands reaching back "
              "to the heels", "on all fours, standing, sitting on heels"),
    "wide-legged-forward-fold": ("wide legged standing forward fold, FRONT view, feet spread very "
                                 "wide apart flat on the floor, legs straight, torso folded down "
                                 "with the head hanging between the legs, hands on the floor",
                                 "side view, lunge, sitting"),
    "forearm-tabletop": ("tabletop position on the FOREARMS, side view, kneeling with knees on the "
                         "floor under the hips, ELBOWS and FOREARMS flat on the floor under the "
                         "shoulders, back flat horizontal", "straight arms, palms only, plank"),
    "side-plank": ("side plank, balancing on one straight arm with the hand flat on the floor, body "
                   "turned sideways in one straight diagonal line from head to stacked feet, other "
                   "arm pointing straight up", "front plank, all fours, kneeling"),
    "forearm-plank": ("forearm plank, side view, ELBOWS and FOREARMS flat on the floor under the "
                      "shoulders, body in one perfectly straight horizontal line from head to heels, "
                      "toes tucked on the floor", "straight arms, raised hips, all fours, knees down"),
}


def sdxl(slug, seed=777):
    pose, neg = PROMPTS[slug]
    ctrl = base64.b64encode((OUT / f"{slug}_control.png").read_bytes()).decode()
    inputs = {"prompt": FEMALE.format(pose=pose), "negative_prompt": f"{neg}, {NEGATIVE}",
              "controlnet_1": "lineart", "controlnet_1_image": f"data:image/png;base64,{ctrl}",
              "controlnet_1_conditioning_scale": 0.48, "width": 1024, "height": 1024,
              "num_inference_steps": 30, "guidance_scale": 7.5, "num_outputs": 1,
              "apply_watermark": False, "seed": seed}
    body = json.dumps({"version": VERSION, "input": inputs}).encode()
    pred = None
    for attempt in range(6):
        req = urllib.request.Request("https://api.replicate.com/v1/predictions", data=body,
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
                print(f"FAIL sdxl {slug}: {e.code}", flush=True)
                return False
    if pred is None:
        return False
    while pred["status"] not in ("succeeded", "failed", "canceled"):
        time.sleep(3)
        req = urllib.request.Request(pred["urls"]["get"], headers={"Authorization": f"Bearer {TOKEN}"})
        with urllib.request.urlopen(req, timeout=30) as r:
            pred = json.load(r)
    if pred["status"] != "succeeded":
        print(f"FAIL sdxl {slug}: {pred.get('error')}", flush=True)
        return False
    outs = pred["output"] if isinstance(pred["output"], list) else [pred["output"]]
    url = next((u for u in outs if "/out-" in u), outs[-1])
    urllib.request.urlretrieve(url, OUT / f"{slug}_sdxl.png")
    return True


for i, slug in enumerate(PROMPTS):
    final = OUT / f"B_{slug}_v3.png"
    if final.exists():
        continue
    if not (OUT / f"{slug}_sdxl.png").exists():
        if not sdxl(slug):
            continue
    time.sleep(2)
    kontext(str(OUT / f"{slug}_sdxl.png"), str(final), RESTYLE)
    print(f"[{i+1}/13] {slug} fait", flush=True)
    time.sleep(2)
print("VAGUE 3 TERMINÉE", flush=True)
