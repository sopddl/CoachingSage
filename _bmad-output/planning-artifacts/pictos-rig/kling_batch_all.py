import pathlib
import sys
import time

sys.path.insert(0, ".")
from kling_animate import STYLE, kling

# ÉLARGISSEMENT ANIMATIONS À TOUT LE CATALOGUE VALIDÉ (Sophie 07-13 : « je veux tous les exos »).
# Leçons Kling appliquées : reps = départ DEBOUT ou retour debout MARTELÉ ; tenues =
# « HOLDS, never … , only chest rises » ; amplitude dans l'image de départ ; membre
# occulté jamais animé ; équilibres = perfectly still. Reprise : skip si mp4 existe.

M = pathlib.Path("ai-explo/muscu")
B = pathlib.Path("ai-explo/batch")
V4 = pathlib.Path("ai-explo/vague4")

BATCH = {
    # ---------- MUSCU (7 restants) ----------
    "back-squat": (M / "B_back-squat_v2.png",
        "The man stands up COMPLETELY from the squat with the barbell on his shoulders until "
        "he is fully upright, then slowly squats all the way back down. FULL RANGE squat "
        "repetitions, large visible movement." + STYLE),
    "squat-bodyweight": (M / "A_m_stand.png",
        "The man slowly squats all the way down, bending his knees and hips while his arms "
        "extend forward for balance, then stands back up fully upright. Two slow FULL "
        "bodyweight squats." + STYLE),
    "triceps-overhead": (M / "B_triceps-overhead_v2.png",
        "The man slowly extends his arms straight up overhead holding the dumbbell, then "
        "bends his elbows lowering it back behind his head. Slow controlled overhead "
        "triceps extensions, only the forearms move." + STYLE),
    "deadlift-conventional": (M / "B_deadlift-conventional_v2.png",
        "The man stands up COMPLETELY, lifting the barbell from the floor up along his legs "
        "until he is fully upright with the bar at his thighs, then lowers it back to the "
        "floor with a FLAT back. Full deadlift repetitions." + STYLE),
    "arnold-press-seated": (M / "B_arnold-press-seated_fix.png",
        "Seated on the bench, the man slowly presses both dumbbells up overhead until his "
        "arms are straight, then lowers them back to shoulder height. Slow controlled "
        "seated press repetitions." + STYLE),
    "bulgarian-split-squat": (M / "B_bulgarian-split-squat_v2.png",
        "The man pushes up FULLY straightening his front leg, his rear foot staying on the "
        "bench, until he stands tall, then lowers slowly back into the deep split squat. "
        "Full repetitions with a clear rise between each." + STYLE),
    "lateral-raise": (M / "B_lateral-raise_fix3.png",
        "The man slowly lowers both dumbbells down to his sides with straight arms, then "
        "raises them back up to shoulder height. Slow controlled lateral raise repetitions, "
        "BOTH arms move together." + STYLE),
    # ---------- VAGUE 4 (9) ----------
    "plank-m": (V4 / "M_plank_pilote3.png",
        "The man HOLDS the high plank perfectly still, his body in one straight line, "
        "breathing calmly — only his chest rises and falls. He HOLDS the position, never "
        "moves, never kneels, never pikes." + STYLE),
    "pushup": (V4 / "M_pushup_ath4.png",
        "The man slowly pushes up until his arms are straight, keeping his body in a rigid "
        "straight line, then lowers back down until his chest hovers just above the mat. "
        "Two slow FULL push-up repetitions." + STYLE),
    "wall-sit": (V4 / "M_wall-sit_ath2.png",
        "The man HOLDS the wall sit perfectly still, his back pressed against the wall, "
        "thighs steady, breathing calmly — only his chest rises. He HOLDS, he never stands "
        "up and never slides down." + STYLE),
    "box-jump": (V4 / "M_box-jump_ath.png",
        "The man absorbs the landing by bending his knees a little deeper, then slowly "
        "stands up tall and stable on top of the box, arms lowering to his sides." + STYLE),
    "facepull": (V4 / "M_facepull_ath.png",
        "The man pulls the rope attachment toward his face, elbows driving high and wide, "
        "then extends his arms back toward the pulley. Slow controlled face pull "
        "repetitions, only the arms move." + STYLE),
    "bench-press": (V4 / "M_bench-press_ath.png",
        "Lying on the bench, the man slowly lowers the barbell down to his chest, then "
        "presses it back up to straight arms. Slow controlled bench press repetitions." + STYLE),
    "rdl-dumbbell": (V4 / "M_rdl-dumbbell_pilote2.png",
        "The man stands up COMPLETELY straight, the dumbbell sliding up along his legs, his "
        "back staying FLAT, then hinges back down pushing his hips far back. Full Romanian "
        "deadlift repetitions with a clear return to standing." + STYLE),
    "kb-swing": (V4 / "L_kb-swing_1.png",
        "The man swings the kettlebell forward and up to chest height with straight arms as "
        "his hips snap forward to FULL standing, then the kettlebell swings back down "
        "between his legs as he hinges. Two full kettlebell swings, he stands completely "
        "upright at the top of each swing." + STYLE),
    "leg-extension": (V4 / "M_leg-extension_regen8.png",
        "Seated on the machine, the man slowly lets his foot lower as his knee bends against "
        "the padded roller, then extends the leg back up to horizontal. Slow controlled leg "
        "extension repetitions, only the lower leg moves." + STYLE),
    # ---------- YOGA / CORE (20) ----------
    "tadasana": (B / "B_tadasana.png",
        "The woman stands tall in mountain pose, perfectly still and grounded, breathing "
        "slowly — her shoulders soften down and her chest gently rises and falls." + STYLE),
    "easy-pose": (B / "B_easy-pose.png",
        "The woman sits in easy cross-legged pose, perfectly still, breathing slowly and "
        "calmly — only her chest and shoulders gently rise and fall. She HOLDS the pose." + STYLE),
    "seated-forward-fold": (B / "B_seated-forward-fold.png",
        "The woman gently deepens her seated forward fold with a slow exhale, sliding her "
        "hands slightly further, then holds, breathing calmly. She STAYS folded over her "
        "legs, never sits up." + STYLE),
    "downward-dog": (B / "B_downward-dog.png",
        "The woman HOLDS downward dog steady, pressing her heels gently toward the mat and "
        "lengthening her spine, breathing calmly. She HOLDS the pose, never walks, never "
        "lowers to the floor." + STYLE),
    "forward-fold": (B / "B_forward-fold.png",
        "The woman hangs relaxed in her standing forward fold, deepening very slightly with "
        "each exhale, breathing calmly. She STAYS folded, never stands up." + STYLE),
    "half-moon": (B / "B_half-moon.png",
        "The woman HOLDS half moon balance PERFECTLY STILL, her top arm reaching up, her "
        "lifted leg strong and horizontal, breathing calmly. She NEVER wobbles, never "
        "lowers her leg, never falls." + STYLE),
    "triangle": (B / "B_triangle.png",
        "The woman HOLDS triangle pose steady, reaching her top arm a little higher toward "
        "the ceiling, breathing calmly. She HOLDS the pose, her legs never move." + STYLE),
    "sun-salutation-a": (B / "B_sun-salutation-a.png",
        "The woman softens deeper into her standing forward fold with a slow exhale, then "
        "holds, breathing calmly. She STAYS folded, never stands up." + STYLE),
    "sun-salutation-b": (B / "B_sun-salutation-b.png",
        "The woman settles a little deeper into the pose, then HOLDS it steady, breathing "
        "calmly and deeply — only her chest rises. Her feet never move." + STYLE),
    "hands-under-feet": (B / "B_hands-under-feet.png",
        "The woman holds the deep forward fold with her hands under her feet, softening a "
        "little deeper with each exhale, breathing calmly. She STAYS folded." + STYLE),
    "marichyasana-a": (B / "B_marichyasana-a.png",
        "The woman gently deepens the seated fold with an exhale, then holds, breathing "
        "calmly. She HOLDS the pose, her legs never move." + STYLE),
    "side-angle": (B / "B_side-angle.png",
        "The woman HOLDS extended side angle steady, reaching her top arm long over her "
        "ear, breathing calmly. Her legs and feet never move." + STYLE),
    "pyramid": (B / "B_pyramid.png",
        "The woman softens a little deeper over her front leg in pyramid pose with an "
        "exhale, then holds, breathing calmly. Her feet never move, she stays folded." + STYLE),
    "embryo": (B / "B_embryo.png",
        "The woman rests curled in the pose, perfectly still and relaxed, breathing slowly "
        "— her back gently rises and falls with each breath. She HOLDS the resting pose." + STYLE),
    "seated-twist": (B / "B_seated-twist.png",
        "The woman gently deepens her seated twist with a slow exhale, then holds, "
        "breathing calmly. Her legs never move, she stays twisted." + STYLE),
    "big-toe-fold": (B / "B_big-toe-fold.png",
        "The woman holds the forward fold gripping her big toes, softening slightly deeper "
        "with each exhale, breathing calmly. She STAYS folded, never stands." + STYLE),
    "forearm-plank": (B / "B_forearm-plank.png",
        "The woman HOLDS the forearm plank perfectly still, her body in one straight line "
        "on her forearms, breathing calmly — only her chest rises. She HOLDS, never "
        "kneels, never pikes, never lifts her hips." + STYLE),
    "plank-f": (B / "B_plank.png",
        "The woman HOLDS the high plank perfectly still, her body in one straight line, "
        "breathing calmly — only her chest rises. She HOLDS, never kneels, never pikes." + STYLE),
    "butterfly": (V4 / "Y_butterfly_s1234.png",
        "The woman sits tall in butterfly pose, her knees bobbing very gently, breathing "
        "calmly. She HOLDS the pose, her feet stay pressed together." + STYLE),
    "foam-rolling-legs": (B / "B_foam-rolling-legs.png",
        "The woman slowly rolls her calves back and forth over the foam roller, shifting "
        "her weight on her hands, in a small gentle massage motion." + STYLE),
}

if __name__ == "__main__":
    todo = {s: sp for s, sp in BATCH.items()
            if not (pathlib.Path("ai-explo/anim") / f"anim_{s}.mp4").exists()}
    print(f"batch animations : {len(todo)}/{len(BATCH)} à générer", flush=True)
    fails = []
    for i, (slug, (src, prompt)) in enumerate(todo.items()):
        assert src.exists(), f"source manquante: {src}"
        if not kling(slug, src, prompt):
            fails.append(slug)
        print(f"[{i + 1}/{len(todo)}] {slug} fait", flush=True)
        time.sleep(3)
    print(f"BATCH TERMINÉ — {len(todo) - len(fails)} ok, fails: {fails}", flush=True)
