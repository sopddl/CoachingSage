import pathlib
import sys

sys.path.insert(0, ".")
from kontext_edit import kontext

# Itération cal2 (07-12) — fusion gate EXPERT (forme) + gate UX (corps/rendu).
# Clé : la réf a des membres LISSES SANS définition musculaire → viser « flat »,
# pas « athletic » (qui induit le biais muscle). + fixes de pose doctrinaux.

V = pathlib.Path("ai-explo/vague4")
# Suffixe corps = coller au style de réf : membres plats, sans relief musculaire.
FLAT = (" Draw his arms, forearms and torso completely SMOOTH and FLAT with NO "
        "muscle definition at all — no biceps bulge, no triceps, no forearm lines "
        "or veins, just simple flat limbs like an ordinary non-muscular person. "
        "Keep the exact same minimalist flat-vector style with soft flat colors and "
        "NO thick black cartoon outlines, same white t-shirt with short sleeves, "
        "same navy trousers, same navy/grey sneakers, same equipment.")

JOBS = [
    # cable-row : forme OK, seul le corps est trop musclé → aplatir
    (V / "M_cable-row_cal.png", V / "M_cable-row_cal2.png",
     "Small correction: remove all the muscle definition on his arms and chest." + FLAT),
    # hanging : forme OK ; débardeur→t-shirt + chaussures vertes→marine
    (V / "M_hanging-leg-raise_cal.png", V / "M_hanging-leg-raise_cal2.png",
     "Small correction: replace his tank top with a fitted WHITE T-SHIRT WITH SHORT "
     "SLEEVES, and make BOTH his shoes navy blue (no green shoe)." + FLAT),
    # rdl : forme + dos plat OK ; style parti en contour cartoon → re-flat
    (V / "M_rdl-dumbbell_cal.png", V / "M_rdl-dumbbell_cal2.png",
     "Small correction: redraw him in clean FLAT-VECTOR style — remove the thick "
     "black cartoon outlines around his face, hair and arms, use soft flat colors "
     "with only a light shadow, exactly like the reference character." + FLAT),
    # kb-swing : forme KO (1 main + fente) + corps trop musclé
    (V / "M_kb-swing_cal.png", V / "M_kb-swing_cal2.png",
     "Small correction: BOTH of his hands grip the kettlebell handle together, both "
     "arms straight; and plant BOTH feet parallel side by side shoulder-width apart "
     "on the floor, NOT staggered. Neutral calm face, no smile." + FLAT),
    # leg-extension : genou fléchi + tibia au-dessus → tendre
    (V / "M_leg-extension_cal.png", V / "M_leg-extension_cal2.png",
     "Small correction: STRAIGHTEN his knee at the top of the movement so the shin "
     "is in a straight line with the thigh — the leg fully extended forward, the "
     "foot at the SAME height as the knee, NOT raised above it." + FLAT),
    # dead-bug : pas tabletop → 90/90 + bras arrière + jambe opposée
    (V / "M_dead-bug_cal.png", V / "M_dead-bug_cal2.png",
     "Small correction: bend BOTH his hips and knees to 90 degrees so his thighs "
     "are vertical and his shins horizontal (tabletop). Then extend ONE arm back "
     "over his head along the floor and the OPPOSITE leg straight out near the "
     "floor, keeping the other arm and leg in tabletop. Simplify his raised hand "
     "to a simple rounded shape with no individual fingers." + FLAT),
]

if __name__ == "__main__":
    for src, dest, prompt in JOBS:
        kontext(src, dest, prompt)
    print("CAL2 TERMINÉE", flush=True)
