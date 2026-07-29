import pathlib

DESC = {
    'ardhaBaddhaPadmottanasana': ("Yoga", "Demi-lotus en flexion avant debout — jambe repliée en demi-lotus dans le dos, main opposée au sol."),
    'bakasana': ("Yoga", "Posture du corbeau — équilibre sur les mains, genoux calés sur les triceps."),
    'bhujapidasana': ("Yoga", "Pression des bras — équilibre sur les mains, jambes croisées devant les épaules."),
    'biceps-curl-barbell': ("Muscu", "Curl biceps à la barre."),
    'bird-dog': ("Muscu", "Bird-dog — quadrupédie, bras et jambe opposée tendus."),
    'boat': ("Yoga", "Posture du bateau (navasana)."),
    'cable-fly': ("Muscu", "Écarté à la poulie vis-à-vis (cable fly)."),
    'catCowForearms': ("Yoga", "Chat-vache sur les avant-bras."),
    'child': ("Yoga", "Posture de l'enfant (balasana)."),
    'clamshell': ("Muscu", "Clamshell — fessiers moyens, allongé sur le côté."),
    'cobra_test': ("Yoga", "Posture du cobra (bhujangasana)."),
    'dead-bug': ("Muscu", "Dead bug — gainage, bras et jambe opposés en extension."),
    'dhanurasana': ("Yoga", "Posture de l'arc."),
    'dirgha': ("Yoga", "Respiration complète en 3 temps (dirgha pranayama)."),
    'dolphinPose': ("Yoga", "Posture du dauphin — avant-bras au sol, hanches hautes."),
    'double-unders': ("Muscu", "Double-unders — corde à sauter, double rotation par saut."),
    'eagle': ("Yoga", "Posture de l'aigle (garudasana)."),
    'face-pull': ("Muscu", "Face pull — tirage à la poulie vers le visage."),
    'farmer-carry': ("Muscu", "Farmer carry — marche chargée, un poids dans chaque main."),
    'halasana': ("Yoga", "Posture de la charrue — jambes tendues au-dessus de la tête, orteils au sol."),
    'hanging-leg-raise': ("Muscu", "Relevé de jambes suspendu à la barre."),
    'hinge-rdl-barbell': ("Muscu", "Soulevé de terre jambes tendues (RDL) à la barre."),
    'hip-thrust': ("Muscu", "Hip thrust — poussée de hanches à la barre, épaules sur banc."),
    'januSirsasana': ("Yoga", "Tête au genou (janu sirsasana)."),
    'kapotasana': ("Yoga", "Posture du pigeon roi (kapotasana)."),
    'karnapidasana': ("Yoga", "Pression des oreilles — variante genoux pliés de la charrue."),
    'kurmasana': ("Yoga", "Posture de la tortue."),
    'leg-curl': ("Muscu", "Leg curl — flexion des jambes, ischio-jambiers."),
    'leg-press': ("Muscu", "Presse à cuisses."),
    'lunge-bodyweight': ("Muscu", "Fente au poids du corps."),
    'matsyasana': ("Yoga", "Posture du poisson."),
    'mountain-climber': ("Muscu", "Mountain climber — genoux ramenés en gainage."),
    'nadiShodhana': ("Yoga", "Respiration alternée (nadi shodhana)."),
    'nordic-curl': ("Muscu", "Nordic curl — ischio-jambiers en excentrique, genoux calés."),
    'pallof-press': ("Muscu", "Pallof press — anti-rotation à la poulie."),
    'phalakasana': ("Yoga", "Posture de la planche (phalakasana)."),
    'plyo-jumpsquat': ("Muscu", "Squat sauté pliométrique."),
    'power-clean': ("Muscu", "Power clean — arraché-épaulé à la barre."),
    'prasaritaPadottanasana': ("Yoga", "Flexion avant jambes écartées."),
    'pull-horizontal-row': ("Muscu", "Rowing horizontal (tirage)."),
    'purvottanasana': ("Yoga", "Planche inversée (purvottanasana)."),
    'push-horizontal-dips': ("Muscu", "Dips — pectoraux/triceps."),
    'push-horizontal-dumbbell': ("Muscu", "Développé couché haltères."),
    'reverse-hyper': ("Muscu", "Reverse hyper — extension lombaire inversée."),
    'salabhasana': ("Yoga", "Posture de la sauterelle (salabhasana)."),
    'sarvangasana': ("Yoga", "Chandelle (sarvangasana)."),
    'savasana': ("Yoga", "Posture du cadavre — relaxation finale."),
    'setuBandha': ("Yoga", "Pont (setu bandhasana)."),
    'side-plank': ("Muscu", "Planche latérale (side plank)."),
    'sirsasana': ("Yoga", "Posture sur la tête (sirsasana)."),
    'sled-push': ("Muscu", "Poussée de traîneau (sled push)."),
    'suptaBaddhaKonasana': ("Yoga", "Papillon allongé (supta baddha konasana)."),
    'tibialis-raise': ("Muscu", "Relevé du tibial antérieur."),
    'triceps-pushdown': ("Muscu", "Extension triceps à la poulie."),
    'turkish-getup': ("Muscu", "Turkish get-up — lever turc."),
    'ujjayi': ("Yoga", "Respiration ujjayi."),
    'upavisthaKonasana': ("Yoga", "Grand écart assis (upavistha konasana)."),
    'urdhvaDhanurasana': ("Yoga", "Pont complet / roue (urdhva dhanurasana)."),
    'ustrasana': ("Yoga", "Posture du chameau (ustrasana)."),
    'uttanaPadasana': ("Yoga", "Jambes tendues levées (uttana padasana)."),
    'utthitaHastaPadangusthasana': ("Yoga", "Main à l'orteil, équilibre debout jambe tendue."),
    'viparitaKarani': ("Yoga", "Jambes au mur (viparita karani)."),
    'warrior2': ("Yoga", "Guerrier II (virabhadrasana II)."),
    'warrior3': ("Yoga", "Guerrier III (virabhadrasana III)."),
    'woodchopper': ("Muscu", "Woodchopper — rotation type bûcheron à la poulie."),
    'ytw-activation': ("Muscu", "Activation Y-T-W — coiffe des rotateurs / omoplates."),
}

files = sorted(p.stem for p in pathlib.Path('reliquat_final').glob('*.png')
               if not p.stem.endswith('_control') and '_BROKEN_backup' not in p.stem
               and '_KO_backup' not in p.stem)

cards = []
for slug in files:
    cat, desc = DESC.get(slug, ("?", ""))
    cards.append(f'''
    <div class="card" id="card-{slug}" data-cat="{cat}">
      <img src="reliquat_final/{slug}.png" loading="lazy" alt="{slug}">
      <div class="meta">
        <div class="tag tag-{cat}">{cat}</div>
        <div class="slug">{slug}</div>
        <div class="desc">{desc}</div>
      </div>
      <button class="ko-btn" onclick="toggleKO('{slug}')">Marquer KO</button>
      <textarea class="comment-box" placeholder="Commentaire..." oninput="saveComment('{slug}', this.value)"></textarea>
    </div>''')

html = f'''<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Gate reliquat illustrations — {len(files)} assets</title>
<style>
  :root {{ --bg:#f4f2ee; --card:#fff; --border:#ddd; --ko:#e05353; --yoga:#87AAB2; --muscu:#B3A8AE; }}
  * {{ box-sizing: border-box; }}
  body {{ font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif; background: var(--bg); margin:0; padding:20px 24px 80px; color:#222; }}
  h1 {{ font-size: 20px; margin: 0 0 4px; }}
  .sub {{ color:#666; font-size:13px; margin-bottom:16px; }}
  .toolbar {{ position: sticky; top:0; background: var(--bg); padding:10px 0; z-index:10; display:flex; gap:12px; align-items:center; flex-wrap:wrap; border-bottom:1px solid var(--border); margin-bottom:16px; }}
  .toolbar button {{ padding:6px 12px; border-radius:6px; border:1px solid #ccc; background:#fff; cursor:pointer; font-size:13px; }}
  .filter-btn.active {{ background:#222; color:#fff; }}
  #count {{ font-weight:600; font-size:14px; }}
  #kolist {{ width:100%; min-height:50px; font-family:ui-monospace,monospace; font-size:12px; padding:8px; border-radius:6px; border:1px solid var(--border); margin-top:8px; background:#fffbe6; }}
  .grid {{ display:grid; grid-template-columns: repeat(auto-fill, minmax(230px,1fr)); gap:16px; }}
  .card {{ background:var(--card); border:2px solid var(--border); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; transition: border-color .15s, opacity .15s; }}
  .card img {{ width:100%; aspect-ratio:1/1; object-fit:cover; background:#eee; }}
  .card .meta {{ padding:8px 10px; flex:1; }}
  .tag {{ display:inline-block; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.03em; padding:2px 6px; border-radius:4px; color:#fff; margin-bottom:4px; }}
  .tag-Yoga {{ background: var(--yoga); }}
  .tag-Muscu {{ background: var(--muscu); }}
  .slug {{ font-family:ui-monospace,monospace; font-size:12px; color:#333; font-weight:600; }}
  .desc {{ font-size:12px; color:#555; margin-top:3px; line-height:1.35; }}
  .ko-btn {{ border:none; background:#f0f0f0; padding:8px; font-size:12px; cursor:pointer; font-weight:600; color:#a33; }}
  .ko-btn:hover {{ background:#fbe0e0; }}
  .card.ko {{ border-color: var(--ko); opacity:.6; }}
  .card.ko img {{ filter: grayscale(1); }}
  .card.ko .ko-btn {{ background: var(--ko); color:#fff; }}
  .card.hidden {{ display:none; }}
  .comment-box {{ width:100%; box-sizing:border-box; min-height:40px; font-size:12px; padding:6px; border:1px solid var(--border); border-top:none; resize:vertical; font-family:inherit; }}
</style>
</head>
<body>
<h1>Gate reliquat illustrations — {len(files)} assets</h1>
<div class="sub">Clique « Marquer KO » sur les assets à refaire. L'état est sauvegardé automatiquement (localStorage) — tu peux fermer/rouvrir la page.</div>
<div class="toolbar">
  <span id="count"></span>
  <button class="filter-btn active" data-f="all" onclick="filterCat('all',this)">Tout</button>
  <button class="filter-btn" data-f="Yoga" onclick="filterCat('Yoga',this)">Yoga</button>
  <button class="filter-btn" data-f="Muscu" onclick="filterCat('Muscu',this)">Muscu</button>
  <button onclick="resetAll()">Tout réinitialiser</button>
</div>
<div class="grid">
{''.join(cards)}
</div>
<textarea id="kolist" readonly placeholder="Aucun KO pour l'instant."></textarea>

<script>
const total = {len(files)};
function getKO() {{ return JSON.parse(localStorage.getItem('reliquat_ko') || '[]'); }}
function setKO(list) {{ localStorage.setItem('reliquat_ko', JSON.stringify(list)); }}

function toggleKO(slug) {{
  let list = getKO();
  const card = document.getElementById('card-'+slug);
  if (list.includes(slug)) {{
    list = list.filter(s => s !== slug);
    card.classList.remove('ko');
    card.querySelector('.ko-btn').textContent = 'Marquer KO';
  }} else {{
    list.push(slug);
    card.classList.add('ko');
    card.querySelector('.ko-btn').textContent = 'Annuler KO';
  }}
  setKO(list);
  refresh();
}}

function resetAll() {{
  setKO([]);
  document.querySelectorAll('.card').forEach(c => {{
    c.classList.remove('ko');
    c.querySelector('.ko-btn').textContent = 'Marquer KO';
  }});
  refresh();
}}

function filterCat(cat, btn) {{
  document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
  btn.classList.add('active');
  document.querySelectorAll('.card').forEach(c => {{
    c.classList.toggle('hidden', cat !== 'all' && c.dataset.cat !== cat);
  }});
}}

function refresh() {{
  const list = getKO();
  document.getElementById('count').textContent = list.length + ' KO / ' + total;
  document.getElementById('kolist').value = list.length ? list.join('\\n') : '';
}}

function getComments() {{ return JSON.parse(localStorage.getItem('reliquat_comments') || '{{}}'); }}
function saveComment(slug, value) {{
  const all = getComments();
  if (value) {{ all[slug] = value; }} else {{ delete all[slug]; }}
  localStorage.setItem('reliquat_comments', JSON.stringify(all));
}}

// restore state on load
const initial = getKO();
initial.forEach(slug => {{
  const card = document.getElementById('card-'+slug);
  if (card) {{
    card.classList.add('ko');
    card.querySelector('.ko-btn').textContent = 'Annuler KO';
  }}
}});
const initialComments = getComments();
Object.keys(initialComments).forEach(slug => {{
  const card = document.getElementById('card-'+slug);
  if (card) {{ card.querySelector('.comment-box').value = initialComments[slug]; }}
}});
refresh();
</script>
</body>
</html>
'''

pathlib.Path('galerie-reliquat-final.html').write_text(html)
print('written', len(files), 'cards')
