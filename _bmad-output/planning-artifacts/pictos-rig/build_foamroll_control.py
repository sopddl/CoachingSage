from PIL import Image, ImageDraw
import math

# Squelette de controle simple pour foam-rolling-legs : assise droite jambes
# tendues, PETIT rouleau isole sous la cheville seulement (pas sous le bassin).
# Meme convention visuelle que downdog_control.png (segments epais colores,
# joints ronds, fond blanc) pour rester dans la meme famille de recette
# flux-canny-pro (cf pilot_flux.py, deja teste sur des poses refractaires).

W = H = 1024
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)

STROKE = 42
JOINT_R = 26

def thick_line(p1, p2, color):
    d.line([p1, p2], fill=color, width=STROKE)
    for p in (p1, p2):
        d.ellipse([p[0]-STROKE/2, p[1]-STROKE/2, p[0]+STROKE/2, p[1]+STROKE/2], fill=color)

GROUND_Y = 820
HIP = (330, 760)
SHOULDER = (365, 430)
HAND = (250, 780)          # bras d'appui droit vers le sol, derriere/a cote du bassin
ANKLE = (760, 800)
TOE = (830, 815)

# jambe tendue (vert), bassin -> cheville -> orteils
thick_line(HIP, ANKLE, "#3f8f5c")
thick_line(ANKLE, TOE, "#3f8f5c")

# tronc (noir), bassin -> epaule
thick_line(HIP, SHOULDER, "black")
# tete
HEAD_R = 60
d.ellipse([SHOULDER[0]-HEAD_R+10, SHOULDER[1]-HEAD_R*2+10,
           SHOULDER[0]+HEAD_R+10, SHOULDER[1]+10], fill="black")

# bras d'appui (orange), epaule -> main au sol
thick_line(SHOULDER, HAND, "#c65a37")

# rouleau : petit cylindre ISOLE sous la cheville uniquement (pas sous le bassin)
roll_cx, roll_cy = ANKLE[0] - 10, GROUND_Y + 10
roll_w, roll_h = 140, 70
d.ellipse([roll_cx-roll_w/2, roll_cy-roll_h/2, roll_cx+roll_w/2, roll_cy+roll_h/2],
          fill="#9a9a9a", outline="#6b6b6b", width=4)

# sol
for x in range(20, W-20, 24):
    d.line([(x, GROUND_Y+55), (x+12, GROUND_Y+55)], fill="#cccccc", width=3)

img.save("puppet_triceps/_foamroll_control.png")
print("OK — puppet_triceps/_foamroll_control.png")
