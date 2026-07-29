import pathlib
import sys

sys.path.insert(0, ".")
from kontext_edit import kontext

# Passe CALIBRATION (07-12) — cible = athlétique MODÉRÉ (gabarit muscu canon), pas
# bodybuilder. Corrige la SUR-correction de la passe bulk + défauts pose/cadrage.
# Chaque sortie repasse gate 1 (moi) + gate expert sport + gate UX challenge-corps.

V = pathlib.Path("ai-explo/vague4")
MOD = (" Give him a MODERATE lean athletic build like an average fit adult — normal "
       "shoulders and arms, normal torso and thighs, clearly NOT a bulky bodybuilder, "
       "NOT skinny either. Keep the exact same pose, same white t-shirt with short "
       "sleeves, same equipment, same flat vector style.")

JOBS = [
    # 3 sur-corrigés « trop gros » → redescendre à modéré
    (V / "M_kb-swing_ath4.png", V / "M_kb-swing_cal.png",
     "Small correction: reduce his muscle mass to a moderate lean athletic build, "
     "slimmer arms and torso, and plant BOTH feet parallel side by side "
     "shoulder-width apart, NOT in a staggered walking stance." + MOD),
    (V / "M_cable-row_ath2.png", V / "M_cable-row_cal.png",
     "Small correction: reduce his muscle mass to a moderate lean athletic build, "
     "slimmer arms and chest." + MOD),
    (V / "M_hanging-leg-raise_ath2.png", V / "M_hanging-leg-raise_cal.png",
     "Small correction: reduce his muscle mass to a moderate lean athletic build, "
     "slimmer arms and torso." + MOD),
    # rdl — proportions étirées
    (V / "M_rdl-dumbbell_ath2.png", V / "M_rdl-dumbbell_cal.png",
     "Small correction: fix his body proportions — his legs are too long and his "
     "torso too short. Make his legs SHORTER and his torso a bit LONGER so he looks "
     "normally proportioned, not elongated. Also make the dumbbell a normal smaller "
     "size." + MOD),
    # leg-extension — tibias au-dessus de l'horizontale
    (V / "M_leg-extension_ath.png", V / "M_leg-extension_cal.png",
     "Small correction: LOWER his extended legs so the shins are HORIZONTAL, in line "
     "with his thighs, with his feet at the SAME height as his knees — his lower legs "
     "must NOT be raised above knee level." + MOD),
    # dead-bug — pied coupé au bord du cadre
    (V / "M_dead-bug_ath2.png", V / "M_dead-bug_cal.png",
     "Small correction: make sure his WHOLE body including both feet is fully visible "
     "inside the frame — nothing cropped or cut off at the edges. Pull the figure "
     "slightly in so both feet stay well within the picture." + MOD),
]

if __name__ == "__main__":
    for src, dest, prompt in JOBS:
        kontext(src, dest, prompt)
    print("CALIBRATION TERMINÉE", flush=True)
