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

# Proposition initiale Claude — pré-cochés "auto-explicite" (pas d'illustration).
PROPOSED_SKIP = {
    'double-unders', 'face-pull', 'hanging-leg-raise',
    'biceps-curl-barbell', 'triceps-pushdown', 'leg-curl', 'leg-press',
    'pull-horizontal-row', 'push-horizontal-dumbbell', 'push-horizontal-dips',
    'mountain-climber', 'farmer-carry',
}

files = sorted(p.stem for p in pathlib.Path('reliquat_final').glob('*.png') if not p.stem.endswith('_control'))

cards = []
for slug in files:
    cat, desc = DESC.get(slug, ("?", ""))
    skip_class = " skip" if slug in PROPOSED_SKIP else ""
    btn_label = "Pas d'illustration" if slug in PROPOSED_SKIP else "Auto-explicite ?"
    cards.append(f'''
    <div class="card{skip_class}" id="card-{slug}" data-cat="{cat}">
      <img src="reliquat_final/{slug}.png" loading="lazy" alt="{slug}">
      <div class="meta">
        <div class="tag tag-{cat}">{cat}</div>
        <div class="slug">{slug}</div>
        <div class="desc">{desc}</div>
      </div>
      <button class="skip-btn" onclick="toggleSkip('{slug}')">{btn_label}</button>
    </div>''')

html = f'''<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<title>Scope illustration — auto-explicite ou pas</title>
<style>
  :root {{ --bg:#f4f2ee; --card:#fff; --border:#ddd; --skip:#3a7d44; --yoga:#87AAB2; --muscu:#B3A8AE; }}
  * {{ box-sizing: border-box; }}
  body {{ font-family: -apple-system, BlinkMacSystemFont, "Helvetica Neue", sans-serif; background: var(--bg); margin:0; padding:20px 24px 80px; color:#222; }}
  h1 {{ font-size: 20px; margin: 0 0 4px; }}
  .sub {{ color:#666; font-size:13px; margin-bottom:16px; max-width:760px; }}
  .toolbar {{ position: sticky; top:0; background: var(--bg); padding:10px 0; z-index:10; display:flex; gap:12px; align-items:center; flex-wrap:wrap; border-bottom:1px solid var(--border); margin-bottom:16px; }}
  .toolbar button {{ padding:6px 12px; border-radius:6px; border:1px solid #ccc; background:#fff; cursor:pointer; font-size:13px; }}
  .filter-btn.active {{ background:#222; color:#fff; }}
  #count {{ font-weight:600; font-size:14px; }}
  #skiplist {{ width:100%; min-height:60px; font-family:ui-monospace,monospace; font-size:12px; padding:8px; border-radius:6px; border:1px solid var(--border); margin-top:8px; background:#eafbe9; }}
  .grid {{ display:grid; grid-template-columns: repeat(auto-fill, minmax(230px,1fr)); gap:16px; }}
  .card {{ background:var(--card); border:2px solid var(--border); border-radius:10px; overflow:hidden; display:flex; flex-direction:column; transition: border-color .15s, opacity .15s; }}
  .card img {{ width:100%; aspect-ratio:1/1; object-fit:cover; background:#eee; }}
  .card .meta {{ padding:8px 10px; flex:1; }}
  .tag {{ display:inline-block; font-size:10px; font-weight:700; text-transform:uppercase; letter-spacing:.03em; padding:2px 6px; border-radius:4px; color:#fff; margin-bottom:4px; }}
  .tag-Yoga {{ background: var(--yoga); }}
  .tag-Muscu {{ background: var(--muscu); }}
  .slug {{ font-family:ui-monospace,monospace; font-size:12px; color:#333; font-weight:600; }}
  .desc {{ font-size:12px; color:#555; margin-top:3px; line-height:1.35; }}
  .skip-btn {{ border:none; background:#f0f0f0; padding:8px; font-size:12px; cursor:pointer; font-weight:600; color:#333; }}
  .skip-btn:hover {{ background:#e2f5e4; }}
  .card.skip {{ border-color: var(--skip); background:#f3fbf3; }}
  .card.skip .skip-btn {{ background: var(--skip); color:#fff; }}
  .card.hidden {{ display:none; }}
</style>
</head>
<body>
<h1>Scope illustration — {len(files)} exos</h1>
<div class="sub">Vert = proposition Claude « auto-explicite, pas besoin d'illustration » (nom/machine suffisamment clair). Clique pour changer d'avis sur n'importe quelle carte. Sauvegarde auto (localStorage).</div>
<div class="toolbar">
  <span id="count"></span>
  <button class="filter-btn active" data-f="all" onclick="filterCat('all',this)">Tout</button>
  <button class="filter-btn" data-f="Yoga" onclick="filterCat('Yoga',this)">Yoga</button>
  <button class="filter-btn" data-f="Muscu" onclick="filterCat('Muscu',this)">Muscu</button>
  <button onclick="resetProposal()">Revenir à la proposition initiale</button>
</div>
<div class="grid">
{''.join(cards)}
</div>
<textarea id="skiplist" readonly placeholder="Aucun exo marqué auto-explicite."></textarea>

<script>
const total = {len(files)};
const proposed = {sorted(PROPOSED_SKIP)!r};

function getSkip() {{
  const stored = localStorage.getItem('scope_skip');
  return stored !== null ? JSON.parse(stored) : proposed.slice();
}}
function setSkip(list) {{ localStorage.setItem('scope_skip', JSON.stringify(list)); }}

function toggleSkip(slug) {{
  let list = getSkip();
  const card = document.getElementById('card-'+slug);
  if (list.includes(slug)) {{
    list = list.filter(s => s !== slug);
    card.classList.remove('skip');
    card.querySelector('.skip-btn').textContent = 'Auto-explicite ?';
  }} else {{
    list.push(slug);
    card.classList.add('skip');
    card.querySelector('.skip-btn').textContent = "Pas d'illustration";
  }}
  setSkip(list);
  refresh();
}}

function resetProposal() {{
  setSkip(proposed.slice());
  document.querySelectorAll('.card').forEach(c => {{
    const slug = c.id.replace('card-','');
    const isSkip = proposed.includes(slug);
    c.classList.toggle('skip', isSkip);
    c.querySelector('.skip-btn').textContent = isSkip ? "Pas d'illustration" : 'Auto-explicite ?';
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
  const list = getSkip();
  document.getElementById('count').textContent = list.length + ' auto-explicite / ' + total;
  document.getElementById('skiplist').value = list.length ? list.join('\\n') : '';
}}

refresh();
</script>
</body>
</html>
'''

pathlib.Path('galerie-scope-illustration.html').write_text(html)
print('written', len(files), 'cards,', len(PROPOSED_SKIP), 'pre-marked auto-explicite')
