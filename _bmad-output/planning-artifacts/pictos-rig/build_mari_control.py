from PIL import Image, ImageDraw

# Controle Marichyasana A (variante preparation documentee : assise droite,
# genou plie releve pied proche de la fesse, jambe tendue devant pied flechi,
# bras cote genou qui enlace/tient le tibia, autre main au sol derriere).
# Vue de PROFIL (face a gauche) — la vue 3/4 dos de l'image originale rendait
# la jambe tendue invisible, cause racine du FAIL source. Meme convention que
# _foamroll_control.png / _triceps_control.png (recette flux-canny validee 2x).

W = H = 1024
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)
STROKE = 40

def thick_line(p1, p2, color):
    d.line([p1, p2], fill=color, width=STROKE)
    for p in (p1, p2):
        d.ellipse([p[0]-STROKE/2, p[1]-STROKE/2, p[0]+STROKE/2, p[1]+STROKE/2], fill=color)

GROUND_Y = 800
HIP = (560, 760)
SHOULDER = (595, 470)   # v2 : tronc un peu plus court

# jambe TENDUE devant (vert) : hanche -> genou -> cheville a plat sur le sol, pied flechi orteils vers le haut
thick_line(HIP, (350, 785), "#3f8f5c")
thick_line((350, 785), (180, 790), "#3f8f5c")
thick_line((180, 790), (165, 732), "#3f8f5c")   # pied flechi, pointe vers le haut

# jambe PLIEE genou vers le ciel : hanche -> genou HAUT -> cheville redescend,
# pied a plat PROCHE de la fesse (v2 : longueurs cuisse/tibia ~egales a la jambe tendue)
thick_line(HIP, (478, 548), "#2a6b44")
thick_line((478, 548), (448, 772), "#2a6b44")
d.line([(415, 795), (485, 795)], fill="#2a6b44", width=30)  # pied a plat au sol

# tronc droit (noir), hanche -> epaule + tete
thick_line(HIP, SHOULDER, "black")
HEAD_R = 55
d.ellipse([SHOULDER[0]-HEAD_R-20, SHOULDER[1]-HEAD_R*2-15, SHOULDER[0]+HEAD_R-20, SHOULDER[1]-15], fill="black")

# bras AVANT (orange) : epaule -> coude -> main qui tient le tibia du genou plie
thick_line(SHOULDER, (505, 590), "#c65a37")
thick_line((505, 590), (452, 650), "#c65a37")

# bras ARRIERE (rouge fonce) : epaule -> coude -> main au sol derriere la hanche
# (v2 : raccourci, il faisait 2x le bras avant)
thick_line(SHOULDER, (655, 605), "#8a3a2a")
thick_line((655, 605), (685, 775), "#8a3a2a")

# sol
for x in range(20, W-20, 24):
    d.line([(x, GROUND_Y+15), (x+12, GROUND_Y+15)], fill="#cccccc", width=3)

img.save("puppet_triceps/_mari_control.png")
print("OK — puppet_triceps/_mari_control.png")
