from PIL import Image, ImageDraw

# Controle ardha uttanasana (demi-redressement, dos plat) pour l'image de
# DEPART de forward-fold_v3 : Kling s'ancre sur l'image de depart (2 rerolls
# sans mouvement depuis le pli profond) -> on lui donne l'AUTRE extreme,
# comme cat-cow v5 / goblet-squat v3. Kontext a echoue 2x a decoller les
# mains du sol -> squelette + flux-canny (recette validee 3x le 07-15/16).

W = H = 1024
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)
STROKE = 58   # v2 : 40 donnait des membres maigres via canny (KO Sophie r14
              # « trop maigre, trop différente ») — épaissi vers le build catalogue

def thick_line(p1, p2, color):
    d.line([p1, p2], fill=color, width=STROKE)
    for p in (p1, p2):
        d.ellipse([p[0]-STROKE/2, p[1]-STROKE/2, p[0]+STROKE/2, p[1]+STROKE/2], fill=color)

GROUND_Y = 900

# jambe (vert) : cheville -> genou legerement flechi -> hanche
ANKLE = (500, GROUND_Y)
KNEE = (515, 720)
HIP = (545, 545)
thick_line(ANKLE, KNEE, "#3f8f5c")
thick_line(KNEE, HIP, "#3f8f5c")
d.line([(455, GROUND_Y+12), (545, GROUND_Y+12)], fill="#3f8f5c", width=26)  # pied au sol

# dos PLAT horizontal (noir) : hanche -> epaule, parallele au sol
SHOULDER = (330, 525)
thick_line(HIP, SHOULDER, "black")
# tete dans le prolongement de la colonne
HEAD_R = 52
d.ellipse([SHOULDER[0]-HEAD_R*2-25, SHOULDER[1]-HEAD_R-8,
           SHOULDER[0]-25, SHOULDER[1]+HEAD_R-8], fill="black")

# bras (orange) : epaule -> coude -> main posee sur le TIBIA a mi-hauteur
thick_line(SHOULDER, (395, 665), "#c65a37")
thick_line((395, 665), (480, 790), "#c65a37")

# sol
for x in range(20, W-20, 24):
    d.line([(x, GROUND_Y+30), (x+12, GROUND_Y+30)], fill="#cccccc", width=3)

img.save("puppet_triceps/_ff_control.png")
print("OK — puppet_triceps/_ff_control.png")
