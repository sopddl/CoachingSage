from PIL import Image, ImageDraw

# Phase 2 cloture : squelettes de controle pour les 3 statiques defectueuses
# EN PROD (bodycheck 07-16) :
# - plank.png : cheville avant cassee a 90 deg (chaussure a plat vers l'avant)
# - forearm-plank.png : l'avant-bras d'appui ne touche pas le sol
# - half-moon.png : pied de la jambe levee difforme (moufle)
# Recette squelette+canny validee 4x (foam-rolling, triceps, marichyasana, ff).

W = H = 1024
STROKE = 56

def new():
    img = Image.new("RGB", (W, H), "white")
    return img, ImageDraw.Draw(img)

def thick_line(d, p1, p2, color, s=STROKE):
    d.line([p1, p2], fill=color, width=s)
    for p in (p1, p2):
        d.ellipse([p[0]-s/2, p[1]-s/2, p[0]+s/2, p[1]+s/2], fill=color)

def ground(d, y):
    for x in range(20, W-20, 24):
        d.line([(x, y), (x+12, y)], fill="#cccccc", width=3)

# ---------- 1. PLANK haute (homme) : ligne droite epaules->talons, appui mains + orteils
img, d = new()
GY = 780
SHOULDER = (330, 480)
HIP = (560, 545)
ANKLE = (790, 640)
# tronc + jambes en ligne
thick_line(d, SHOULDER, HIP, "black")
thick_line(d, HIP, ANKLE, "#3f8f5c")
# pied : orteils replies au sol, TALON LEVE (le defaut prod = pied a plat)
thick_line(d, ANKLE, (830, 745), "#3f8f5c", 40)   # avant-pied vers le sol
# bras vertical epaule->main au sol
thick_line(d, SHOULDER, (330, 745), "#c65a37")
d.line([(300, 762), (390, 762)], fill="#c65a37", width=26)  # main a plat
# tete dans le prolongement
HEAD_R = 50
d.ellipse([SHOULDER[0]-HEAD_R*2-30, SHOULDER[1]-HEAD_R-45,
           SHOULDER[0]-30, SHOULDER[1]+HEAD_R-45], fill="black")
ground(d, GY)
img.save("puppet_triceps/_plank_control.png")

# ---------- 2. FOREARM PLANK (femme) : coude SOUS l'epaule, avant-bras A PLAT au sol
img, d = new()
GY = 780
SHOULDER = (350, 500)
HIP = (580, 555)
ANKLE = (800, 645)
thick_line(d, SHOULDER, HIP, "black")
thick_line(d, HIP, ANKLE, "#3f8f5c")
thick_line(d, ANKLE, (838, 748), "#3f8f5c", 40)   # orteils replies, talon leve
# bras : epaule -> coude au sol SOUS l'epaule -> avant-bras HORIZONTAL a plat vers l'avant
thick_line(d, SHOULDER, (350, 740), "#c65a37")
thick_line(d, (350, 740), (215, 748), "#c65a37", 46)  # avant-bras A PLAT sur le sol
HEAD_R = 48
d.ellipse([SHOULDER[0]-HEAD_R*2-25, SHOULDER[1]-HEAD_R-40,
           SHOULDER[0]-25, SHOULDER[1]+HEAD_R-40], fill="black")
ground(d, GY)
img.save("puppet_triceps/_forearmplank_control.png")

# ---------- 3. HALF-MOON (femme) : debout sur une jambe, l'autre a l'horizontale,
# un bras vers le sol, un bras vers le ciel ; pied leve NET (talon + orteils)
img, d = new()
GY = 870
FOOT = (500, GY)
KNEE = (505, 700)
HIP = (515, 545)
thick_line(d, FOOT, KNEE, "#3f8f5c")
thick_line(d, KNEE, HIP, "#3f8f5c")
d.line([(455, GY+12), (555, GY+12)], fill="#3f8f5c", width=26)  # pied au sol
# jambe levee horizontale vers la droite, pied flechi (talon en bas, orteils a droite)
thick_line(d, HIP, (790, 520), "#2a6b44")
thick_line(d, (790, 520), (805, 455), "#2a6b44", 40)  # pied flechi vertical
# tronc horizontal vers la gauche
SHOULDER = (330, 520)
thick_line(d, HIP, SHOULDER, "black")
HEAD_R = 48
d.ellipse([SHOULDER[0]-HEAD_R*2-20, SHOULDER[1]-HEAD_R-15,
           SHOULDER[0]-20, SHOULDER[1]+HEAD_R-15], fill="black")
# bras bas : epaule -> main vers le sol (au-dessus du sol)
thick_line(d, SHOULDER, (335, 790), "#c65a37")
# bras haut : epaule -> main vers le ciel
thick_line(d, SHOULDER, (325, 250), "#8a3a2a")
ground(d, GY)
img.save("puppet_triceps/_halfmoon_control.png")

print("OK — 3 controles ecrits")
