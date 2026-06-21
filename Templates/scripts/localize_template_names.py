#!/usr/bin/env python3
"""Chantier i18n « localisation des noms de templates » (2026-06-21).

Le champ `name` top-level des 40 templates était {"fr":..} fr-only → noms affichés
en FR sous EN/ES + paliers anglais (beginner/regular/competitive/recreational)
résiduels dans le FR. Ce script pose name = {fr,en,es} :
- FR : francise les paliers (libellés onboarding.level.* : Débutant/Régulier/
  Compétiteur/Loisir) + résidus (Mountain treks, finisher→finir, inversions wall,
  régionale typo, primary series/advanced).
- EN/ES : traductions ; proper nouns gardés (Half Ironman, Vinyasa, Ashtanga,
  Hatha, Iyengar, WODs, Push-Pull-Legs, Fastpacking, R3-N3).
Sérialise via swiftjson → diff limité au seul champ name.
"""
import sys, os, glob, json
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from swiftjson import dumps

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'Sources', 'TemplateLoader', 'Resources', 'Templates')

NAMES = {
 "cycling-beginner-reprise-6sem": ("Vélo reprise — Retrouver le plaisir en 6 semaines","Cycling restart — Rediscover the joy in 6 weeks","Ciclismo retomar — Reencontrar el placer en 6 semanas"),
 "cycling-competitive-cyclosportive-16sem": ("Cyclosportive — Préparation 16 semaines","Gran fondo — 16-week prep","Cicloturista — Preparación 16 semanas"),
 "cycling-recreational-endurance-10sem": ("Vélo endurance — 80 km en 10 semaines","Cycling endurance — 80 km in 10 weeks","Ciclismo resistencia — 80 km en 10 semanas"),
 "cycling-regular-sorties-longues-12sem": ("Vélo sorties longues — 150 km en 12 semaines","Cycling long rides — 150 km in 12 weeks","Ciclismo salidas largas — 150 km en 12 semanas"),
 "football-beginner-initiation-8sem": ("Football débutant — Initiation 8 semaines","Football beginner — Initiation 8 weeks","Fútbol principiante — Iniciación 8 semanas"),
 "football-competitive-saison-regional-16sem": ("Football compétiteur — Saison régionale R3-N3 16 semaines","Football competitive — Regional season R3-N3 16 weeks","Fútbol competidor — Temporada regional R3-N3 16 semanas"),
 "football-recreational-loisir-10sem": ("Football loisir — Foot loisir 10 semaines","Football recreational — Casual football 10 weeks","Fútbol ocio — Fútbol recreativo 10 semanas"),
 "football-regular-club-12sem": ("Football régulier — Saison club amateur 12 semaines","Football regular — Amateur club season 12 weeks","Fútbol regular — Temporada club amateur 12 semanas"),
 "hiit-beginner-6sem": ("HIIT initiation — 6 semaines pour réaliser une séance complète de 20 min","HIIT starter — 6 weeks to complete a full 20-min session","HIIT iniciación — 6 semanas para completar una sesión de 20 min"),
 "hiit-competitive-athletique-12sem": ("HIIT compétiteur — Préparation athlétique 12 semaines","HIIT competitive — Athletic prep 12 weeks","HIIT competidor — Preparación atlética 12 semanas"),
 "hiit-recreational-8sem": ("HIIT intermédiaire — 8 semaines","HIIT intermediate — 8 weeks","HIIT intermedio — 8 semanas"),
 "hiit-regular-10sem": ("HIIT avancé — 10 semaines de WODs progressifs","HIIT advanced — 10 weeks of progressive WODs","HIIT avanzado — 10 semanas de WODs progresivos"),
 "hiking-beginner-decouverte-8sem": ("Randonnée débutant — Découverte sentiers plats sur 8 semaines","Hiking beginner — Flat-trail discovery over 8 weeks","Senderismo principiante — Descubrir senderos llanos en 8 semanas"),
 "hiking-competitive-fastpacking-16sem": ("Randonnée compétiteur — Fastpacking + ultra-distance 16 semaines","Hiking competitive — Fastpacking + ultra-distance 16 weeks","Senderismo competidor — Fastpacking + ultradistancia 16 semanas"),
 "hiking-recreational-day-hikes-10sem": ("Randonnée loisir — Sorties à la journée 10 semaines","Hiking recreational — Day hikes 10 weeks","Senderismo ocio — Salidas de un día 10 semanas"),
 "hiking-regular-mountain-trek-12sem": ("Randonnée régulier — Treks en montagne 12 semaines","Hiking regular — Mountain treks 12 weeks","Senderismo regular — Treks de montaña 12 semanas"),
 "running-beginner-5k-8sem": ("5K Doux — 8 semaines pour courir 30 min en continu","Gentle 5K — 8 weeks to run 30 min nonstop","5K suave — 8 semanas para correr 30 min seguidos"),
 "running-competitive-marathon-16sem": ("Marathon — 16 semaines vers ton temps personnel","Marathon — 16 weeks toward your personal time","Maratón — 16 semanas hacia tu marca personal"),
 "running-recreational-10k-8sem": ("10K — 8 semaines pour franchir la barre des 10 km","10K — 8 weeks to break the 10 km mark","10K — 8 semanas para superar los 10 km"),
 "running-regular-semi-marathon-12sem": ("Semi-marathon — 12 semaines pour performer sur 21,1 km","Half marathon — 12 weeks to perform over 21.1 km","Media maratón — 12 semanas para rendir en 21,1 km"),
 "strength-training-beginner-home-basics-8sem": ("Musculation maison — Fondamentaux en 8 semaines","Home strength training — Fundamentals in 8 weeks","Musculación en casa — Fundamentos en 8 semanas"),
 "strength-training-competitive-strength-5x5-cycle": ("Force 5x5 — Cycle de progression 12 semaines","5x5 Strength — 12-week progression cycle","Fuerza 5x5 — Ciclo de progresión 12 semanas"),
 "strength-training-recreational-upperlower-12sem": ("Programme Haut/Bas — 12 semaines","Upper/Lower program — 12 weeks","Programa Superior/Inferior — 12 semanas"),
 "strength-training-regular-ppl-12sem": ("Push-Pull-Legs — 12 semaines","Push-Pull-Legs — 12 weeks","Push-Pull-Legs — 12 semanas"),
 "swimming-beginner-initiation-6sem": ("Natation initiation — Nager 200 m en 6 semaines","Swimming starter — Swim 200 m in 6 weeks","Natación iniciación — Nadar 200 m en 6 semanas"),
 "swimming-competitive-perfectionnement-12sem": ("Natation perfectionnement — 12 semaines haute intensité","Swimming advanced — 12 weeks high intensity","Natación perfeccionamiento — 12 semanas alta intensidad"),
 "swimming-recreational-endurance-8sem": ("Natation endurance — 1000 m continu en 8 semaines","Swimming endurance — 1000 m nonstop in 8 weeks","Natación resistencia — 1000 m seguidos en 8 semanas"),
 "swimming-regular-technique-8sem": ("Natation technique — Perfectionnement sur 8 semaines","Swimming technique — Refinement over 8 weeks","Natación técnica — Perfeccionamiento en 8 semanas"),
 "tennis-beginner-initiation-8sem": ("Tennis initiation — Premiers échanges en 8 semaines","Tennis starter — First rallies in 8 weeks","Tenis iniciación — Primeros peloteos en 8 semanas"),
 "tennis-competitive-tournoi-prep-16sem": ("Tennis compétiteur — Préparation tournoi 16 semaines","Tennis competitive — Tournament prep 16 weeks","Tenis competidor — Preparación torneo 16 semanas"),
 "tennis-recreational-regularite-10sem": ("Tennis régularité — 10 semaines","Tennis consistency — 10 weeks","Tenis regularidad — 10 semanas"),
 "tennis-regular-match-prep-12sem": ("Tennis régulier — Préparation match 12 semaines","Tennis regular — Match prep 12 weeks","Tenis regular — Preparación partido 12 semanas"),
 "triathlon-beginner-decouverte-10sem": ("Triathlon découverte — 10 semaines pour finir ton premier sprint","Triathlon discovery — 10 weeks to finish your first sprint","Triatlón descubrimiento — 10 semanas para terminar tu primer sprint"),
 "triathlon-competitive-half-ironman-20sem": ("Triathlon compétiteur — Half Ironman 70.3 sur 20 semaines","Triathlon competitive — Half Ironman 70.3 over 20 weeks","Triatlón competidor — Half Ironman 70.3 en 20 semanas"),
 "triathlon-recreational-sprint-12sem": ("Triathlon Sprint — 12 semaines pour enchaîner 750 m natation + 20 km vélo + 5 km course","Sprint triathlon — 12 weeks to link 750 m swim + 20 km bike + 5 km run","Triatlón Sprint — 12 semanas para encadenar 750 m natación + 20 km bici + 5 km carrera"),
 "triathlon-regular-distance-m-16sem": ("Triathlon régulier — Distance M (Olympique) 16 semaines","Triathlon regular — M distance (Olympic) 16 weeks","Triatlón regular — Distancia M (Olímpica) 16 semanas"),
 "yoga-beginner-initiation-6sem": ("Yoga initiation — 6 semaines pour une pratique autonome","Yoga starter — 6 weeks to a self-guided practice","Yoga iniciación — 6 semanas para una práctica autónoma"),
 "yoga-competitive-advanced-12sem": ("Yoga compétiteur — Ashtanga série primaire + Iyengar avancé, 12 semaines","Yoga competitive — Ashtanga primary series + advanced Iyengar, 12 weeks","Yoga competidor — Ashtanga serie primaria + Iyengar avanzado, 12 semanas"),
 "yoga-recreational-hatha-8sem": ("Hatha yoga — 8 semaines de pratique régulière","Hatha yoga — 8 weeks of regular practice","Hatha yoga — 8 semanas de práctica regular"),
 "yoga-regular-vinyasa-10sem": ("Yoga régulier — Vinyasa, enchaînement + intro inversions au mur, 10 semaines","Yoga regular — Vinyasa, flow + intro to wall inversions, 10 weeks","Yoga regular — Vinyasa, encadenamiento + intro inversiones en pared, 10 semanas"),
}

def main():
    files = sorted(glob.glob(os.path.join(BASE, '*.json')))
    done = 0; missing = []
    seen_ids = set()
    for f in files:
        if os.path.basename(f) == 'template-summaries.json':
            continue
        orig = open(f).read(); d = json.loads(orig)
        tid = d.get('id')
        seen_ids.add(tid)
        if tid not in NAMES:
            missing.append(tid); continue
        fr, en, es = NAMES[tid]
        d['name'] = {"fr": fr, "en": en, "es": es}
        out = dumps(d)
        if out != orig:
            open(f, 'w').write(out); done += 1
    print(f"# {done} fichiers mis à jour")
    if missing: print("!! id sans mapping:", missing)
    extra = [k for k in NAMES if k not in seen_ids]
    if extra: print("!! mapping sans template:", extra)

if __name__ == '__main__':
    main()
