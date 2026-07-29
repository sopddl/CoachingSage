from PIL import Image, ImageDraw

# Controle Garbha Pindasana, vue de profil : boule assise en equilibre sur les
# ischions, genoux hauts en lotus, bras PASSE dans l'interstice cuisse/mollet,
# main remontant vers l'oreille. Texte-seul KO (le modele lit "embryo/womb"
# comme une grossesse, 2/3 seeds) -> squelette + canny, prompt geometrique.

W = H = 1024
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)
STROKE = 56

def thick_line(p1, p2, color):
    d.line([p1, p2], fill=color, width=STROKE)
    for p in (p1, p2):
        d.ellipse([p[0]-STROKE/2, p[1]-STROKE/2, p[0]+STROKE/2, p[1]+STROKE/2], fill=color)

GROUND_Y = 830

# assise : bassin au sol
HIP = (560, 770)

# tronc arrondi vers l'arriere (2 segments pour suggerer le dos rond)
MID = (585, 610)
SHOULDER = (565, 470)
thick_line(HIP, MID, "black")
thick_line(MID, SHOULDER, "black")
HEAD_R = 55
d.ellipse([SHOULDER[0]-HEAD_R-35, SHOULDER[1]-HEAD_R*2-5,
           SHOULDER[0]+HEAD_R-35, SHOULDER[1]-5], fill="black")   # tete legerement rentree

# jambes en lotus RELEVEES (genou haut devant la poitrine, tibia croise replie)
KNEE = (400, 545)
thick_line(HIP, KNEE, "#3f8f5c")                 # cuisse relevee
thick_line(KNEE, (505, 640), "#3f8f5c")          # tibia replie vers le corps
d.line([(505, 640), (560, 620)], fill="#2a6b44", width=34)  # pied sur la cuisse opposee
# 2e genou suggere derriere (plus sombre, leger decalage)
thick_line((575, 745), (430, 580), "#2a6b44")

# bras PASSE dans l'interstice cuisse/mollet : epaule -> coude qui ressort
# sous le tibia -> avant-bras qui REMONTE devant le tibia -> main a l'oreille
thick_line(SHOULDER, (455, 610), "#c65a37")      # humerus plonge dans l'interstice
thick_line((455, 610), (475, 445), "#c65a37")    # avant-bras remonte devant le genou
d.ellipse([458, 408, 502, 452], fill="#c65a37")  # main pres de l'oreille

# sol
for x in range(20, W-20, 24):
    d.line([(x, GROUND_Y+30), (x+12, GROUND_Y+30)], fill="#cccccc", width=3)

img.save("puppet_triceps/_garbha_control.png")
print("OK — puppet_triceps/_garbha_control.png")
