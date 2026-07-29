import re

LOTS = [f"lot{i}.html" for i in range(1, 11)]

# Poses retravaillées dans cette passe (4e revue Sophie) — badge "retravaillée"
REWORKED = {
    "ViparitaKarani", "UttanaPadasana", "Sarvangasana", "BaddhaKonasana",
    "UpavisthaKonasana", "SetuBandha", "Dirgha", "Ujjayi", "NadiShodhana",
    "UrdhvaDhanurasana", "Salabhasana", "Boat", "Triangle", "BirdDog",
    "Karnapidasana", "CatCow", "DolphinPose", "Warrior3", "Halasana",
    "JanuSirsasana", "MarichyasanaA", "Kurmasana", "Padangusthasana",
    "Padahastasana", "Parsvottanasana", "ArdhaBaddhaPadmottanasana",
    "Purvottanasana", "Anjaneyasana", "Garudasana", "PrasaritaPadottanasana",
}

figures = []
for lot in LOTS:
    html = open(lot).read()
    for fig in re.findall(r"<figure>.*?</figure>", html, re.S):
        title = re.search(r"<b>(.*?)</b>", fig).group(1)
        caption = re.search(r"</b><br>(.*?)</figcaption>", fig, re.S).group(1)
        svgs = re.findall(r"(<svg.*?</svg>)", fig, re.S)
        body = svgs[0]
        zoom = svgs[1] if len(svgs) > 1 else None
        figures.append((title, caption, body, zoom))

print(f"{len(figures)} poses extraites de {len(LOTS)} lots")

CSS = """
body{margin:0;padding:24px;background:#fdfdfd;font-family:-apple-system,sans-serif;color:#222;}
h1{font-size:20px;margin:0 0 4px;}
.sub{color:#666;font-size:13px;margin:0 0 16px;}
.legend{display:flex;gap:18px;align-items:center;font-size:12px;color:#444;margin-bottom:10px;flex-wrap:wrap;}
.swatch{display:inline-block;width:14px;height:14px;border-radius:3px;vertical-align:middle;margin-right:5px;}
.fixnote{background:#eef6ee;border:1px solid #bfe0bf;border-radius:8px;padding:12px 16px;font-size:13px;margin-bottom:18px;max-width:900px;line-height:1.5;}
.fixnote b{color:#2c6e2c;}
.toolbar{display:flex;gap:10px;margin-bottom:18px;}
button.gen{background:#1a1a1a;color:#fff;border:none;border-radius:6px;padding:8px 14px;font-size:13px;cursor:pointer;}
button.clear{background:#eee;color:#444;border:none;border-radius:6px;padding:8px 14px;font-size:13px;cursor:pointer;}
.grid{display:flex;flex-wrap:wrap;gap:18px;}
figure{margin:0;text-align:center;width:236px;background:#fff;border:1px solid #eee;border-radius:10px;padding:10px;position:relative;}
figure.haszoom{width:380px;}
.badge{position:absolute;top:6px;left:6px;background:#c65a37;color:#fff;font-size:10px;padding:2px 6px;border-radius:10px;z-index:1;}
.cellrow{display:flex;gap:8px;}
.cell{flex:1;height:150px;background:#f7f7f7;border-radius:8px;display:flex;align-items:center;justify-content:center;overflow:hidden;}
.cell.zoom{flex:0 0 150px;background:#fff3ea;border:2px solid #e8a93d;}
.zoomlabel{font-size:10px;color:#a86a1f;margin-top:2px;}
svg{width:88%;height:88%;}
figcaption{margin-top:8px;font-size:12px;color:#444;}
figcaption b{display:block;font-size:13px;margin-bottom:2px;}
.review{margin-top:8px;display:flex;gap:6px;justify-content:center;}
.review button{flex:1;padding:5px 0;border-radius:6px;border:1px solid #ccc;background:#fff;font-size:12px;cursor:pointer;}
.review button.ok.active{background:#3f8f5c;color:#fff;border-color:#3f8f5c;}
.review button.ko.active{background:#c0392b;color:#fff;border-color:#c0392b;}
textarea{width:100%;margin-top:6px;font-size:12px;border:1px solid #ddd;border-radius:6px;padding:6px;resize:vertical;min-height:36px;box-sizing:border-box;font-family:inherit;}
#summaryBox{white-space:pre-wrap;background:#f7f7f7;border:1px solid #ddd;border-radius:8px;padding:12px;font-size:12px;margin-top:14px;max-width:900px;display:none;}
"""

JS = """
var KEY = 'sophie_pose_review_v1';
function loadState(){ try { return JSON.parse(localStorage.getItem(KEY)) || {}; } catch(e){ return {}; } }
function saveState(s){ localStorage.setItem(KEY, JSON.stringify(s)); }
function setVerdict(name, verdict){
  var s = loadState(); s[name] = s[name] || {};
  s[name].verdict = verdict; saveState(s); applyUI();
}
function setComment(name, val){
  var s = loadState(); s[name] = s[name] || {};
  s[name].comment = val; saveState(s);
}
function applyUI(){
  var s = loadState();
  document.querySelectorAll('[data-pose]').forEach(function(fig){
    var name = fig.getAttribute('data-pose');
    var st = s[name] || {};
    var okBtn = fig.querySelector('.ok'), koBtn = fig.querySelector('.ko');
    okBtn.classList.toggle('active', st.verdict === 'ok');
    koBtn.classList.toggle('active', st.verdict === 'ko');
    var ta = fig.querySelector('textarea');
    if (ta && st.comment && !ta.value) ta.value = st.comment;
  });
}
function genSummary(){
  var s = loadState();
  var lines = [];
  Object.keys(s).forEach(function(name){
    var st = s[name];
    if (!st.verdict && !st.comment) return;
    var v = st.verdict ? st.verdict.toUpperCase() : '?';
    var line = name + ' : ' + v;
    if (st.comment) line += ' — ' + st.comment;
    lines.push(line);
  });
  var box = document.getElementById('summaryBox');
  box.style.display = 'block';
  box.textContent = lines.length ? lines.join('\\n') : '(rien de coché)';
}
function clearAll(){
  if (!confirm('Effacer toutes les coches et commentaires ?')) return;
  localStorage.removeItem(KEY);
  document.querySelectorAll('textarea').forEach(function(t){ t.value = ''; });
  applyUI();
}
window.addEventListener('DOMContentLoaded', applyUI);
"""

FIXNOTE = """
<b>Ce qui a changé dans cette passe (4e revue) :</b><br>
<b>3 vrais bugs de construction trouvés et corrigés</b> (un point de code manquant
faisait brancher un membre au mauvais endroit) : <b>ViparitaKarani</b> (le tronc
traversait le mur), <b>UttanaPadasana</b> (les jambes partaient de la tête),
<b>Warrior3</b>/<b>Purvottanasana</b>/<b>ArdhaChandrasana</b> (pied/jambe flottant à
15-20 unités au-dessus du sol, jamais posé).<br>
Nouveau : panneau <b>zoom</b> agrandi (150px, était trop petit pour être vu) + position
de main recalculée numériquement pour vraiment toucher gorge/visage (Ujjayi,
NadiShodhana). Nouveau : trait courbe (<b>arc_line</b>) pour <b>UrdhvaDhanurasana</b> —
seule façon de distinguer un vrai dos cambré d'un pli (ForwardFold). Nouveau :
<b>cheveux</b> sur la tête (Salabhasana) + <b>pieds pointés bas/haut</b> pour
différencier ventre (Salabhasana) de dos (Boat). Nouveau : trait de contact sol
recoloré en <b>jaune</b> (était noir, confondu avec le corps). Nouveau : <b>flèche de
trajectoire</b> en pointillé (Halasana) pour montrer le mouvement, pas juste la
position finale.<br>
Bras ajoutés (absents avant) : <b>BaddhaKonasana, UpavisthaKonasana, SetuBandha,
JanuSirsasana</b>. Couleur/segments corrigés : <b>MarichyasanaA</b> (tibia mal
coloré + bras incomplet). Vue de face (profil ne montrait qu'une jambe) :
<b>Kurmasana</b> (comme Triangle/Prasarita passe précédente). Genou/bras retravaillés :
<b>Anjaneyasana</b> (genou arrière ne pouvait pas géométriquement toucher le sol),
<b>Garudasana</b> (un seul bras ne peut pas se lire "entrelacé", 2e bras ajouté).
Torse "qui retrace la jambe" corrigé (même bug que ForwardFold) : <b>Padangusthasana,
Padahastasana, Parsvottanasana, ArdhaBaddhaPadmottanasana</b>.<br>
<b>Pas encore fait</b> : Kapotasana, Ustrasana, Parsvakonasana, Bhujapidasana,
GarbhaPindasana, UtthitaHastaPadangusthasana, ArdhaMatsyendrasana — passables mais
pas retravaillés en profondeur cette passe (aucun motif précis donné). Cobra
"comment ne pas lever les fesses" reste une question pédagogique, pas un bug de dessin.
"""

parts = ['<!doctype html><html><head><meta charset="utf-8"><title>Rig unique — 65 poses (revue 3)</title>',
         f"<style>{CSS}</style></head><body>",
         "<h1>Rig unique — galerie de revue (65 poses)</h1>",
         '<p class="sub">Mêmes proportions, même trait, mêmes articulations partout. Coche OK/KO + commentaire, '
         'le tout se sauvegarde automatiquement dans ce navigateur.</p>',
         '<div class="legend">'
         '<span><span class="swatch" style="background:#c65a37"></span>bras (toujours)</span>'
         '<span><span class="swatch" style="background:#3f8f5c"></span>jambe (toujours)</span>'
         '<span><span class="swatch" style="background:#1a1a1a"></span>tronc/tête (toujours)</span>'
         '<span><span class="swatch" style="background:#fff3ea;border:1px solid #e0b896"></span>panneau zoom</span>'
         '<span><span class="swatch" style="background:#c65a37;border-radius:10px;width:auto;padding:0 4px;color:#fff;font-size:9px;">retravaillée</span> = changée cette passe</span>'
         "</div>",
         f'<div class="fixnote">{FIXNOTE}</div>',
         '<div class="toolbar">'
         '<button class="gen" onclick="genSummary()">Générer mon retour</button>'
         '<button class="clear" onclick="clearAll()">Tout effacer</button>'
         "</div>",
         '<pre id="summaryBox"></pre>',
         '<div class="grid">']

for title, caption, body, zoom in figures:
    badge = '<div class="badge">↻ retravaillée</div>' if title in REWORKED else ''
    fig_class = "haszoom" if zoom else ""
    zoom_div = f'<div class="cell zoom">{zoom}</div>' if zoom else ''
    parts.append(
        f'<figure class="{fig_class}" data-pose="{title}">{badge}'
        f'<div class="cellrow"><div class="cell">{body}</div>{zoom_div}</div>'
        f'<figcaption><b>{title}</b>{caption}</figcaption>'
        f'<div class="review">'
        f'<button class="ok" onclick="setVerdict(\'{title}\',\'ok\')">OK</button>'
        f'<button class="ko" onclick="setVerdict(\'{title}\',\'ko\')">KO</button>'
        f"</div>"
        f'<textarea placeholder="commentaire..." onchange="setComment(\'{title}\', this.value)"></textarea>'
        f"</figure>"
    )

parts.append("</div>")
parts.append(f"<script>{JS}</script>")
parts.append("</body></html>")

out_path = "/private/tmp/claude-501/-Users-sophieslama-CL3-CoachingSage/e5e160ab-245e-434a-aaef-68d0b4446009/scratchpad/all-65-poses.html"
with open(out_path, "w") as f:
    f.write("\n".join(parts))
print("OK —", out_path)
assert "${" not in "\n".join(parts), "template literal bug!"
