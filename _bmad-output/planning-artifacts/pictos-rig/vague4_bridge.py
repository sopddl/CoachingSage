import pathlib
import sys

sys.path.insert(0, ".")
from kontext_edit import kontext

# PONT (07-12) — Sophie : le set canon = gringalet plat cartoon, incohérent avec
# les animations/muscu validés (perso plus humain, volume + ombrage doux).
# Cause : vague4 = FLUX-canny sur rig fil-de-fer maigre (bonnes poses, perso plat) ;
# muscu/anim = kontext depuis base ombrée (bon perso, poses parfois fausses).
# Solution = prendre la BONNE POSE (source _canon) et la RESTYLER au perso muscu
# via kontext (build solide + ombrage). Bon perso + bonne pose enfin réunis.

V4 = pathlib.Path("ai-explo/vague4")
SLUGS = ["plank","pushup","wall-sit","box-jump","facepull","bench-press",
         "cable-row","rdl-dumbbell","kb-swing","hanging-leg-raise",
         "leg-extension","dead-bug"]

RESTYLE = ("Redraw this exact same man in the EXACT same pose and with the same "
           "equipment and setting, but give him a normal solid healthy adult build "
           "with natural body volume — fuller shoulders, chest and thighs, an average "
           "fit physique, clearly NOT thin or scrawny. Render him with SOFT SUBTLE "
           "SHADING and gentle gradients on his white t-shirt, his skin and his navy "
           "pants to give the body depth and volume, in a polished semi-realistic "
           "flat illustration style with NO hard black outlines, short dark hair, "
           "navy sneakers.")

if __name__ == "__main__":
    for slug in SLUGS:
        src = V4 / f"M_{slug}_canon.png"
        assert src.exists(), f"source manquante {src}"
        kontext(src, V4 / f"M_{slug}_bridge.png", RESTYLE)
        print(f"OK — M_{slug}_bridge.png", flush=True)
    print("BRIDGE ALL TERMINÉ", flush=True)
