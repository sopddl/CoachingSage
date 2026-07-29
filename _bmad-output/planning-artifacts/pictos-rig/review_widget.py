# Widget de retours Sophie injecté dans les galeries : boutons OK/KO + commentaire
# par carte, autosauvegarde localStorage (par fichier), bouton d'export JSON
# (télécharge retours-<page>.json dans ~/Downloads, que Claude relit ensuite).

CSS = """
.rev{margin-top:8px;border-top:1px solid #eee;padding-top:8px;display:flex;flex-direction:column;gap:6px;}
.rev .btns{display:flex;gap:8px;}
.rev button{flex:1;padding:5px 0;border:1.5px solid #ccc;border-radius:8px;background:#fff;
  font-size:13px;font-weight:700;cursor:pointer;color:#888;}
.rev button.ok.on{background:#3f8f5c;border-color:#3f8f5c;color:#fff;}
.rev button.ko.on{background:#c65a37;border-color:#c65a37;color:#fff;}
.rev textarea{width:100%;box-sizing:border-box;border:1px solid #ddd;border-radius:8px;
  padding:6px 8px;font-size:12.5px;font-family:inherit;resize:vertical;min-height:34px;}
#revbar{position:fixed;bottom:18px;right:18px;z-index:9;display:flex;gap:10px;align-items:center;
  background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,.18);padding:10px 14px;}
#revbar .count{font-size:12.5px;color:#555;}
#revbar button{border:none;border-radius:8px;background:#2b6cb0;color:#fff;font-weight:700;
  font-size:13px;padding:8px 14px;cursor:pointer;}
"""

JS = """
<div id="revbar"><span class="count" id="revcount"></span>
<button onclick="revExport()">Exporter mes retours</button></div>
<script>
const PAGE = location.pathname.split('/').pop().replace('.html','');
const K = s => 'rev:' + PAGE + ':' + s;
function revLoad(s){ try{return JSON.parse(localStorage.getItem(K(s)))||{}}catch(e){return {}} }
function revSave(s, d){ localStorage.setItem(K(s), JSON.stringify(d)); revCount(); }
function revCount(){
  let n = 0, cards = document.querySelectorAll('.card[data-slug]');
  cards.forEach(c => { const d = revLoad(c.dataset.slug); if (d.verdict || d.comment) n++; });
  document.getElementById('revcount').textContent = n + '/' + cards.length + ' retours';
}
document.querySelectorAll('.card[data-slug]').forEach(card => {
  const slug = card.dataset.slug, d = revLoad(slug);
  const div = document.createElement('div'); div.className = 'rev';
  div.innerHTML = '<div class="btns"><button class="ok">OK</button><button class="ko">KO</button></div>' +
    '<textarea placeholder="commentaire…"></textarea>';
  card.appendChild(div);
  const ok = div.querySelector('.ok'), ko = div.querySelector('.ko'), ta = div.querySelector('textarea');
  function paint(){ ok.classList.toggle('on', d.verdict==='OK'); ko.classList.toggle('on', d.verdict==='KO'); }
  ta.value = d.comment || ''; paint();
  ok.onclick = () => { d.verdict = d.verdict==='OK' ? null : 'OK'; revSave(slug, d); paint(); };
  ko.onclick = () => { d.verdict = d.verdict==='KO' ? null : 'KO'; revSave(slug, d); paint(); };
  ta.oninput = () => { d.comment = ta.value; revSave(slug, d); };
});
function revExport(){
  const out = {};
  document.querySelectorAll('.card[data-slug]').forEach(c => {
    const d = revLoad(c.dataset.slug);
    if (d.verdict || d.comment) out[c.dataset.slug] = d;
  });
  const blob = new Blob([JSON.stringify(out, null, 1)], {type: 'application/json'});
  const a = document.createElement('a');
  a.href = URL.createObjectURL(blob); a.download = 'retours-' + PAGE + '.json'; a.click();
}
revCount();
</script>
"""
