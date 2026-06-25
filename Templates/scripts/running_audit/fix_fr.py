import json, glob, os
TPL='../Sources/TemplateLoader/Resources/Templates'
# Règles ordonnées (substring FR-only). Spécifiques AVANT génériques.
RULES = [
 # --- Artefacts injection sensation-first (intervalles) ---
 ("intervalles très dur (intervalles) stricts", "intervalles très durs stricts"),
 ("le très dur (intervalles) devient", "l'allure intervalles (très dur) devient"),
 ("très dur (intervalles) (5K-3K)", "intervalles (très dur, allure 5K-3K)"),
 ("très dur (intervalles) (5K)", "intervalles (très dur, allure 5K)"),
 ("très dur (intervalles)", "intervalles (très dur)"),
 # --- Artefacts allure marathon (soutenu) ---
 ("à allure cible allure marathon (soutenu) stable", "à allure marathon cible (soutenue) stable"),
 ("(allure marathon (soutenu))", "(soutenue)"),
 ("allure marathon (soutenu)", "allure marathon (soutenue)"),
 # --- Artefacts divers ---
 ("l'allure cible à allure semi-marathon", "l'allure semi-marathon cible"),
 ("Allure à allure semi-marathon", "Allure semi-marathon cible"),
 ("MAINTENUE à au seuil", "MAINTENUE au seuil"),
 ("Allure facile (tu peux parler) facile.", "Allure facile (tu peux parler)."),
 # --- MDR : claims médicaux / chiffrés / injonctions ---
 ("Renforce le mécanisme d'absorption de choc à l'atterrissage et prévient le syndrome fémoro-patellaire (PFPS).",
  "Renforce le contrôle du genou à l'atterrissage et améliore la stabilité de la foulée."),
 ("Renforce l'insertion haute des ischio-jambiers sur fractionné : exercice le plus validé scientifiquement (Mjolsnes 2004).",
  "Travaille l'arrière de la cuisse (ischio-jambiers), un exercice de prévention reconnu chez les coureurs."),
 ("Aide-toi des mains pour remonter. Mjolsnes 2004 : -51% de gênes au tendon des ischio-jambiers.",
  "Aide-toi des mains pour remonter. Exercice de référence pour renforcer l'arrière de la cuisse."),
 ("Sollicite le tibia (les mollets forts absorbent jusqu'à 30% de la charge tibiale). Obligatoire chez le débutant.",
  "Renforce les mollets, qui protègent le tibia des chocs de la course — très important quand on débute."),
 ("Protection du tendon d'Achille. Obligatoire chez l'expert en préparation marathon (charge cumulée > 700 km).",
  "Protège le tendon d'Achille. Fortement recommandé en préparation marathon (gros volume cumulé)."),
 ("Sollicite le tendon d'Achille. Obligatoire pour coureur recreational en montée de volume.",
  "Sollicite le tendon d'Achille. Fortement recommandé quand tu montes en volume."),
 # --- Data coach-science retirée (décision Sophie : partout) ---
 (" (principe Daniels VDOT)", ""),
 ("plus exigeant métaboliquement (95-100% VDOT)", "plus exigeant (proche de ton effort maximal)"),
 ("FC cible : 85-90% FCmax, lactatémie ~4 mmol/L. ", ""),
 ("Construction de la base aérobie polarisée (LIT), ne pas forcer.",
  "On construit ta base d'endurance (course très facile, conversationnelle) — ne force pas."),
 ("C'est l'entraînement le plus spécifique du plan (sortie longue avec segment à allure semi-marathon, Pfitzinger).",
  "C'est la séance la plus proche des conditions de course du plan (sortie longue avec un segment à allure semi-marathon)."),
 ("c'est ici que se construit la base mitochondriale.", "c'est ici que se construit ton endurance de fond."),
 ("au seuil correspond au seuil lactique 1 : efficacité métabolique maximale.",
  "C'est l'allure seuil : confortablement dur, le meilleur compromis pour développer ton endurance de course."),
 ("tu as basculé dans la zone grise au-dessus du seuil.", "tu cours trop vite pour cet exercice (au-dessus de l'allure visée)."),
 ("Stimule la VO2max sans brutaliser. Si pas d'accès track : zone plate calibrée GPS suffit.",
  "Réveille la vitesse et la foulée sans fatiguer. Si tu n'as pas accès à une piste, un terrain plat repéré au GPS suffit."),
 # --- Noms/alternatives cryptiques (FR) ---
 ("Montées de genoux A (skipping A-march)", "Montées de genoux (genou haut)"),
 ("montées de genoux A (skipping A-march)", "montées de genoux (genou haut)"),
 ("Extensions des mollets bipodal sol", "Extensions des mollets debout (deux pieds)"),
 ("Extensions des mollets bipodal", "Extensions des mollets (deux pieds)"),
 ("Curl ischio au sol (razor curl)", "Curl ischio au sol"),
 ("Anti-rotation à l'élastique avec bande élastique", "Anti-rotation à l'élastique"),
 ("Bloc en escalier 1m30 + 3 min", "Bloc par paliers 1 min 30 + 3 min"),
]

def fix(v):
    """v = dict langue ; édite SEULEMENT 'fr'."""
    if not isinstance(v, dict) or 'fr' not in v: return 0
    fr = v['fr']; n=0
    for old,new in RULES:
        if old in fr:
            n += fr.count(old); fr = fr.replace(old,new)
    v['fr']=fr; return n

total=0
counts={}
for path in sorted(glob.glob(os.path.join(TPL,'running-*.json'))):
    d=json.load(open(path)); c=0
    for w in d['weeks']:
        for s in w['sessions']:
            for fld in ('warmup','cooldown','name'):
                if isinstance(s.get(fld),dict): c+=fix(s[fld])
            exos=list(s.get('exercises',[]))
            for v in s.get('variants',[]): exos+=v.get('exercises',[])
            for e in exos:
                c+=fix(e.get('name',{}))
                c+=fix(e.get('notes',{}))
                for a in e.get('alternatives',[]): c+=fix(a)
    json.dump(d,open(path,'w'),ensure_ascii=False,indent=2)
    counts[os.path.basename(path)]=c; total+=c
for k,v in counts.items(): print(f'{v:4} {k}')
print('TOTAL remplacements:',total)
