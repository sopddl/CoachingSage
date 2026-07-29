import pathlib
import sys

sys.path.insert(0, ".")
from kontext_edit import kontext

# Passe finale silhouette vague 4 (07-12) — 3 corrections ciblées après gate 1 pass 2 :
#   plank_ath2   — le 2e bras n'est toujours pas visible (retour Sophie « bras coupé »)
#   kb-swing_ath3 — pieds décalés (un swing = pieds parallèles) + visage sourire anime
#   pushup_ath3  — visage anime détaillé + chaussures type chaussons

V = pathlib.Path("ai-explo/vague4")

if __name__ == "__main__":
    kontext(V / "M_plank_ath2.png", V / "M_plank_ath3.png",
        "Small correction: he supports himself on BOTH arms — draw TWO separate "
        "straight arms clearly visible, the second arm slightly in front of the "
        "first one, with TWO hands flat on the mat next to each other.")
    kontext(V / "M_kb-swing_ath3.png", V / "M_kb-swing_ath4.png",
        "Small correction: both his feet are planted side by side, PARALLEL, "
        "shoulder-width apart on the floor — no staggered walking stance — and "
        "his face is a simple neutral minimal flat-vector profile with a closed "
        "mouth, no smile, no teeth.")
    kontext(V / "M_pushup_ath3.png", V / "M_pushup_ath4.png",
        "Small correction: his face is a simple minimal flat-vector profile with "
        "a tiny simple eye, no detailed shaded eye, and he wears simple navy "
        "sneakers with white soles.")
    print("FIX3 TERMINÉ", flush=True)
