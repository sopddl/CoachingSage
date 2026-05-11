"""
Generate CoachingSage AppIcon based on FloreSage/GardenSage visual pattern :
- Fond sable iOS #F3EDE2
- Anneau or extérieur (stroke #D4A85A width 36)
- Cercle central rempli avec la mosaïque 6 sports (clippée en disque)
- Sigil Sage bottom-right (étoile 4 branches + cercle doré central)
"""
from PIL import Image, ImageDraw, ImageFilter

SRC = "/Users/sophieslama/Downloads/CoachingSage-icon-mosaique-1024.png"

# Output 3 variants
OUT_LIGHT = "/Users/sophieslama/CL3/CoachingSage/Resources/Brand/coachingsage-icon-light.png"
OUT_DARK = "/Users/sophieslama/CL3/CoachingSage/Resources/Brand/coachingsage-icon-dark.png"
OUT_TINTED = "/Users/sophieslama/CL3/CoachingSage/Resources/Brand/coachingsage-icon-tinted.png"

SIZE = 1024
CX = CY = 478  # même centre que GardenSage (légèrement décalé)
R_OUTER = 400  # anneau extérieur radius
R_DISC = 320   # cercle central radius (mosaïque)
RING_WIDTH = 36
SIGIL_CX, SIGIL_CY = 740, 740
SIGIL_R = 78


def build(background_color, label):
    canvas = Image.new("RGBA", (SIZE, SIZE), background_color)
    draw = ImageDraw.Draw(canvas)

    # Load mosaic image and resize to fit INSIDE the disc (carré inscrit dans
    # le cercle de rayon R_DISC → côté ~= R_DISC * sqrt(2) pour que les emojis
    # des coins ne soient pas trop rognés, on prend 2 * R_DISC pour inscrire
    # le cercle DANS la mosaïque puis on accepte que les COINS de la mosaïque
    # soient coupés par le clip).
    mosaic_size = 2 * R_DISC  # 640px : la mosaïque pleine s'inscrit, les coins du carré dépassent et sont clippés
    mosaic = Image.open(SRC).convert("RGBA").resize((mosaic_size, mosaic_size), Image.LANCZOS)

    # Rotation légère vers la gauche (Sophie 2026-05-11) — donne du dynamisme.
    # PIL rotate angle positif = anti-horaire = "vers la gauche".
    mosaic = mosaic.rotate(10, resample=Image.BICUBIC, expand=False)

    # Position the mosaic centered on (CX, CY)
    mosaic_x = CX - mosaic_size // 2
    mosaic_y = CY - mosaic_size // 2

    # Build circular mask for the mosaic (centered on (CX, CY) radius R_DISC)
    mask = Image.new("L", (SIZE, SIZE), 0)
    mdraw = ImageDraw.Draw(mask)
    mdraw.ellipse(
        (CX - R_DISC, CY - R_DISC, CX + R_DISC, CY + R_DISC),
        fill=255,
    )

    # Composite mosaic onto canvas through the circular mask
    canvas.paste(mosaic, (mosaic_x, mosaic_y), mask.crop((mosaic_x, mosaic_y, mosaic_x + mosaic_size, mosaic_y + mosaic_size)))

    # Gold outer ring (drawn AFTER the mosaic so it's on top)
    # Use a thicker outline by drawing two concentric ellipses
    ring_color = (212, 168, 90, 255)  # #D4A85A
    bbox_out = (CX - R_OUTER, CY - R_OUTER, CX + R_OUTER, CY + R_OUTER)
    draw.ellipse(bbox_out, outline=ring_color, width=RING_WIDTH)

    # Sigil Sage bottom-right — circle white + 4-branch star + golden dot
    # Outer disc cream
    draw.ellipse(
        (SIGIL_CX - SIGIL_R, SIGIL_CY - SIGIL_R,
         SIGIL_CX + SIGIL_R, SIGIL_CY + SIGIL_R),
        fill=(243, 237, 226, 255),
    )
    # Inner disc white
    draw.ellipse(
        (SIGIL_CX - 74, SIGIL_CY - 74, SIGIL_CX + 74, SIGIL_CY + 74),
        fill=(255, 255, 255, 255),
    )
    # 4-branch star — earth color #5C5248
    star_color = (92, 82, 72, 255)
    # Star path : pointed N/S/E/W with thin waist
    star_points = [
        (SIGIL_CX, SIGIL_CY - 55),
        (SIGIL_CX + 2, SIGIL_CY - 7),
        (SIGIL_CX + 55, SIGIL_CY),
        (SIGIL_CX + 2, SIGIL_CY + 7),
        (SIGIL_CX, SIGIL_CY + 55),
        (SIGIL_CX - 2, SIGIL_CY + 7),
        (SIGIL_CX - 55, SIGIL_CY),
        (SIGIL_CX - 2, SIGIL_CY - 7),
    ]
    draw.polygon(star_points, fill=star_color)
    # Golden dot center
    draw.ellipse(
        (SIGIL_CX - 6, SIGIL_CY - 6, SIGIL_CX + 6, SIGIL_CY + 6),
        fill=(212, 168, 90, 255),
    )
    draw.ellipse(
        (SIGIL_CX - 3, SIGIL_CY - 3, SIGIL_CX + 3, SIGIL_CY + 3),
        fill=(240, 200, 122, 255),
    )

    return canvas


def main():
    # Light variant — fond sable iOS
    light = build((243, 237, 226, 255), "Light")
    light.save(OUT_LIGHT)
    print(f"Wrote {OUT_LIGHT}")

    # Dark variant — fond noir profond
    dark = build((15, 22, 32, 255), "Dark")
    dark.save(OUT_DARK)
    print(f"Wrote {OUT_DARK}")

    # Tinted variant : convert Light en grayscale puis ajouter une opacité homogène
    tinted = light.convert("RGBA")
    # Use luminance keeping RGBA
    grayscale = tinted.convert("L").convert("RGBA")
    grayscale.save(OUT_TINTED)
    print(f"Wrote {OUT_TINTED}")


if __name__ == "__main__":
    main()
