import pathlib
import shutil
import sys
import time

sys.path.insert(0, ".")
from kontext_edit import kontext

# VAGUE MUSCU — phase B : un exo = édition kontext depuis l'image A de son type.
# Tier 1 = zone de réussite (debout / haltères / barre / gainage / quadrupède).
# Tier 2 = équipement nouveau (barre fixe, câble, banc, box, mur) — 2 essais max.
# GELÉS (familles KO confirmées 07-11, 2+2 essais) : allongé-dos (glute-bridge,
# dead-bug, hollow, clamshell), banc couché (bench press barre/haltères, pullover),
# machines assises (leg-press/ext/curl, reverse-hyper, cable-fly/row, facepull),
# ventral (YTW), hip-thrust (banc). walking-lunge = dédup picto lunge.

OUT = pathlib.Path("ai-explo/muscu")
A = {
    "stand": OUT / "A_m_stand.png",
    "stand_db": OUT / "A_m_stand_db.png",
    "goblet": OUT / "A_m_goblet.png",
    "stand_bb": OUT / "A_m_stand_bb_v2.png",
    "plank": OUT / "A_m_plank.png",
    "tabletop": OUT / "A_m_tabletop.png",
}

# slug -> (type de départ, prompt kontext "Change his pose: …")
BATCH = {
    # ---- TIER 1 ----
    "squat-bodyweight": ("stand",
        "Change his pose: he squats down, hips pushed back and down, knees bent deep, "
        "thighs parallel to the floor, both feet flat on the mat, both arms extended "
        "straight forward horizontally for balance, back straight, torso leaning slightly forward."),
    "calf-raise": ("stand",
        "Change his pose: he rises up onto the balls of his feet, both heels lifted high "
        "off the mat, legs straight, standing tall, arms relaxed straight at his sides."),
    "lunge-dumbbell": ("stand_db",
        "Change his pose: he steps into a forward lunge, front knee bent about 90 degrees "
        "directly above the front ankle, front foot flat on the mat, back knee bent low "
        "just above the mat, back heel lifted, torso upright, still holding one dumbbell "
        "in each hand with arms hanging straight down at his sides."),
    "rdl-dumbbell": ("stand_db",
        "Change his pose: he hinges forward at the hips, back flat, torso leaning forward, "
        "knees slightly bent, hips pushed back, both dumbbells lowered together in front "
        "of his shins, arms hanging straight down."),
    "biceps-curl": ("stand_db",
        "Change his pose: he curls both dumbbells up, upper arms vertical with elbows "
        "pinned at his sides, forearms bent up so the dumbbells reach shoulder height, "
        "standing upright."),
    "triceps-overhead": ("stand_db",
        "Change his pose: he now holds one single dumbbell with both hands behind his "
        "head, elbows bent pointing straight up, upper arms vertical beside his ears, "
        "standing upright. The other dumbbell is gone."),
    "kb-swing": ("stand_db",
        "Replace the dumbbells with one single kettlebell held with both hands. Change his "
        "pose: hips hinged back, knees slightly bent, torso leaning forward slightly, both "
        "arms straight swinging the kettlebell forward and up to chest height."),
    "rdl-barbell": ("stand_bb",
        "Change his pose: he hinges forward at the hips, back flat, knees slightly bent, "
        "hips pushed back, the barbell lowered to mid-shin height with both arms straight, "
        "the weight plates NOT touching the mat."),
    "deadlift-conventional": ("stand_bb",
        "Change his pose: the barbell now rests ON the mat with its round weight plates "
        "touching the mat. He bends down gripping the bar with both arms straight and "
        "vertical, hips high, knees bent, back flat, chest up, ready to lift."),
    "back-squat": ("stand_bb",
        "Change his pose: the barbell now rests across his upper back and shoulders behind "
        "his neck, both hands gripping the bar. He squats down, knees bent deep, thighs "
        "parallel to the floor, torso upright, both feet flat on the mat."),
    "ohp-barbell": ("stand_bb",
        "Change his pose: he presses the barbell straight overhead, both arms fully "
        "extended vertically, the bar directly above his head, standing upright, feet flat."),
    "bentover-row-barbell": ("stand_bb",
        "Change his pose: he hinges forward with his torso leaning forward, back flat, "
        "knees slightly bent, and pulls the barbell up against his lower chest, elbows "
        "bent pointing up behind him."),
    "pushup": ("plank",
        "Change his pose: he lowers into the bottom of a push-up, elbows bent pointing "
        "back, chest hovering just above the mat, body in one straight line from head to "
        "heels, toes tucked on the mat."),
    "side-plank": ("plank",
        "Change his pose: he rotates into a side plank, balancing on one straight arm "
        "with the hand flat on the mat, body turned sideways in one straight diagonal "
        "line, feet stacked, the other arm pointing straight up toward the ceiling."),
    "bird-dog": ("tabletop",
        "Change his pose: still on all fours, he extends one arm straight forward "
        "horizontally and the opposite leg straight back horizontally, back flat, "
        "balancing on the other hand and the other knee."),
    # ---- TIER 2 (équipement / scènes nouvelles — 2 essais max) ----
    "wall-sit": ("stand",
        "Add a flat vertical wall on the right edge of the image. Change his pose: his "
        "back is flat against the wall, knees bent at 90 degrees, thighs horizontal, "
        "feet flat on the floor, arms relaxed at his sides, as if sitting on an "
        "invisible chair."),
    "arnold-press-seated": ("stand_db",
        "Add a flat dark bench. Change his pose: he sits upright on the bench, feet flat "
        "on the floor, pressing both dumbbells overhead with arms extended straight up."),
    "pullup": ("stand",
        "Add a high horizontal pull-up bar at the top of the image. Change his pose: he "
        "hangs from the bar gripping it with both hands, elbows bent pulling his body up, "
        "chin near the bar, both feet off the floor, knees slightly bent."),
    "hanging-leg-raise": ("stand",
        "Add a high horizontal pull-up bar at the top of the image. Change his pose: he "
        "hangs from the bar with both arms straight, and lifts both legs together "
        "straight forward up to hip height, feet off the floor."),
    "pallof-press": ("stand",
        "Add a tall vertical cable column on the right edge of the image. Change his "
        "pose: standing upright sideways, he holds a cable handle with both hands, arms "
        "extended straight forward at chest height, the cable running horizontally from "
        "his hands to the column."),
    "triceps-pushdown": ("stand",
        "Add a tall vertical cable column on the right edge of the image. Change his "
        "pose: standing facing the column, elbows pinned at his sides and bent, both "
        "hands gripping a short horizontal bar attached to a cable coming down from the "
        "top of the column, pushing the bar down toward his thighs."),
    "lat-pulldown": ("stand",
        "Change the scene: he now sits at a lat pulldown machine, gripping a wide bar "
        "overhead with both hands, the bar attached to a cable running up to the top of "
        "the machine, pulling the bar down toward his upper chest, knees under the pad."),
    "nordic-curl": ("stand",
        "Change his pose: he kneels on the mat with his shins flat on the mat and his "
        "ankles held down, body leaning forward from the knees in one straight line from "
        "knees to head, arms crossed over his chest."),
    "dips": ("stand",
        "Add two parallel dip bars. Change his pose: he supports himself between the "
        "bars, both hands gripping them, arms straight, body upright, both feet off the "
        "floor, knees bent back."),
    "box-jump": ("stand",
        "Add a sturdy dark plyometric box on the mat. Change his pose: he stands on top "
        "of the box, knees slightly bent, arms swung back, having just landed a jump."),
    "bulgarian-split-squat": ("stand_db",
        "Add a low flat dark bench behind him. Change his pose: his back foot rests on "
        "the bench with the shoelaces down, front leg bent about 90 degrees in a deep "
        "split squat, torso upright, one dumbbell in each hand with arms hanging straight."),
    "pushup-incline-chair": ("plank",
        "Add a sturdy chair. Change his pose: his hands now rest on the seat of the "
        "chair, arms straight, body in one straight inclined line from head to heels, "
        "feet on the mat."),
}

# lateral-raise : vue de FACE obligatoire (plan frontal) — paire A/B dédiée
LATERAL_A = ("stand_db",
    "He turns to face the viewer: standing fully upright FACING FORWARD toward the "
    "viewer, feet shoulder-width apart flat on the mat, one dumbbell in each hand, "
    "arms hanging straight down at his sides.")
LATERAL_B = ("Change his pose: still facing the viewer, he raises both straight arms out "
             "to the sides up to shoulder height, one dumbbell in each hand, forming a T shape.")

# restyle homme du forearm-plank FLUX validé (pilote)
FP_SRC = pathlib.Path("ai-explo/pilot-flux/forearm-plank_cannypro_r2_s2025.png")
FP_RESTYLE = ("Make the person a man with short dark hair, wearing a fitted white t-shirt, "
              "navy blue pants and sneakers. Make the mat dark navy and the background plain "
              "light mauve-gray. Keep the exact same forearm plank pose, same flat vector "
              "illustration style.")


def run():
    done, fail = 0, 0
    for slug, (a_key, prompt) in BATCH.items():
        dest = OUT / f"B_{slug}.png"
        if dest.exists():
            continue
        if kontext(str(A[a_key]), str(dest), prompt):
            done += 1
        else:
            fail += 1
        time.sleep(2)
    # lateral-raise (2 étapes)
    la = OUT / "A_m_stand_db_front.png"
    if not la.exists():
        kontext(str(A[LATERAL_A[0]]), str(la), LATERAL_A[1])
        time.sleep(2)
    lb = OUT / "B_lateral-raise.png"
    if la.exists() and not lb.exists():
        kontext(str(la), str(lb), LATERAL_B)
        time.sleep(2)
    # forearm-plank homme (restyle du FLUX validé)
    fp = OUT / "B_forearm-plank.png"
    if not fp.exists():
        kontext(str(FP_SRC), str(fp), FP_RESTYLE)
    # dédups / copies directes
    if not (OUT / "B_goblet-squat.png").exists():
        shutil.copy("ai-explo/planche/goblet_squat_kontext2.png", OUT / "B_goblet-squat.png")
    if not (OUT / "B_plank.png").exists():
        shutil.copy(A["plank"], OUT / "B_plank.png")
    print(f"BATCH MUSCU : {done} générés, {fail} échecs", flush=True)


if __name__ == "__main__":
    run()
