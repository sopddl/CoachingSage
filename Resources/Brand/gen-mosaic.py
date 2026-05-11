"""
Génère la mosaïque source CoachingSage option D (validée Sophie 2026-05-11) :
- Layout 3 col × 2 lignes
- Course + Muscu en positions centrales (colonne du milieu)
- Natation remplace Football
- 6e cellule = Randonnée
- Fonds couleur sport (matching Color.coachingSport(forCode:))
- Emojis Apple rendus en couleur via PIL embedded_color
"""
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
COLS = 3
ROWS = 2
CELL_W = SIZE // COLS  # 341
CELL_H = SIZE // ROWS  # 512

EMOJI_FONT = "/System/Library/Fonts/Apple Color Emoji.ttc"
EMOJI_NATIVE_SIZE = 160  # taille bitmap dispo dans AppleColorEmoji
EMOJI_TARGET = 380       # ×1.36 vs 280 — Sophie 2026-05-11 : encore plus grand (limite largeur cellule 341)

# Layout option D :
# col0 = Natation,  col1 = Course,  col2 = Vélo
# col0 = Yoga,      col1 = Muscu,   col2 = Randonnée
CELLS = [
    # (col, row, emoji, bg_color hex)
    (0, 0, "🥾", "#4A7044"),                 # randonnée (était natation)
    (1, 0, "🏃‍♀️", "#C8913A"),   # course
    (2, 0, "🚴‍♀️", "#2D8A4E"),   # vélo
    (0, 1, "🧘‍♀️", "#0F1620"),   # yoga
    (1, 1, "🏋️‍♀️", "#8C4A2E"),  # muscu
    (2, 1, "🏊‍♀️", "#1B3A5C"),   # natation (était randonnée)
]

OUT = "/Users/sophieslama/CL3/CoachingSage/Resources/Brand/coachingsage-mosaic-source.png"


def hex_to_rgba(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)


def render_emoji(emoji_text):
    """Render an emoji at native AppleColorEmoji bitmap size into a transparent
    image, then resize to EMOJI_TARGET. Returns RGBA Image."""
    font = ImageFont.truetype(EMOJI_FONT, size=EMOJI_NATIVE_SIZE)
    # Padding suffisant pour ne pas clipper
    pad = 20
    tmp = Image.new("RGBA", (EMOJI_NATIVE_SIZE + pad * 2, EMOJI_NATIVE_SIZE + pad * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(tmp)
    draw.text((pad, pad), emoji_text, embedded_color=True, font=font)
    # Crop to non-transparent bbox to remove extra space
    bbox = tmp.getbbox()
    if bbox:
        tmp = tmp.crop(bbox)
    # Resize to target keeping aspect ratio (UP or DOWN — vs thumbnail qui ne fait QUE downscale)
    w, h = tmp.size
    scale = EMOJI_TARGET / max(w, h)
    new_size = (int(w * scale), int(h * scale))
    tmp = tmp.resize(new_size, Image.LANCZOS)
    return tmp


def main():
    canvas = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
    draw = ImageDraw.Draw(canvas)

    for col, row, emoji, bg_hex in CELLS:
        x0 = col * CELL_W
        y0 = row * CELL_H
        x1 = x0 + CELL_W
        y1 = y0 + CELL_H
        draw.rectangle((x0, y0, x1, y1), fill=hex_to_rgba(bg_hex))

        # Render emoji
        em = render_emoji(emoji)
        ew, eh = em.size
        # Center in cell
        ex = x0 + (CELL_W - ew) // 2
        ey = y0 + (CELL_H - eh) // 2
        canvas.paste(em, (ex, ey), em)

    canvas.save(OUT)
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
