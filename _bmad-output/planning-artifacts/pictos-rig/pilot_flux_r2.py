import time

from pilot_flux import OUT, V3, POSES, FEMALE, b64, replicate_run

# Round 2 (dernier) du pilote — correctifs ciblés après revue gate 1 :
# forearm-plank : géométrie OK mais corps flottant → ancrage martelé au prompt.
# camel / low-lunge : pigeon rendu à la place → négatifs anti-pigeon + xlabs 0.65.

R2 = {
    "forearm-plank": ("forearm plank, her ELBOWS and FOREARMS pressed flat INTO the white mat on "
                      "the floor, weight resting on the forearms which TOUCH the mat, body in one "
                      "straight horizontal line just above the floor, toes tucked on the mat",
                      "floating, hovering above the floor, gap under the arms, push-up on hands"),
    "camel": ("camel pose backbend, KNEELING UPRIGHT with BOTH knees and BOTH shins side by side "
              "flat on the floor, thighs vertical, hips pushed forward, back arched backward, "
              "chest open toward the ceiling, both hands reaching back to grab the heels",
              "pigeon pose, one leg extended forward or backward, sitting on the floor, splits, "
              "torso leaning forward"),
    "low-lunge": ("low lunge, the FRONT FOOT planted FLAT on the floor in front with the front "
                  "knee bent directly above the front ankle, the BACK KNEE and back shin resting "
                  "on the floor behind, torso upright, both arms raised overhead",
                  "pigeon pose, foot tucked under the hips, sitting on the heel, splits, "
                  "both legs on the floor"),
}


def canny_pro_r2(slug, seed=2025):
    pose, neg = R2[slug]
    dest = OUT / f"{slug}_cannypro_r2_s{seed}.png"
    if dest.exists():
        return True
    # canny-pro n'a pas de negative_prompt → négatifs intégrés en "not ..." inutile,
    # on mise sur la description renforcée seule
    return replicate_run("black-forest-labs/flux-canny-pro",
        {"prompt": FEMALE.format(pose=pose), "control_image": b64(V3 / f"{slug}_control.png"),
         "guidance": 30, "steps": 50, "seed": seed, "output_format": "png",
         "safety_tolerance": 2}, dest)


def xlabs_r2(slug, seed=2025, strength=0.65):
    pose, neg = R2[slug]
    dest = OUT / f"{slug}_xlabs_r2_s{seed}.png"
    if dest.exists():
        return True
    return replicate_run(
        "9a8db105db745f8b11ad3afe5c8bd892428b2a43ade0b67edc4e0ccd52ff2fda",
        {"prompt": FEMALE.format(pose=pose), "control_image": b64(V3 / f"{slug}_control.png"),
         "control_type": "canny", "control_strength": strength, "steps": 28,
         "guidance_scale": 3.5, "seed": seed, "output_format": "png",
         "negative_prompt": f"{neg}, photo, photorealistic, 3d render, stick figure, skeleton, "
                            "text, watermark, extra limbs, deformed hands"},
        dest, by_version=True)


if __name__ == "__main__":
    for slug in R2:
        canny_pro_r2(slug)
        time.sleep(2)
        xlabs_r2(slug)
        time.sleep(2)
    print("ROUND 2 TERMINÉ", flush=True)
