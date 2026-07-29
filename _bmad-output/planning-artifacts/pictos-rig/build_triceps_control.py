from PIL import Image, ImageDraw

# Controle simple pour standing overhead triceps extension (French press) :
# bras proche quasi tendu derriere la tete, bras loin plie au coude, meme
# haltere tenu aux 2 mains. Meme convention que _foamroll_control.png
# (segments epais colores, joints ronds, fond blanc) — a nourrir a
# flux-canny-pro puisque le texte seul derive systematiquement vers un
# developpe epaules (2 tentatives, 6 seeds).

W = H = 1024
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)

STROKE = 40

def thick_line(p1, p2, color):
    d.line([p1, p2], fill=color, width=STROKE)
    for p in (p1, p2):
        d.ellipse([p[0]-STROKE/2, p[1]-STROKE/2, p[0]+STROKE/2, p[1]+STROKE/2], fill=color)

GROUND_Y = 960
ANKLE = (500, GROUND_Y)
HIP = (490, 610)
SHOULDER = (470, 380)
DB = (400, 160)          # point de l'haltere, derriere/au-dessus de la tete
FAR_ELBOW = (555, 290)

# jambes (vert) : simplifie en un seul segment hanche->cheville (debout, jambe tendue)
thick_line(HIP, ANKLE, "#3f8f5c")

# tronc (noir)
thick_line(HIP, SHOULDER, "black")
HEAD_R = 55
d.ellipse([SHOULDER[0]-HEAD_R, SHOULDER[1]-HEAD_R*2-10, SHOULDER[0]+HEAD_R, SHOULDER[1]-10], fill="black")

# bras PROCHE (orange) : quasi tendu, epaule -> haltere
thick_line(SHOULDER, DB, "#c65a37")

# bras LOIN (rouge fonce) : plie, epaule -> coude -> haltere (meme point)
thick_line(SHOULDER, FAR_ELBOW, "#8a3a2a")
thick_line(FAR_ELBOW, DB, "#8a3a2a")

# halterte
d.ellipse([DB[0]-45, DB[1]-20, DB[0]+45, DB[1]+20], fill="#555555", outline="#333333", width=4)

# sol
for x in range(20, W-20, 24):
    d.line([(x, GROUND_Y+5), (x+12, GROUND_Y+5)], fill="#cccccc", width=3)

img.save("puppet_triceps/_triceps_control.png")
print("OK — puppet_triceps/_triceps_control.png")
