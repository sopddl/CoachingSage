import pathlib
import subprocess
import sys

import imageio_ffmpeg
from PIL import Image, ImageDraw

# Revue gate 1 des animations : extrait 5 frames par vidéo (0/25/50/75/100 %)
# et compose une bande par vidéo — la revue multimodale se fait sur ces bandes.

FF = imageio_ffmpeg.get_ffmpeg_exe()
ANIM = pathlib.Path("ai-explo/anim")
TMP = ANIM / "_frames"
TMP.mkdir(exist_ok=True)


def strip(mp4):
    slug = mp4.stem.replace("anim_", "")
    out = ANIM / f"_strip_{slug}.png"
    # ne réutilise la bande que si elle est plus récente que le mp4 (sinon bande
    # périmée après un trim/ralenti ffmpeg — bug constaté 07-13, gates faussés)
    if out.exists() and out.stat().st_mtime > mp4.stat().st_mtime:
        return out
    # durée via ffmpeg (stderr)
    r = subprocess.run([FF, "-i", str(mp4)], capture_output=True, text=True)
    import re
    m = re.search(r"Duration: (\d+):(\d+):([\d.]+)", r.stderr)
    dur = int(m.group(1)) * 3600 + int(m.group(2)) * 60 + float(m.group(3))
    frames = []
    for i, frac in enumerate([0.02, 0.25, 0.5, 0.75, 0.98]):
        f = TMP / f"{slug}_{i}.png"
        subprocess.run([FF, "-y", "-ss", f"{dur * frac:.2f}", "-i", str(mp4),
                        "-frames:v", "1", str(f)], capture_output=True)
        frames.append(f)
    ims = [Image.open(f).resize((360, 360)) for f in frames if f.exists()]
    band = Image.new("RGB", (360 * len(ims), 380), "white")
    d = ImageDraw.Draw(band)
    for i, im in enumerate(ims):
        band.paste(im, (i * 360, 20))
        d.text((i * 360 + 6, 2), f"{int([2, 25, 50, 75, 98][i])}%", fill="#c00")
    d.text((6, 2), slug, fill="#00c")
    band.save(out)
    return out


if __name__ == "__main__":
    vids = sorted(ANIM.glob("anim_*.mp4"))
    for v in vids:
        print(strip(v))
    print(f"{len(vids)} bandes")
