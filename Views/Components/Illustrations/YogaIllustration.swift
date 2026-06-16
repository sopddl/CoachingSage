// Views/Components/Illustrations/YogaIllustration.swift
// Story 3.19 Jalon 2c — 10 poses yoga V1 (Sophie 2026-05-23).
// Story 3.23 Tier 1 Jalon 1 — ajout Dirgha pranayama + Cat-cow (+ variante
// avant-bras) suite test simu Sophie 2026-05-24 (3 KO confirmés).
// Pattern ombrelle `.yoga` → dispatch interne keyword `exerciseName` vers la
// sub-pose. Toutes statiques 1 frame + annotations alignement orange.
//
// Poses V1 (Story 3.19) :
//   - Chien tête en bas (Adho Mukha Svanasana)
//   - Guerrier I, II (Virabhadrasana I, II)
//   - Arbre (Vrksasana)
//   - Cobra (Bhujangasana)
//   - Enfant (Balasana)
//   - Pince debout (Uttanasana)
//   - Triangle (Trikonasana)
//   - Bateau (Navasana)
//   - Savasana (cadavre)
// Poses ajoutées Story 3.23 Tier 1 Jalon 1 :
//   - Dirgha pranayama (respiration 3-parties allongée + 3 cercles)
//   - Cat-cow (Marjaryasana-Bitilasana) — 4 pattes profil + flèches ↕
//   - Cat-cow variante avant-bras
// Poses ajoutées Story 3.23 Tier 1 Jalon 3 (haute fréquence inventaire agent) :
//   - Sarvangasana / Chandelle (88 occ × 4 tpl)
//   - Setu Bandha / Pont fessier (69 occ × 4 tpl)
//   - Ujjayi / Pranayama souffle océan assise (75 occ × 4 tpl)
//   - Surya Namaskar A / Salutation soleil A (97 occ × 3 tpl) — 3 mini-silhouettes
//
// Silhouette violet yoga (`Color.coachingSport(forCode: "yoga")` = `#9B6BB3`).
import SwiftUI

struct YogaIllustration: View {
    let sportCode: String
    var exerciseName: String? = nil
    /// Hauteur de rendu. POC yoga (D4) : avant, la frame était figée à 80×48 et le
    /// `size:` passé par le parent était ignoré → dessin « riquiqui ». Désormais le
    /// dessin grossit avec `size` (largeur = hauteur × ratio viewbox, ancrage conservé).
    var size: CGFloat = IllustrationStyle.staticFrameSize.height

    var body: some View {
        Canvas { ctx, canvasSize in
            let sx = canvasSize.width / IllustrationStyle.staticFrameSize.width
            let sy = canvasSize.height / IllustrationStyle.staticFrameSize.height
            let s = min(sx, sy)
            // Centrage du dessin dans la frame (D4 « recentrer ») — sans effet quand
            // la frame respecte déjà le ratio du viewbox, robuste sinon.
            ctx.translateBy(x: (canvasSize.width - IllustrationStyle.staticFrameSize.width * s) / 2,
                            y: (canvasSize.height - IllustrationStyle.staticFrameSize.height * s) / 2)
            let stroke = StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s, lineCap: .round, lineJoin: .round)

            // Sol pointillé fixe (référentiel ancrage)
            var ground = Path()
            ground.move(to: CGPoint(x: 4 * s, y: 46 * s))
            ground.addLine(to: CGPoint(x: 76 * s, y: 46 * s))
            ctx.stroke(ground, with: .color(IllustrationStyle.groundLine),
                       style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))

            switch poseKind {
            case .downwardDog:     drawDownwardDog(ctx, s: s, stroke: stroke)
            case .warrior1:        drawWarrior1(ctx, s: s, stroke: stroke)
            case .warrior2:        drawWarrior2(ctx, s: s, stroke: stroke)
            case .tree:            drawTree(ctx, s: s, stroke: stroke)
            case .cobra:           drawCobra(ctx, s: s, stroke: stroke)
            case .child:           drawChild(ctx, s: s, stroke: stroke)
            case .forwardFold:     drawForwardFold(ctx, s: s, stroke: stroke)
            case .triangle:        drawTriangle(ctx, s: s, stroke: stroke)
            case .boat:            drawBoat(ctx, s: s, stroke: stroke)
            case .savasana:        drawSavasana(ctx, s: s, stroke: stroke)
            case .dirgha:          drawDirgha(ctx, s: s, stroke: stroke)
            case .catCow:          drawCatCow(ctx, s: s, stroke: stroke, forearms: false)
            case .catCowForearms:  drawCatCow(ctx, s: s, stroke: stroke, forearms: true)
            case .sarvangasana:    drawSarvangasana(ctx, s: s, stroke: stroke)
            case .setuBandha:      drawSetuBandha(ctx, s: s, stroke: stroke)
            case .ujjayi:          drawUjjayi(ctx, s: s, stroke: stroke)
            case .suryaNamaskarA:  drawSuryaNamaskarA(ctx, s: s, stroke: stroke)
            // Story 3.23 Lot 2
            case .padangusthasana:     drawPadangusthasana(ctx, s: s, stroke: stroke)
            case .suryaNamaskarB:      drawSuryaNamaskarB(ctx, s: s, stroke: stroke)
            case .baddhaKonasana:      drawBaddhaKonasana(ctx, s: s, stroke: stroke)
            case .paschimottanasana:   drawPaschimottanasana(ctx, s: s, stroke: stroke)
            case .suptaBaddhaKonasana: drawSuptaBaddhaKonasana(ctx, s: s, stroke: stroke)
            // Story 3.23 Lot 4
            case .januSirsasana:    drawJanuSirsasana(ctx, s: s, stroke: stroke)
            case .tadasana:         drawTadasana(ctx, s: s, stroke: stroke)
            case .dandasana:        drawDandasana(ctx, s: s, stroke: stroke)
            case .marichyasanaA:    drawMarichyasanaA(ctx, s: s, stroke: stroke)
            case .matsyasana:       drawMatsyasana(ctx, s: s, stroke: stroke)
            case .parsvakonasana:   drawParsvakonasana(ctx, s: s, stroke: stroke)
            case .viparitaKarani:   drawViparitaKarani(ctx, s: s, stroke: stroke)
            case .parsvottanasana:  drawParsvottanasana(ctx, s: s, stroke: stroke)
            case .halasana:         drawHalasana(ctx, s: s, stroke: stroke)
            case .kurmasana:        drawKurmasana(ctx, s: s, stroke: stroke)
            // Story 3.23 Lot 6
            case .anjaneyasana:      drawAnjaneyasana(ctx, s: s, stroke: stroke)
            case .urdhvaDhanurasana: drawUrdhvaDhanurasana(ctx, s: s, stroke: stroke)
            case .dolphinPose:       drawDolphinPose(ctx, s: s, stroke: stroke)
            case .garudasana:        drawGarudasana(ctx, s: s, stroke: stroke)
            case .utkatasana:        drawUtkatasana(ctx, s: s, stroke: stroke)
            case .warrior3:          drawWarrior3(ctx, s: s, stroke: stroke)
            case .nadiShodhana:      drawNadiShodhana(ctx, s: s, stroke: stroke)
            case .ardhaChandrasana:  drawArdhaChandrasana(ctx, s: s, stroke: stroke)
            case .sukhasana:         drawSukhasana(ctx, s: s, stroke: stroke)
            case .sirsasana:         drawSirsasana(ctx, s: s, stroke: stroke)
            // Party illustrations 2026-06-08 — asanas avancées
            case .salabhasana:                  drawSalabhasana(ctx, s: s, stroke: stroke)
            case .ustrasana:                    drawUstrasana(ctx, s: s, stroke: stroke)
            case .dhanurasana:                  drawDhanurasana(ctx, s: s, stroke: stroke)
            case .phalakasana:                  drawPhalakasana(ctx, s: s, stroke: stroke)
            case .upavisthaKonasana:            drawUpavisthaKonasana(ctx, s: s, stroke: stroke)
            case .bakasana:                     drawBakasana(ctx, s: s, stroke: stroke)
            case .purvottanasana:               drawPurvottanasana(ctx, s: s, stroke: stroke)
            case .uttanaPadasana:               drawUttanaPadasana(ctx, s: s, stroke: stroke)
            case .prasaritaPadottanasana:       drawPrasaritaPadottanasana(ctx, s: s, stroke: stroke)
            case .padahastasana:                drawPadahastasana(ctx, s: s, stroke: stroke)
            case .ardhaMatsyendrasana:          drawArdhaMatsyendrasana(ctx, s: s, stroke: stroke)
            case .kapotasana:                   drawKapotasana(ctx, s: s, stroke: stroke)
            case .bhujapidasana:                drawBhujapidasana(ctx, s: s, stroke: stroke)
            case .garbhaPindasana:              drawGarbhaPindasana(ctx, s: s, stroke: stroke)
            case .karnapidasana:                drawKarnapidasana(ctx, s: s, stroke: stroke)
            case .utthitaHastaPadangusthasana:  drawUtthitaHastaPadangusthasana(ctx, s: s, stroke: stroke)
            case .ardhaBaddhaPadmottanasana:    drawArdhaBaddhaPadmottanasana(ctx, s: s, stroke: stroke)
            // POC yoga (D1) — fallback ORIENTATION-AWARE : une posture non reconnue
            // ne s'affiche plus systématiquement debout (Warrior I). On infère
            // couché/assis/debout par mots-clés sanskrit et on dessine une
            // silhouette générique de la BONNE orientation. Plus jamais d'absurde
            // (couché → debout). Couverture 1-dessin-par-posture = V2.
            case .unknown:
                switch fallbackOrientation {
                case .lying:    drawGenericLying(ctx, s: s, stroke: stroke)
                case .seated:   drawGenericSeated(ctx, s: s, stroke: stroke)
                case .standing: drawGenericStanding(ctx, s: s, stroke: stroke)
                }
            }
        }
        .frame(width: size * IllustrationStyle.staticFrameSize.width / IllustrationStyle.staticFrameSize.height,
               height: size)
    }

    // MARK: - Pose detection

    private enum YogaPose {
        case downwardDog, warrior1, warrior2, tree, cobra
        case child, forwardFold, triangle, boat, savasana
        // Story 3.23 Tier 1 Jalon 1
        case dirgha, catCow, catCowForearms
        // Story 3.23 Tier 1 Jalon 3
        case sarvangasana, setuBandha, ujjayi, suryaNamaskarA
        // Story 3.23 Lot 2 (haute fréquence)
        case padangusthasana, suryaNamaskarB, baddhaKonasana, paschimottanasana, suptaBaddhaKonasana
        // Story 3.23 Lot 4 (moyenne fréquence)
        case januSirsasana, tadasana, dandasana, marichyasanaA, matsyasana
        case parsvakonasana, viparitaKarani, parsvottanasana, halasana, kurmasana
        // Story 3.23 Lot 6 (reste yoga)
        case anjaneyasana, urdhvaDhanurasana, dolphinPose, garudasana, utkatasana
        case warrior3, nadiShodhana, ardhaChandrasana, sukhasana, sirsasana
        // Party illustrations 2026-06-08 — asanas avancées (longue traîne, comp/advanced)
        case salabhasana, ustrasana, dhanurasana, phalakasana, upavisthaKonasana
        case bakasana, purvottanasana, uttanaPadasana, prasaritaPadottanasana, padahastasana
        case ardhaMatsyendrasana, kapotasana, bhujapidasana, garbhaPindasana, karnapidasana
        case utthitaHastaPadangusthasana, ardhaBaddhaPadmottanasana
        case unknown
    }

    private var poseKind: YogaPose {
        guard let lower = exerciseName?.lowercased() else { return .unknown }
        // Cat-cow variante avant-bras AVANT cat-cow (ordering matters : "avant-bras"
        // doit matcher avant le simple "cat"/"cow").
        if (lower.contains("avant-bras") || lower.contains("avant bras") || lower.contains("forearm"))
            && (lower.contains("cat") || lower.contains("cow") || lower.contains("chat") || lower.contains("vache")
                || lower.contains("marjaryasana") || lower.contains("bitilasana")) {
            return .catCowForearms
        }
        if lower.contains("cat-cow") || lower.contains("cat cow") || lower.contains("chat-vache") || lower.contains("chat vache")
            || lower.contains("marjaryasana") || lower.contains("bitilasana") {
            return .catCow
        }
        // Story 3.23 Tier 1 Jalon 3 — Ujjayi (souffle océan assise)
        if lower.contains("ujjayi") || lower.contains("souffle océan") || lower.contains("souffle ocean")
            || lower.contains("ocean breath") {
            return .ujjayi
        }
        // Dirgha pranayama (respiration 3-parties). Ordre : Ujjayi avant Dirgha
        // (sinon "pranayama" générique tomberait sur Dirgha pour Ujjayi).
        if lower.contains("dirgha") || lower.contains("respiration 3") || lower.contains("respiration trois")
            || lower.contains("trois temps") || lower.contains("three part")
            || lower.contains("pranayama") {
            return .dirgha
        }
        // Story 3.23 Tier 1 Jalon 3 — Sarvangasana (chandelle/shoulderstand)
        if lower.contains("sarvangasana") || lower.contains("chandelle") || lower.contains("shoulderstand")
            || lower.contains("shoulder stand") {
            return .sarvangasana
        }
        // Setu Bandha (pont fessier) — distinguer du "pont fessier" strength
        // (hip thrust). Le sport yoga + le nom Setu/bridge yoga différencie.
        if lower.contains("setu bandha") || lower.contains("setu-bandha")
            || (lower.contains("pont") && (lower.contains("yoga") || lower.contains("setu")))
            || lower.contains("bridge pose") {
            return .setuBandha
        }
        // Story 3.23 Lot 2 — Surya Namaskar B (avec Utkatasana) AVANT A
        // (sinon "surya namaskar" matche A en priorité).
        if lower.contains("surya namaskar b") || lower.contains("salutation soleil b")
            || lower.contains("sun salutation b") {
            return .suryaNamaskarB
        }
        // Surya Namaskar A (salutation soleil)
        if lower.contains("surya namaskar") || lower.contains("salutation soleil")
            || lower.contains("salutation au soleil") || lower.contains("sun salutation") {
            return .suryaNamaskarA
        }
        // Story 3.23 Lot 2 — Supta Baddha Konasana (papillon allongé) AVANT
        // Baddha Konasana (sinon "baddha" matche cordonnier assis).
        if lower.contains("supta baddha") || lower.contains("supta-baddha")
            || lower.contains("papillon allongé") || lower.contains("papillon allonge")
            || lower.contains("reclining bound angle") || lower.contains("reclining cobbler") {
            return .suptaBaddhaKonasana
        }
        // Story 3.23 Lot 2 — Baddha Konasana (cordonnier / cobbler assis)
        if lower.contains("baddha konasana") || lower.contains("baddha-konasana")
            || lower.contains("cordonnier") || lower.contains("cobbler")
            || lower.contains("bound angle") || lower.contains("papillon") {
            return .baddhaKonasana
        }
        // Story 3.23 Lot 2 — Paschimottanasana (flexion avant assise)
        if lower.contains("paschimottanasana") || lower.contains("flexion avant assise")
            || lower.contains("seated forward bend") || lower.contains("pince assise") {
            return .paschimottanasana
        }
        // Story 3.23 Lot 2 — Padangusthasana (flexion grand orteil debout)
        // Doit matcher AVANT Uttanasana car les 2 poses sont proches (Pince debout).
        if lower.contains("padangusthasana") || lower.contains("grand orteil")
            || lower.contains("big toe pose") || lower.contains("gros orteil") {
            return .padangusthasana
        }
        // Story 3.23 Lot 4 — Janu Sirsasana AVANT Sirsasana (futur Lot 6).
        // "janu" = unique, jamais ambigu.
        if lower.contains("janu sirsasana") || lower.contains("janu-sirsasana")
            || lower.contains("tête au genou") || lower.contains("tete au genou")
            || lower.contains("head to knee") {
            return .januSirsasana
        }
        // Story 3.23 Lot 4 — Marichyasana A (torsion assise)
        if lower.contains("marichyasana") || lower.contains("marichi") {
            return .marichyasanaA
        }
        // Story 3.23 Lot 4 — Matsyasana (poisson)
        if lower.contains("matsyasana") || lower.contains("poisson") || lower.contains("fish pose") {
            return .matsyasana
        }
        // Story 3.23 Lot 4 — Utthita Parsvakonasana (angle latéral étendu).
        // AVANT Parsvottanasana (mots proches).
        if lower.contains("parsvakonasana") || lower.contains("angle latéral") || lower.contains("angle lateral")
            || lower.contains("side angle") {
            return .parsvakonasana
        }
        // Story 3.23 Lot 4 — Parsvottanasana (pyramide)
        if lower.contains("parsvottanasana") || lower.contains("pyramide")
            || lower.contains("intense side stretch") {
            return .parsvottanasana
        }
        // Story 3.23 Lot 4 — Viparita Karani (jambes contre le mur)
        if lower.contains("viparita karani") || lower.contains("viparita-karani")
            || lower.contains("jambes contre le mur") || lower.contains("jambes au mur")
            || lower.contains("legs up the wall") {
            return .viparitaKarani
        }
        // Story 3.23 Lot 4 — Halasana (charrue)
        if lower.contains("halasana") || lower.contains("charrue") || lower.contains("plow pose") {
            return .halasana
        }
        // Story 3.23 Lot 4 — Kurmasana (tortue)
        if lower.contains("kurmasana") || lower.contains("tortue") || lower.contains("tortoise") {
            return .kurmasana
        }
        // Story 3.23 Lot 4 — Dandasana (bâton assis) AVANT generic
        if lower.contains("dandasana") || lower.contains("bâton assis") || lower.contains("baton assis")
            || lower.contains("staff pose") {
            return .dandasana
        }
        // Story 3.23 Lot 4 — Tadasana standalone (montagne). AVANT Surya A
        // qui contient "tadasana" dans le code mais matche déjà sur "surya".
        // Mot "tadasana" simple suffit.
        if lower.contains("tadasana") || lower.contains("montagne") || lower.contains("mountain pose") {
            return .tadasana
        }
        // Story 3.23 Lot 6 — Anjaneyasana (low lunge / fente basse yoga)
        // AVANT toute autre détection lunge (qui est strength).
        if lower.contains("anjaneyasana") || lower.contains("low lunge")
            || lower.contains("fente basse") || lower.contains("lunge bas") {
            return .anjaneyasana
        }
        // Story 3.23 Lot 6 — Urdhva Dhanurasana (roue / wheel)
        if lower.contains("urdhva dhanurasana") || lower.contains("roue")
            || lower.contains("wheel pose") || lower.contains("upward bow") {
            return .urdhvaDhanurasana
        }
        // Story 3.23 Lot 6 — Dolphin pose / Forearm Down Dog
        // AVANT chien tête en bas (mots clés "chien" / "downward" matchent les deux).
        if lower.contains("dolphin") || lower.contains("dauphin")
            || lower.contains("pincha") || lower.contains("forearm down")
            || lower.contains("makarasana") {
            return .dolphinPose
        }
        // Story 3.23 Lot 6 — Garudasana (aigle)
        if lower.contains("garudasana") || lower.contains("aigle") || lower.contains("eagle pose") {
            return .garudasana
        }
        // Story 3.23 Lot 6 — Utkatasana standalone (chaise). AVANT Surya B
        // qui contient utkatasana mais matche sur "surya b".
        if lower.contains("utkatasana") || lower.contains("chaise") || lower.contains("chair pose") {
            return .utkatasana
        }
        // Story 3.23 Lot 6 — Warrior 3 (équilibre buste horizontal)
        // AVANT Warrior 1/2 generic — "warrior 3" / "iii" plus spécifique.
        if lower.contains("warrior 3") || lower.contains("warrior iii") || lower.contains("guerrier 3")
            || lower.contains("guerrier iii") || lower.contains("virabhadrasana iii") {
            return .warrior3
        }
        // Story 3.23 Lot 6 — Nadi Shodhana (respiration alternée)
        if lower.contains("nadi shodhana") || lower.contains("nadi-shodhana")
            || lower.contains("respiration alternée") || lower.contains("respiration alternee")
            || lower.contains("alternate nostril") {
            return .nadiShodhana
        }
        // Story 3.23 Lot 6 — Ardha Chandrasana (demi-lune)
        if lower.contains("ardha chandrasana") || lower.contains("ardha-chandrasana")
            || lower.contains("demi-lune") || lower.contains("demi lune") || lower.contains("half moon") {
            return .ardhaChandrasana
        }
        // Story 3.23 Lot 6 — Sukhasana (assise en tailleur)
        // AVANT Sirsasana (mot "sirsasana" contient pas "sukha" donc OK).
        if lower.contains("sukhasana") || lower.contains("tailleur") || lower.contains("easy pose")
            || lower.contains("assise simple") {
            return .sukhasana
        }
        // Story 3.23 Lot 6 — Sirsasana (headstand) — APRÈS Janu Sirsasana
        // (déjà ordonné en Lot 4). Critique : "sirsasana" ne doit pas matcher "janu sirsasana".
        if lower.contains("sirsasana") || lower.contains("headstand") || lower.contains("équilibre tête")
            || lower.contains("equilibre tete") {
            return .sirsasana
        }
        // Party illustrations 2026-06-08 — asanas avancées (placées AVANT les catch génériques).
        if lower.contains("salabhasana") || lower.contains("sauterelle") || lower.contains("locust") { return .salabhasana }
        if lower.contains("ustrasana") || lower.contains("chameau") || lower.contains("camel") { return .ustrasana }
        // Dhanurasana (arc) — APRÈS urdhva dhanurasana (roue, déjà capté plus haut).
        if lower.contains("dhanurasana") || lower.contains("posture de l'arc") || lower.contains("bow pose") { return .dhanurasana }
        if lower.contains("phalakasana") || lower.contains("kumbhakasana") { return .phalakasana }
        if lower.contains("upavistha") { return .upavisthaKonasana }
        if lower.contains("bakasana") || lower.contains("crow") || lower.contains("corbeau") || lower.contains("corneille") { return .bakasana }
        if lower.contains("purvottanasana") || lower.contains("planche inversée") || lower.contains("planche inversee")
            || lower.contains("upward plank") || lower.contains("reverse plank") { return .purvottanasana }
        if lower.contains("uttana padasana") { return .uttanaPadasana }
        if lower.contains("prasarita") { return .prasaritaPadottanasana }
        if lower.contains("padahastasana") || lower.contains("mains sous") { return .padahastasana }
        // Ardha Matsyendrasana (torsion assise) — distinct de Matsyasana (poisson) et Ardha Chandrasana.
        if lower.contains("matsyendrasana") || lower.contains("demi-torsion") || lower.contains("seated twist")
            || lower.contains("torsion assise") { return .ardhaMatsyendrasana }
        if lower.contains("kapotasana") || lower.contains("pigeon royal") || lower.contains("king pigeon") { return .kapotasana }
        if lower.contains("bhujapidasana") || lower.contains("pression épaule") || lower.contains("pression epaule")
            || lower.contains("pression bras") || lower.contains("arm pressure") { return .bhujapidasana }
        if lower.contains("garbha") || lower.contains("kukkutasana") || lower.contains("embryon")
            || lower.contains("rooster") || lower.contains("coq") { return .garbhaPindasana }
        if lower.contains("karnapidasana") || lower.contains("genoux aux oreilles") || lower.contains("knees to ears") { return .karnapidasana }
        if lower.contains("utthita hasta") || lower.contains("hand to big toe") || lower.contains("main au gros orteil") { return .utthitaHastaPadangusthasana }
        if lower.contains("ardha baddha padmottanasana") || lower.contains("demi-lotus debout") { return .ardhaBaddhaPadmottanasana }

        if lower.contains("chien") || lower.contains("downward") || lower.contains("adho") { return .downwardDog }
        if lower.contains("guerrier 2") || lower.contains("guerrier ii") || lower.contains("warrior 2") || lower.contains("warrior ii") || lower.contains("virabhadrasana ii") { return .warrior2 }
        if lower.contains("guerrier") || lower.contains("warrior") || lower.contains("virabhadrasana") { return .warrior1 }
        if lower.contains("arbre") || lower.contains("tree") || lower.contains("vrksasana") { return .tree }
        if lower.contains("cobra") || lower.contains("bhujangasana") { return .cobra }
        if lower.contains("enfant") || lower.contains("child") || lower.contains("balasana") { return .child }
        if lower.contains("pince") || lower.contains("forward fold") || lower.contains("uttanasana") { return .forwardFold }
        if lower.contains("triangle") || lower.contains("trikonasana") { return .triangle }
        if lower.contains("bateau") || lower.contains("boat") || lower.contains("navasana") { return .boat }
        if lower.contains("savasana") || lower.contains("cadavre") || lower.contains("relaxation") { return .savasana }
        return .unknown
    }

    // MARK: - POC yoga (D1) — fallback orientation-aware

    /// Orientation générale d'une posture, pour choisir une silhouette générique
    /// quand la pose précise n'est pas reconnue (au lieu d'afficher Warrior I debout
    /// sur une posture couchée). Mots-clés SANSKRIT + FR + EN. Défaut = debout.
    private enum YogaOrientation { case lying, seated, standing }

    private var fallbackOrientation: YogaOrientation {
        guard let lower = exerciseName?.lowercased() else { return .standing }
        // Couché (sur le dos / le ventre, inversions au sol, backbends couchés).
        let lyingKeys = ["savasana", "supta", "jathara", "setu", "sarvangasana", "halasana",
                         "viparita", "matsyasana", "dhanurasana", "salabhasana", "bhujangasana",
                         "ananda balasana", "allongé", "allonge", "couché", "couche",
                         "sur le dos", "sur le ventre", "lying", "reclining", "supine", "prone"]
        // Assis / à genoux (postures au sol jambes pliées).
        let seatedKeys = ["sukhasana", "padmasana", "vajrasana", "dandasana", "paschimottanasana",
                          "konasana", "marichyasana", "navasana", "gomukhasana", "siddhasana",
                          "upavistha", "virasana", "agnistambhasana", "assis", "assise", "seated",
                          "tailleur", "lotus", "à genoux", "a genoux", "genoux", "kneeling"]
        if lyingKeys.contains(where: lower.contains) { return .lying }
        if seatedKeys.contains(where: lower.contains) { return .seated }
        return .standing
    }

    /// Silhouette générique COUCHÉE (sur le dos), vue de profil — neutre. Dessine
    /// une vraie personne allongée (tête, tronc, bras posé, jambe avec genou
    /// légèrement relevé, pied) pour NE PAS ressembler à une flèche.
    private func drawGenericLying(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let groundY: CGFloat = 42 * s
        let headX: CGFloat = 16 * s
        let headSize: CGFloat = 6 * s
        let hipX: CGFloat = 44 * s
        let kneeX: CGFloat = 54 * s
        let footX: CGFloat = 62 * s

        // Tête (à gauche, posée au sol)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: groundY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Tronc (nuque → hanche, posé au sol)
        var trunk = Path()
        trunk.move(to: CGPoint(x: headX + headSize / 2 + 1 * s, y: groundY))
        trunk.addLine(to: CGPoint(x: hipX, y: groundY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)
        // Jambe avec genou LÉGÈREMENT relevé puis pied au sol (signale une personne,
        // pas une simple barre/flèche).
        var leg = Path()
        leg.move(to: CGPoint(x: hipX, y: groundY))
        leg.addLine(to: CGPoint(x: kneeX, y: groundY - 6 * s))
        leg.addLine(to: CGPoint(x: footX, y: groundY))
        ctx.stroke(leg, with: .color(silhouette), style: stroke)
        // Bras posé le long du corps, NETTEMENT décalé sous le tronc (pas collé).
        var arm = Path()
        arm.move(to: CGPoint(x: headX + 6 * s, y: groundY + 3 * s))
        arm.addLine(to: CGPoint(x: hipX - 4 * s, y: groundY + 3 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Silhouette générique ASSISE (jambes croisées) — neutre.
    private func drawGenericSeated(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let hipY: CGFloat = 38 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 14 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Tronc droit vertical (épaules → hanche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 20 * s))
        trunk.addLine(to: CGPoint(x: cx, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)
        // Jambes croisées : triangle bas posé au sol (genoux écartés vers le sol)
        var legs = Path()
        legs.move(to: CGPoint(x: cx, y: hipY))
        legs.addLine(to: CGPoint(x: cx - 14 * s, y: 46 * s))
        legs.addLine(to: CGPoint(x: cx + 14 * s, y: 46 * s))
        legs.addLine(to: CGPoint(x: cx, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)
        // Bras posés sur les genoux
        var armL = Path()
        armL.move(to: CGPoint(x: cx, y: 24 * s))
        armL.addLine(to: CGPoint(x: cx - 11 * s, y: 44 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx, y: 24 * s))
        armR.addLine(to: CGPoint(x: cx + 11 * s, y: 44 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Silhouette générique DEBOUT (montagne) — neutre, bras le long du corps.
    private func drawGenericStanding(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let shoulderY: CGFloat = 14 * s
        let hipY: CGFloat = 30 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 6 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Tronc
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: shoulderY))
        trunk.addLine(to: CGPoint(x: cx, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)
        // Bras le long du corps
        var armL = Path()
        armL.move(to: CGPoint(x: cx, y: shoulderY + 1 * s))
        armL.addLine(to: CGPoint(x: cx - 6 * s, y: 28 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx, y: shoulderY + 1 * s))
        armR.addLine(to: CGPoint(x: cx + 6 * s, y: 28 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
        // Jambes (debout, légère séparation)
        var legL = Path()
        legL.move(to: CGPoint(x: cx, y: hipY))
        legL.addLine(to: CGPoint(x: cx - 4 * s, y: 46 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx, y: hipY))
        legR.addLine(to: CGPoint(x: cx + 4 * s, y: 46 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)
    }

    private var silhouette: Color { IllustrationStyle.silhouette(sportCode: sportCode) }
    private var annotation: Color { IllustrationStyle.movementArrow }

    // MARK: - Poses (toutes en coordonnées 80×48)

    /// Chien tête en bas — corps en V inversé. Mains côté droit (28-32), pieds côté gauche (48-52), fesses pointées vers le haut.
    private func drawDownwardDog(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let handX: CGFloat = 18 * s
        let handY: CGFloat = 46 * s
        let footX: CGFloat = 62 * s
        let footY: CGFloat = 46 * s
        let hipX: CGFloat = 40 * s
        let hipY: CGFloat = 10 * s // hauteur du sommet du V

        // Bras (poignet au sol → épaule)
        let shoulderX: CGFloat = 26 * s
        let shoulderY: CGFloat = 22 * s
        var arm = Path()
        arm.move(to: CGPoint(x: handX, y: handY))
        arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Tête (entre les bras, légèrement projetée vers le sol)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - 2 * s - headSize / 2, y: shoulderY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc épaule → hanche (au sommet du V)
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes hanche → pied
        var leg = Path()
        leg.move(to: CGPoint(x: hipX, y: hipY))
        leg.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(leg, with: .color(silhouette), style: stroke)

        // Annotation : ligne pointillée bras alignement (poignet → hanche)
        var alignment = Path()
        alignment.move(to: CGPoint(x: handX - 1 * s, y: handY - 2 * s))
        alignment.addLine(to: CGPoint(x: hipX + 1 * s, y: hipY - 3 * s))
        ctx.stroke(alignment, with: .color(annotation),
                   style: StrokeStyle(lineWidth: 1.2 * s, dash: [3 * s, 2 * s]))
    }

    /// Guerrier I — debout face caméra, fente, bras tendus vers le haut mains au ciel.
    private func drawWarrior1(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let topOfHeadY: CGFloat = 4 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 24 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe avant fléchie (pied avant sous la hanche)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 8 * s, y: 34 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 10 * s, y: 46 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière tendue (pied loin derrière)
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 14 * s, y: 46 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Bras tendus vers le HAUT (signature guerrier I)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: shoulderY))
        armL.addLine(to: CGPoint(x: centerX - 4 * s, y: 0))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: shoulderY))
        armR.addLine(to: CGPoint(x: centerX + 4 * s, y: 0))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Mains jointes au sommet (petit point)
        let handSize: CGFloat = 2 * s
        ctx.fill(
            Path(ellipseIn: CGRect(x: centerX - handSize / 2, y: 0, width: handSize, height: handSize)),
            with: .color(silhouette)
        )
    }

    /// Guerrier II — pose de face, fente, bras HORIZONTAUX écartés.
    private func drawWarrior2(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s
        let topOfHeadY: CGFloat = 10 * s
        let shoulderY: CGFloat = topOfHeadY + headSize
        let hipY: CGFloat = 28 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: topOfHeadY,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras HORIZONTAUX écartés (signature guerrier II)
        var arms = Path()
        arms.move(to: CGPoint(x: 18 * s, y: shoulderY + 1 * s))
        arms.addLine(to: CGPoint(x: 62 * s, y: shoulderY + 1 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)

        // Jambe avant fléchie (genou avant)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: centerX, y: hipY))
        frontLeg.addLine(to: CGPoint(x: centerX + 10 * s, y: 36 * s))
        frontLeg.addLine(to: CGPoint(x: centerX + 12 * s, y: 46 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière tendue
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: centerX, y: hipY))
        backLeg.addLine(to: CGPoint(x: centerX - 14 * s, y: 46 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)
    }

    /// Arbre — debout équilibre sur un pied, autre pied au genou, mains jointes au ciel.
    /// Arbre (Vrksasana) — refonte Story 3.23 Lot 1 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Vrikshasana
    /// Signature : genou TRÈS écarté + pied collé cuisse intérieure + mains
    /// jointes en losange au-dessus de la tête (coudes écartés).
    private func drawTree(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 24 * s
        let headSize: CGFloat = 6 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: 8 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc (épaules → hanche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: 14 * s))
        trunk.addLine(to: CGPoint(x: centerX, y: 26 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe d'appui (verticale, pied à plat au sol)
        var standLeg = Path()
        standLeg.move(to: CGPoint(x: centerX, y: 26 * s))
        standLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 36 * s))
        standLeg.addLine(to: CGPoint(x: centerX - 2 * s, y: 46 * s))
        ctx.stroke(standLeg, with: .color(silhouette), style: stroke)

        // Jambe pliée signature : genou très écarté + pied revient et S'APPUIE
        // sur la cuisse intérieure (petit marqueur horizontal explicite au contact).
        var foldedLeg = Path()
        foldedLeg.move(to: CGPoint(x: centerX, y: 26 * s))
        foldedLeg.addLine(to: CGPoint(x: centerX + 11 * s, y: 30 * s))
        foldedLeg.addLine(to: CGPoint(x: centerX - 1 * s, y: 36 * s))
        ctx.stroke(foldedLeg, with: .color(silhouette), style: stroke)

        // Marqueur pied posé sur cuisse intérieure (segment horizontal au contact)
        var footMark = Path()
        footMark.move(to: CGPoint(x: centerX - 3 * s, y: 36 * s))
        footMark.addLine(to: CGPoint(x: centerX, y: 36 * s))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Bras gauche en losange large (coude bien écarté pour visibilité)
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 2 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: centerX - 7 * s, y: 8 * s))
        armL.addLine(to: CGPoint(x: centerX - 1 * s, y: 1 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit en losange large
        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 2 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: centerX + 7 * s, y: 8 * s))
        armR.addLine(to: CGPoint(x: centerX + 1 * s, y: 1 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Marqueur mains jointes (petit segment horizontal au sommet du losange)
        var palms = Path()
        palms.move(to: CGPoint(x: centerX - 2 * s, y: 1 * s))
        palms.addLine(to: CGPoint(x: centerX + 2 * s, y: 1 * s))
        ctx.stroke(palms, with: .color(silhouette), style: stroke)
    }

    /// Cobra — allongé ventre au sol, buste relevé bras tendus, tête haute.
    private func drawCobra(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de profil. Pieds + jambes au sol (côté gauche), buste relevé (côté droit).
        let footX: CGFloat = 14 * s
        let footY: CGFloat = 44 * s
        let hipX: CGFloat = 36 * s
        let hipY: CGFloat = 44 * s
        let shoulderX: CGFloat = 56 * s
        let shoulderY: CGFloat = 30 * s
        let handX: CGFloat = 60 * s
        let handY: CGFloat = 46 * s

        // Jambes/bassin couché au sol
        var legs = Path()
        legs.move(to: CGPoint(x: footX, y: footY))
        legs.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc qui se relève en arc (de la hanche vers l'épaule en montant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addQuadCurve(to: CGPoint(x: shoulderX, y: shoulderY),
                           control: CGPoint(x: 50 * s, y: 30 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en haut du buste relevé, regard vers le haut-avant)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX + 2 * s - headSize / 2, y: shoulderY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus (épaule → main au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        arm.addLine(to: CGPoint(x: handX, y: handY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Enfant (Balasana) — refonte Story 3.23 Lot 1 v4 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Balasana
    /// Signature : silhouette agenouillée nettement visible (cuisses verticales
    /// repliées sur les talons + fessiers surélevés en arc + dos arrondi
    /// large + front au sol + bras tendus devant le long du sol).
    /// Refonte v4 : élévation fessiers + dos plus arrondi + bras DEVANT bien
    /// séparés du corps.
    private func drawChild(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, personnage face à gauche. Tibias+fesses côté droit, front+bras côté gauche.

        // Pied/talon (sous les fesses, côté droit) — segment au sol
        let footX: CGFloat = 50 * s
        let footY: CGFloat = 46 * s
        var footMark = Path()
        footMark.move(to: CGPoint(x: footX - 2 * s, y: footY))
        footMark.addLine(to: CGPoint(x: footX + 2 * s, y: footY))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Tibia plié au sol (talon vers genou — quasi horizontal)
        var shin = Path()
        shin.move(to: CGPoint(x: footX, y: footY))
        shin.addLine(to: CGPoint(x: 38 * s, y: 44 * s))
        ctx.stroke(shin, with: .color(silhouette), style: stroke)

        // Genou (segment vertical court)
        var knee = Path()
        knee.move(to: CGPoint(x: 38 * s, y: 44 * s))
        knee.addLine(to: CGPoint(x: 40 * s, y: 38 * s))
        ctx.stroke(knee, with: .color(silhouette), style: stroke)

        // Fesse SURÉLEVÉE (bosse haute signature)
        let buttX: CGFloat = 42 * s
        let buttY: CGFloat = 34 * s
        var thigh = Path()
        thigh.move(to: CGPoint(x: 40 * s, y: 38 * s))
        thigh.addLine(to: CGPoint(x: buttX, y: buttY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Tronc replié en arc DOS ARRONDI bien visible (quadCurve avec bosse haute)
        let shoulderX: CGFloat = 18 * s
        let shoulderY: CGFloat = 40 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addQuadCurve(to: CGPoint(x: shoulderX, y: shoulderY),
                           control: CGPoint(x: 30 * s, y: 26 * s))   // bosse dos haute
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au sol (front touche le sol par le bas)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 12 * s - headSize / 2, y: 42 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus DEVANT le long du sol (épaule → main loin devant, écarté
        // du corps pour différenciation visuelle vs tronc arc)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX - 2 * s, y: shoulderY + 1 * s))   // épaule
        arm.addLine(to: CGPoint(x: 12 * s, y: 45 * s))                       // coude au sol
        arm.addLine(to: CGPoint(x: 4 * s, y: 45 * s))                        // main tendue loin
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Pince debout — debout, buste plié vers les pieds, mains au sol.
    private func drawForwardFold(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let centerX: CGFloat = 40 * s
        let footX: CGFloat = centerX
        let footY: CGFloat = 46 * s
        let hipY: CGFloat = 22 * s

        // Jambes droites debout
        var legL = Path()
        legL.move(to: CGPoint(x: centerX, y: hipY))
        legL.addLine(to: CGPoint(x: footX - 2 * s, y: footY))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: centerX, y: hipY))
        legR.addLine(to: CGPoint(x: footX + 2 * s, y: footY))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Tronc PLIÉ vers les pieds (depuis la hanche, buste descend)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: hipY))
        trunk.addLine(to: CGPoint(x: centerX - 2 * s, y: 38 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en bas, près des pieds, vue tête vers le sol)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - 2 * s - headSize / 2, y: 38 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras pendants vers le sol (mains qui touchent les pieds)
        var arm = Path()
        arm.move(to: CGPoint(x: centerX - 3 * s, y: 40 * s))
        arm.addLine(to: CGPoint(x: centerX - 4 * s, y: 46 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Triangle — jambes très écartées, buste lateral, main basse au sol, main haute au ciel.
    private func drawTriangle(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de face. Jambes très écartées (V à l'envers).
        let centerX: CGFloat = 40 * s
        let footLX: CGFloat = 18 * s
        let footRX: CGFloat = 62 * s
        let hipX: CGFloat = centerX
        let hipY: CGFloat = 30 * s

        // Jambes écartées
        var legL = Path()
        legL.move(to: CGPoint(x: hipX, y: hipY))
        legL.addLine(to: CGPoint(x: footLX, y: 46 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        var legR = Path()
        legR.move(to: CGPoint(x: hipX, y: hipY))
        legR.addLine(to: CGPoint(x: footRX, y: 46 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Tronc incliné latéralement vers la jambe gauche (hanche → épaule à gauche-haut)
        let shoulderX: CGFloat = 24 * s
        let shoulderY: CGFloat = 18 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc incliné
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - 2 * s - headSize / 2, y: shoulderY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras VERTICAL (l'un vers le ciel, l'autre vers le sol — signature triangle)
        // Bras haut vers le ciel
        var armUp = Path()
        armUp.move(to: CGPoint(x: shoulderX, y: shoulderY))
        armUp.addLine(to: CGPoint(x: shoulderX, y: 0))
        ctx.stroke(armUp, with: .color(silhouette), style: stroke)

        // Bras bas vers le pied gauche (touche la cheville)
        var armDown = Path()
        armDown.move(to: CGPoint(x: shoulderX + 1 * s, y: shoulderY + 2 * s))
        armDown.addLine(to: CGPoint(x: footLX, y: 44 * s))
        ctx.stroke(armDown, with: .color(silhouette), style: stroke)
    }

    /// Bateau (Navasana) — refonte Story 3.23 Lot 1 (2026-05-25).
    /// Source : https://en.wikipedia.org/wiki/Navasana
    /// Signature : V franc avec sommet aux fesses (pivot bas-centre), jambes
    /// montent à droite, tronc monte à gauche, bras horizontaux séparés des jambes.
    private func drawBoat(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, fesses pivot au sol au centre. Coords contraintes au viewbox 48×48.

        // Fesses pivot (point bas du V, au sol)
        let buttX: CGFloat = 24 * s
        let buttY: CGFloat = 42 * s

        // Jambes tendues vers le haut-droite (montée à ~55°)
        let feetX: CGFloat = 44 * s
        let feetY: CGFloat = 12 * s
        var legs = Path()
        legs.move(to: CGPoint(x: buttX, y: buttY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Petit marqueur pied perpendiculaire à la jambe (signature cheville)
        var footMark = Path()
        footMark.move(to: CGPoint(x: feetX, y: feetY))
        footMark.addLine(to: CGPoint(x: 46 * s, y: 14 * s))
        ctx.stroke(footMark, with: .color(silhouette), style: stroke)

        // Tronc incliné vers le haut-gauche (montée symétrique ~55°)
        let shoulderX: CGFloat = 8 * s
        let shoulderY: CGFloat = 14 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (en haut-gauche)
        let headSize: CGFloat = 6 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 6 * s - headSize / 2, y: 10 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus quasi-horizontaux pointant vers les chevilles
        // (épaule au tronc → main qui rejoint l'aire des pieds, gap vertical
        // avec les jambes pour ne pas se confondre)
        var arms = Path()
        arms.move(to: CGPoint(x: 10 * s, y: 16 * s))
        arms.addLine(to: CGPoint(x: 38 * s, y: 14 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)
    }

    /// Savasana — allongé sur le dos, bras le long du corps, pieds tombants.
    private func drawSavasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de dessus stylisée — silhouette HORIZONTALE allongée au sol.
        let headX: CGFloat = 14 * s
        let headY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s
        let footX: CGFloat = 66 * s
        let footY: CGFloat = 42 * s

        // Tête à gauche (cercle)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Corps allongé (épaule → pied)
        var body = Path()
        body.move(to: CGPoint(x: headX + headSize / 2 + 1 * s, y: headY))
        body.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(body, with: .color(silhouette), style: stroke)

        // Bras le long du corps (légèrement décalés en y)
        var armL = Path()
        armL.move(to: CGPoint(x: headX + 6 * s, y: headY - 1 * s))
        armL.addLine(to: CGPoint(x: headX + 22 * s, y: headY - 2 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: headX + 6 * s, y: headY + 1 * s))
        armR.addLine(to: CGPoint(x: headX + 22 * s, y: headY + 2 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Pieds tombants (petits chevrons V sur le côté droit, suggèrent les pieds tournés vers l'extérieur)
        var feet = Path()
        feet.move(to: CGPoint(x: footX, y: footY - 3 * s))
        feet.addLine(to: CGPoint(x: footX + 4 * s, y: footY))
        feet.addLine(to: CGPoint(x: footX, y: footY + 3 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Annotation : petits Z stylisés au-dessus de la tête (relaxation)
        var z = Path()
        z.move(to: CGPoint(x: headX - 4 * s, y: 32 * s))
        z.addLine(to: CGPoint(x: headX, y: 32 * s))
        z.addLine(to: CGPoint(x: headX - 4 * s, y: 36 * s))
        z.addLine(to: CGPoint(x: headX, y: 36 * s))
        ctx.stroke(z, with: .color(annotation),
                   style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round))
    }

    // MARK: - Story 3.23 Tier 1 Jalon 1 — Dirgha + Cat-cow

    /// Dirgha pranayama — REFONDU P0 (review agent 2026-05-25) :
    /// silhouette debout VUE DE FACE avec 3 zones d'expansion respiratoire
    /// empilées verticalement (clavicules en haut, thorax au milieu, ventre en bas).
    /// Tailles croissantes du haut vers le bas symbolisent l'amplitude d'expansion
    /// (le ventre est la plus grande zone diaphragmatique).
    /// **Différenciation Ujjayi** : Dirgha = debout face avec 3 zones torse,
    /// Ujjayi = assise jambes croisées avec cercle souffle à la gorge.
    /// Réf : Iyengar "Light on Pranayama" — 3-part breath, conscience verticale
    /// des zones abdomen/thorax/clavicule.
    private func drawDirgha(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s

        // Tête (centrée)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 6 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        // Cou
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 12 * s))
        neck.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Épaules (largeur du torse en haut)
        var shoulders = Path()
        shoulders.move(to: CGPoint(x: 32 * s, y: 14 * s))
        shoulders.addLine(to: CGPoint(x: 48 * s, y: 14 * s))
        ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

        // Tronc — trapèze fermé (épaules larges, hanches plus étroites)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 32 * s, y: 14 * s))
        trunk.addLine(to: CGPoint(x: 35 * s, y: 38 * s))   // hanche gauche
        trunk.addLine(to: CGPoint(x: 45 * s, y: 38 * s))   // hanche droite
        trunk.addLine(to: CGPoint(x: 48 * s, y: 14 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // 2 bras le long du corps
        var armL = Path()
        armL.move(to: CGPoint(x: 32 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: 28 * s, y: 32 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: 48 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: 52 * s, y: 32 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // 2 jambes (légère séparation au sol)
        var legL = Path()
        legL.move(to: CGPoint(x: 35 * s, y: 38 * s))
        legL.addLine(to: CGPoint(x: 33 * s, y: 46 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: 45 * s, y: 38 * s))
        legR.addLine(to: CGPoint(x: 47 * s, y: 46 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds
        var feet = Path()
        feet.move(to: CGPoint(x: 30 * s, y: 46 * s))
        feet.addLine(to: CGPoint(x: 36 * s, y: 46 * s))
        feet.move(to: CGPoint(x: 44 * s, y: 46 * s))
        feet.addLine(to: CGPoint(x: 50 * s, y: 46 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // === 3 zones d'expansion respiratoire EMPILÉES VERTICALEMENT ===
        // Ellipses horizontales de tailles CROISSANTES du haut vers le bas
        // (symbolise : clavicules = petite expansion, ventre = grosse expansion).
        let zoneStroke = StrokeStyle(lineWidth: 1.3 * s, lineCap: .round)

        // Zone 1 — Clavicules (en haut, petite ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 4 * s, y: 18 * s - 1 * s,
                                    width: 8 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )
        // Zone 2 — Thorax (milieu, moyenne ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 6 * s, y: 25 * s - 1 * s,
                                    width: 12 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )
        // Zone 3 — Ventre (en bas, grande ellipse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 8 * s, y: 33 * s - 1 * s,
                                    width: 16 * s, height: 2 * s)),
            with: .color(annotation), style: zoneStroke
        )

        // Flèche d'inspiration ↓ à droite (l'air descend dans les poumons)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var inhaleArrow = Path()
        inhaleArrow.move(to: CGPoint(x: 60 * s, y: 16 * s))
        inhaleArrow.addLine(to: CGPoint(x: 60 * s, y: 34 * s))
        inhaleArrow.move(to: CGPoint(x: 58 * s, y: 32 * s))
        inhaleArrow.addLine(to: CGPoint(x: 60 * s, y: 34 * s))
        inhaleArrow.addLine(to: CGPoint(x: 62 * s, y: 32 * s))
        ctx.stroke(inhaleArrow, with: .color(annotation), style: arrowStyle)
    }

    /// Cat-cow (Marjaryasana-Bitilasana) — 2 mini-silhouettes 4-pattes profil
    /// côte à côte : Cat (dos rond, tête baissée) à gauche, Cow (dos creux,
    /// tête relevée) à droite, séparées par une flèche ↔ alternance orange.
    ///
    /// **Référence anatomique** (Wikipedia Marjariasana + canon yoga) :
    /// - Cat = flexion vertébrale : dos arrondi en arc CONVEXE vers le ciel,
    ///   bassin en rétroversion (queue rentrée), tête baissée menton-poitrine.
    /// - Cow = extension vertébrale : dos creux en arc CONCAVE (ventre tombe),
    ///   bassin en antéversion (ischions hauts), tête relevée regard haut.
    /// - Position commune : mains sous les épaules, genoux sous les hanches,
    ///   verticalité bras + cuisses.
    ///
    /// `forearms == true` : variante avec avant-bras au sol au lieu des mains
    /// (= bras pliés à 90°, coude sous l'épaule, avant-bras horizontal au sol).
    private func drawCatCow(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, forearms: Bool) {
        // Cat à gauche (zone x [4-36], centre cx=20), Cow à droite (zone x [44-76], centre cx=60)
        drawCatPhase(ctx, s: s, stroke: stroke, originCx: 20, forearms: forearms)
        drawCowPhase(ctx, s: s, stroke: stroke, originCx: 60, forearms: forearms)

        // Flèche ↔ centrale (annotation alternance entre Cat et Cow)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow = Path()
        // Trait horizontal au milieu
        arrow.move(to: CGPoint(x: 36 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 44 * s, y: 24 * s))
        // Chevron gauche (pointe vers Cat)
        arrow.move(to: CGPoint(x: 38 * s, y: 22 * s))
        arrow.addLine(to: CGPoint(x: 36 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 38 * s, y: 26 * s))
        // Chevron droit (pointe vers Cow)
        arrow.move(to: CGPoint(x: 42 * s, y: 22 * s))
        arrow.addLine(to: CGPoint(x: 44 * s, y: 24 * s))
        arrow.addLine(to: CGPoint(x: 42 * s, y: 26 * s))
        ctx.stroke(arrow, with: .color(annotation), style: arrowStyle)
    }

    /// Cat phase — dos rond CONVEXE, tête baissée. Centre `originCx` (4-36 ou 44-76).
    private func drawCatPhase(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originCx: CGFloat, forearms: Bool) {
        // Articulations clés (coordonnées canvas 80×48)
        let handX: CGFloat = (originCx - 10) * s   // ex Cat: 10
        let kneeX: CGFloat = (originCx + 8) * s    // ex Cat: 28
        let shoulderX: CGFloat = (originCx - 8) * s // ex Cat: 12
        let hipX: CGFloat = (originCx + 6) * s     // ex Cat: 26
        let shoulderY: CGFloat = 30 * s
        let hipY: CGFloat = 30 * s

        // Bras / avant-bras
        if forearms {
            // **REFONDU P0** — différenciation Cat-cow standard vs avant-bras :
            // avant-bras long et bien visible au sol + cercle accentuant le coude.
            // Avant-bras au sol : coude sous l'épaule, main devant.
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            // Avant-bras au sol (trait épaissi pour signature)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s * 1.3, lineCap: .round))
            // Cercle accentuant le coude (signature variante avant-bras)
            let elbowSize: CGFloat = 2.5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: elbowX - elbowSize / 2, y: 46 * s - elbowSize,
                                        width: elbowSize, height: elbowSize)),
                with: .color(silhouette), style: stroke
            )
        } else {
            // Mains au sol (bras quasi-verticaux)
            var arm = Path()
            arm.move(to: CGPoint(x: handX, y: 46 * s))
            arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)
        }

        // Cuisses (genou au sol → hanche)
        var thigh = Path()
        thigh.move(to: CGPoint(x: kneeX, y: 46 * s))
        thigh.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Dos CONVEXE (bombé vers le HAUT) — addQuadCurve avec control point au-dessus
        let backControlX: CGFloat = (originCx - 1) * s  // milieu épaule-hanche
        let backControlY: CGFloat = 22 * s              // au-dessus de la ligne épaule-hanche
        var back = Path()
        back.move(to: CGPoint(x: shoulderX, y: shoulderY))
        back.addQuadCurve(to: CGPoint(x: hipX, y: hipY),
                          control: CGPoint(x: backControlX, y: backControlY))
        ctx.stroke(back, with: .color(silhouette), style: stroke)

        // Cou descend en bas-gauche (tête baissée, menton-poitrine)
        let neckEndX: CGFloat = (originCx - 12) * s  // ex Cat: 8
        let neckEndY: CGFloat = 35 * s
        var neck = Path()
        neck.move(to: CGPoint(x: shoulderX, y: shoulderY))
        neck.addLine(to: CGPoint(x: neckEndX, y: neckEndY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tête baissée (cercle sous le cou)
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: neckEndX - headSize / 2 - 1 * s, y: neckEndY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Orteils repliés derrière les genoux
        var toes = Path()
        toes.move(to: CGPoint(x: kneeX, y: 46 * s))
        toes.addLine(to: CGPoint(x: kneeX + 4 * s, y: 46 * s))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)
    }

    /// Cow phase — dos creux CONCAVE, tête relevée. Centre `originCx`.
    private func drawCowPhase(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originCx: CGFloat, forearms: Bool) {
        let handX: CGFloat = (originCx - 10) * s
        let kneeX: CGFloat = (originCx + 8) * s
        let shoulderX: CGFloat = (originCx - 8) * s
        let hipX: CGFloat = (originCx + 6) * s
        let shoulderY: CGFloat = 30 * s
        let hipY: CGFloat = 30 * s

        // Bras / avant-bras (idem Cat — même signature avant-bras avec cercle coude)
        if forearms {
            let elbowX: CGFloat = shoulderX
            var armUpper = Path()
            armUpper.move(to: CGPoint(x: shoulderX, y: shoulderY))
            armUpper.addLine(to: CGPoint(x: elbowX, y: 46 * s))
            ctx.stroke(armUpper, with: .color(silhouette), style: stroke)
            // Avant-bras au sol (épaissi)
            var forearmPath = Path()
            forearmPath.move(to: CGPoint(x: elbowX, y: 46 * s))
            forearmPath.addLine(to: CGPoint(x: handX, y: 46 * s))
            ctx.stroke(forearmPath, with: .color(silhouette),
                       style: StrokeStyle(lineWidth: IllustrationStyle.strokeWidth * s * 1.3, lineCap: .round))
            // Cercle coude
            let elbowSize: CGFloat = 2.5 * s
            ctx.stroke(
                Path(ellipseIn: CGRect(x: elbowX - elbowSize / 2, y: 46 * s - elbowSize,
                                        width: elbowSize, height: elbowSize)),
                with: .color(silhouette), style: stroke
            )
        } else {
            var arm = Path()
            arm.move(to: CGPoint(x: handX, y: 46 * s))
            arm.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
            ctx.stroke(arm, with: .color(silhouette), style: stroke)
        }

        // Cuisses
        var thigh = Path()
        thigh.move(to: CGPoint(x: kneeX, y: 46 * s))
        thigh.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Dos CONCAVE (creusé vers le BAS) — control point en-dessous de la ligne
        let backControlX: CGFloat = (originCx - 1) * s
        let backControlY: CGFloat = 38 * s  // sous la ligne épaule-hanche (qui est à y=30)
        var back = Path()
        back.move(to: CGPoint(x: shoulderX, y: shoulderY))
        back.addQuadCurve(to: CGPoint(x: hipX, y: hipY),
                          control: CGPoint(x: backControlX, y: backControlY))
        ctx.stroke(back, with: .color(silhouette), style: stroke)

        // Cou remonte en haut-gauche (tête relevée, regard vers le haut)
        let neckEndX: CGFloat = (originCx - 12) * s
        let neckEndY: CGFloat = 24 * s
        var neck = Path()
        neck.move(to: CGPoint(x: shoulderX, y: shoulderY))
        neck.addLine(to: CGPoint(x: neckEndX, y: neckEndY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tête relevée (cercle au-dessus du cou)
        let headSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: neckEndX - headSize / 2 - 1 * s, y: neckEndY - headSize - 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Orteils repliés derrière les genoux
        var toes = Path()
        toes.move(to: CGPoint(x: kneeX, y: 46 * s))
        toes.addLine(to: CGPoint(x: kneeX + 4 * s, y: 46 * s))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)
    }

    // MARK: - Story 3.23 Tier 1 Jalon 3 — 4 poses haute fréquence

    /// Sarvangasana (Chandelle / Shoulderstand) — refondu (review agent expert).
    /// **Signature inversion** : 2 flèches orange ↑ pieds + ↓ tête (sinon
    /// la pose ressemble à un "?", surtout pour novice qui ne connaît pas).
    /// Bras de support en V propre (épaule → coude au sol → main qui remonte
    /// sur le bas du dos), pas un Z parasite.
    /// Réf : Wikipedia Sarvangasana — "legs straightened to a vertical position,
    /// back supported by hands".
    private func drawSarvangasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 5 * s
        let headX: CGFloat = 14 * s
        let headY: CGFloat = 43 * s  // tête sur le sol

        // Tête (posée sur le sol pointillé)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou + épaule (épaules sur le sol, juste à droite de la tête)
        let shoulderX: CGFloat = 22 * s
        let shoulderY: CGFloat = 43 * s
        var neck = Path()
        neck.move(to: CGPoint(x: headX + headSize / 2, y: headY))
        neck.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Dos PARFAITEMENT vertical (signature chandelle)
        let hipX: CGFloat = shoulderX
        let hipY: CGFloat = 24 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes verticales (hanche → pieds vers le haut)
        let feetX: CGFloat = hipX
        let feetY: CGFloat = 6 * s
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: feetX, y: feetY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Orteils horizontaux (signature pieds en haut)
        var toes = Path()
        toes.move(to: CGPoint(x: feetX - 3 * s, y: feetY))
        toes.addLine(to: CGPoint(x: feetX + 3 * s, y: feetY))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)

        // Bras de support : V propre (épaule → coude au sol → main remontant sur le dos)
        var supportArm = Path()
        supportArm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        supportArm.addLine(to: CGPoint(x: shoulderX + 5 * s, y: 44 * s))   // coude sur le sol
        supportArm.addLine(to: CGPoint(x: shoulderX + 1.5 * s, y: 34 * s)) // main remonte sur le bas du dos
        ctx.stroke(supportArm, with: .color(silhouette), style: stroke)

        // **Annotation INVERSION** : flèche orange ↑ aux pieds (signal "tête en bas")
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var feetArrow = Path()
        feetArrow.move(to: CGPoint(x: feetX + 6 * s, y: feetY + 6 * s))
        feetArrow.addLine(to: CGPoint(x: feetX + 6 * s, y: feetY))
        feetArrow.move(to: CGPoint(x: feetX + 4 * s, y: feetY + 2 * s))
        feetArrow.addLine(to: CGPoint(x: feetX + 6 * s, y: feetY))
        feetArrow.addLine(to: CGPoint(x: feetX + 8 * s, y: feetY + 2 * s))
        ctx.stroke(feetArrow, with: .color(annotation), style: arrowStyle)
    }

    /// Setu Bandha (Pont fessier yoga) — allongée sur le dos, genoux pliés,
    /// pieds au sol, bassin levé. Distinct du Hip Thrust strength (pas de banc).
    /// Réf : Yoga Journal Bridge Pose.
    private func drawSetuBandha(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Tête au sol côté gauche
        let headX: CGFloat = 12 * s
        let headY: CGFloat = 42 * s
        let headSize: CGFloat = 5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Épaules au sol (droite de la tête) — sur le sol pointillé (y=44)
        let shoulderX: CGFloat = 20 * s
        let shoulderY: CGFloat = 44 * s

        // Pieds au sol côté droit
        let footX: CGFloat = 60 * s
        let footY: CGFloat = 46 * s

        // Genoux levés au-dessus des pieds
        let kneeX: CGFloat = footX - 2 * s
        let kneeY: CGFloat = 30 * s

        // Bassin (hanche) levé en pont — refonte review agent : plus haut pour
        // arc franc visible (était 26, mou) → 20.
        let hipX: CGFloat = 42 * s
        let hipY: CGFloat = 20 * s

        // Tronc (épaule → hanche en montant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: shoulderY))
        trunk.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Cuisses (hanche → genou) — quasi horizontales
        var thigh = Path()
        thigh.move(to: CGPoint(x: hipX, y: hipY))
        thigh.addLine(to: CGPoint(x: kneeX, y: kneeY))
        ctx.stroke(thigh, with: .color(silhouette), style: stroke)

        // Tibias (genou → pied)
        var shin = Path()
        shin.move(to: CGPoint(x: kneeX, y: kneeY))
        shin.addLine(to: CGPoint(x: footX, y: footY))
        ctx.stroke(shin, with: .color(silhouette), style: stroke)

        // Bras le long du corps au sol (épaule → main au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX + 2 * s, y: shoulderY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 14 * s, y: 46 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Annotation : flèche ↑ au-dessus du bassin (contraction)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow = Path()
        arrow.move(to: CGPoint(x: hipX, y: hipY + 2 * s))
        arrow.addLine(to: CGPoint(x: hipX, y: hipY - 6 * s))
        arrow.move(to: CGPoint(x: hipX - 2 * s, y: hipY - 4 * s))
        arrow.addLine(to: CGPoint(x: hipX, y: hipY - 6 * s))
        arrow.addLine(to: CGPoint(x: hipX + 2 * s, y: hipY - 4 * s))
        ctx.stroke(arrow, with: .color(annotation), style: arrowStyle)
    }

    /// Ujjayi (souffle océan) — assise jambes croisées, annotation cercle
    /// souffle autour du cou/gorge (zone de contraction du souffle océan).
    /// Réf : Yoga Journal Ujjayi.
    private func drawUjjayi(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue face (silhouette assise vue de devant)
        let centerX: CGFloat = 40 * s
        let hipY: CGFloat = 38 * s

        // Tête (face)
        let headSize: CGFloat = 6 * s
        let headY: CGFloat = 14 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - headSize / 2, y: headY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc (épaule → hanche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: centerX, y: headY + headSize / 2))
        trunk.addLine(to: CGPoint(x: centerX, y: hipY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras pliés posés sur les genoux (refonte review agent — signature
        // méditation Sukhasana, pas une croix). Épaule → coude descendant +
        // avant-bras horizontal posé sur le genou.
        var armL = Path()
        armL.move(to: CGPoint(x: centerX - 1 * s, y: 22 * s))    // épaule gauche
        armL.addLine(to: CGPoint(x: centerX - 8 * s, y: 32 * s)) // coude (au-dessus du genou gauche)
        armL.addLine(to: CGPoint(x: centerX - 4 * s, y: 36 * s)) // main au repos sur le genou
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        var armR = Path()
        armR.move(to: CGPoint(x: centerX + 1 * s, y: 22 * s))
        armR.addLine(to: CGPoint(x: centerX + 8 * s, y: 32 * s))
        armR.addLine(to: CGPoint(x: centerX + 4 * s, y: 36 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Jambes croisées (Sukhasana) — 2 V de chaque côté
        var legL = Path()
        legL.move(to: CGPoint(x: centerX, y: hipY))
        legL.addLine(to: CGPoint(x: centerX - 14 * s, y: 44 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: centerX, y: hipY))
        legR.addLine(to: CGPoint(x: centerX + 14 * s, y: 44 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds croisés au centre (petite ligne horizontale)
        var feet = Path()
        feet.move(to: CGPoint(x: centerX - 8 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: centerX + 8 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Annotation : cercle souffle autour de la gorge (signature Ujjayi)
        let breathCircleY: CGFloat = 20 * s
        let breathRadius: CGFloat = 5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: centerX - breathRadius, y: breathCircleY - breathRadius,
                                    width: breathRadius * 2, height: breathRadius * 2)),
            with: .color(annotation),
            style: StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, dash: [2 * s, 1.5 * s])
        )
        // Flèche d'entrée souffle (côté gauche du cercle)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var inhale = Path()
        inhale.move(to: CGPoint(x: centerX - 12 * s, y: breathCircleY))
        inhale.addLine(to: CGPoint(x: centerX - 6 * s, y: breathCircleY))
        inhale.move(to: CGPoint(x: centerX - 8 * s, y: breathCircleY - 1.5 * s))
        inhale.addLine(to: CGPoint(x: centerX - 6 * s, y: breathCircleY))
        inhale.addLine(to: CGPoint(x: centerX - 8 * s, y: breathCircleY + 1.5 * s))
        ctx.stroke(inhale, with: .color(annotation), style: arrowStyle)
    }

    /// Surya Namaskar A — 3 mini-silhouettes côte à côte représentant
    /// l'essence du flow : Tadasana → Uttanasana → Chaturanga.
    /// Forme condensée car séquence 12 postures non visualisable en 1 frame.
    /// Réf : Yoga Journal Sun Salutation A.
    private func drawSuryaNamaskarA(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // 3 zones côte à côte : x=[2-26] | [28-52] | [54-78]
        // 1. Tadasana (debout)
        drawMiniTadasana(ctx, s: s, stroke: stroke, originX: 4)
        // 2. Uttanasana (plié avant)
        drawMiniUttanasana(ctx, s: s, stroke: stroke, originX: 28)
        // 3. Chaturanga (plank bas)
        drawMiniChaturanga(ctx, s: s, stroke: stroke, originX: 52)

        // 2 flèches entre les mini-poses (référentiel : la séquence se déroule)
        let arrowStyle = StrokeStyle(lineWidth: 1.2 * s, lineCap: .round, lineJoin: .round)
        var arrow1 = Path()
        arrow1.move(to: CGPoint(x: 25 * s, y: 24 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 24 * s))
        arrow1.move(to: CGPoint(x: 26.5 * s, y: 22.5 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 24 * s))
        arrow1.addLine(to: CGPoint(x: 26.5 * s, y: 25.5 * s))
        ctx.stroke(arrow1, with: .color(annotation), style: arrowStyle)

        var arrow2 = Path()
        arrow2.move(to: CGPoint(x: 50 * s, y: 24 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 24 * s))
        arrow2.move(to: CGPoint(x: 51.5 * s, y: 22.5 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 24 * s))
        arrow2.addLine(to: CGPoint(x: 51.5 * s, y: 25.5 * s))
        ctx.stroke(arrow2, with: .color(annotation), style: arrowStyle)
    }

    /// drawMiniTadasana — silhouette debout COMPLÈTE refondue (review agent expert) :
    /// tête + cou + tronc + 2 jambes distinctes + 2 bras + 2 pieds horizontaux.
    /// Réf : Wikipedia Tadasana (Mountain Pose) — pieds joints/parallèles,
    /// bras le long du corps, posture neutre.
    private func drawMiniTadasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête + cou
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 8 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 12 * s))
        neck.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tronc
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 14 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 28 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // 2 jambes distinctes (V léger pour signature)
        var legL = Path()
        legL.move(to: CGPoint(x: cx, y: 28 * s))
        legL.addLine(to: CGPoint(x: cx - 1.5 * s, y: 44 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx, y: 28 * s))
        legR.addLine(to: CGPoint(x: cx + 1.5 * s, y: 44 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // 2 pieds horizontaux (signature pieds au sol — "pieds parallèles" Tadasana)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 3 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx - 0.5 * s, y: 44 * s))
        feet.move(to: CGPoint(x: cx + 0.5 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx + 3 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // 2 bras le long du corps (signature posture neutre)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 15 * s))
        armL.addLine(to: CGPoint(x: cx - 3 * s, y: 28 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 15 * s))
        armR.addLine(to: CGPoint(x: cx + 3 * s, y: 28 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// drawMiniUttanasana — pliée en deux refondue (review agent expert) :
    /// jambes verticales + tronc HORIZONTAL plongeant vers les pieds + tête près
    /// du sol + bras pendants. Anciennement le tronc et les jambes étaient
    /// superposés sur le même axe vertical (illisible).
    /// Réf : Wikipedia Uttanasana — flexion avant debout, mains vers les pieds.
    private func drawMiniUttanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let footY: CGFloat = 44 * s
        let hipY: CGFloat = 22 * s   // hanche en haut = pliure de la pose
        let headSize: CGFloat = 4 * s

        // Jambes verticales (pieds au sol → hanche en haut)
        var legs = Path()
        legs.move(to: CGPoint(x: cx, y: footY))
        legs.addLine(to: CGPoint(x: cx, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pieds horizontaux
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 3 * s, y: footY))
        feet.addLine(to: CGPoint(x: cx + 3 * s, y: footY))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc PLIÉ vers l'avant (hanche → épaule à l'horizontale vers la gauche)
        let shoulderX = cx - 6 * s
        let shoulderY: CGFloat = hipY + 4 * s  // tronc plonge vers le sol
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête PRÈS DES PIEDS (au-dessus du sol, devant les tibias)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - headSize - 1 * s, y: shoulderY + 1 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras pendants vers le sol depuis l'épaule
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX, y: footY - 2 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// drawMiniChaturanga — planche basse refondue (review agent expert) :
    /// corps HORIZONTAL proche du sol (y=36), coudes pliés ~90° sous les épaules,
    /// pieds au sol côté droit. Anciennement les jambes plongeaient vers le sol
    /// (ressemblait à un chien tête en bas).
    /// Réf : Wikipedia Chaturanga Dandasana — planche basse, coudes près du corps.
    private func drawMiniChaturanga(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let bodyY: CGFloat = 36 * s   // corps proche du sol
        let footY: CGFloat = 38 * s
        let groundY: CGFloat = 44 * s
        let headSize: CGFloat = 4 * s

        // Tête côté gauche (regard vers le sol)
        let headCx = (originX + 4) * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headCx - headSize / 2, y: bodyY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc HORIZONTAL (épaule côté gauche → hanche côté droit)
        let shoulderX = (originX + 6) * s
        let hipX = (originX + 16) * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: shoulderX, y: bodyY))
        trunk.addLine(to: CGPoint(x: hipX, y: bodyY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes (hanche → pied légèrement plus bas = pieds au sol)
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: bodyY))
        legs.addLine(to: CGPoint(x: (originX + 22) * s, y: footY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Petits orteils (signature pieds au sol)
        var toes = Path()
        toes.move(to: CGPoint(x: (originX + 22) * s, y: footY))
        toes.addLine(to: CGPoint(x: (originX + 23) * s, y: groundY))
        ctx.stroke(toes, with: .color(silhouette), style: stroke)

        // Bras pliés à 90° sous les épaules (signature chaturanga)
        // épaule → coude (au sol) → main (au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: bodyY + 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 2 * s, y: groundY - 1 * s))
        arm.addLine(to: CGPoint(x: shoulderX, y: groundY))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    // MARK: - Story 3.23 Lot 2 (haute fréquence)

    /// Padangusthasana (flexion gros orteil debout) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Padangusthasana
    /// Signature : pli hanche net en L inversé (tronc HORIZONTAL plié, jambes
    /// verticales) + bras DESCENDANT VERTICAL séparés du corps avec mains aux orteils.
    /// Vue profil personnage face à droite (regard vers les pieds).
    private func drawPadangusthasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil. Pieds à droite, tronc plié vers la droite.
        let footX: CGFloat = 50 * s
        let footY: CGFloat = 44 * s
        let hipX: CGFloat = footX   // hanche à l'aplomb du pied (jambes verticales)
        let hipY: CGFloat = 22 * s
        let headSize: CGFloat = 6 * s

        // Pieds joints (segment horizontal au sol)
        var feet = Path()
        feet.move(to: CGPoint(x: footX - 4 * s, y: footY))
        feet.addLine(to: CGPoint(x: footX + 4 * s, y: footY))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Jambes verticales tendues (cheville → hanche)
        var legs = Path()
        legs.move(to: CGPoint(x: footX, y: footY))
        legs.addLine(to: CGPoint(x: hipX, y: hipY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc HORIZONTAL plié (hanche → épaule vers la gauche)
        // Forme un L inversé bien visible avec les jambes verticales.
        let shoulderX: CGFloat = 30 * s
        let shoulderY: CGFloat = 22 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (regard vers le bas)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX - headSize, y: shoulderY + 2 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus VERTICAL vers les pieds (épaule → main au pied)
        // Bien séparés du tronc pour visibilité.
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX + 4 * s, y: shoulderY + 2 * s))
        arm.addLine(to: CGPoint(x: shoulderX + 6 * s, y: 32 * s))   // coude vertical
        arm.addLine(to: CGPoint(x: hipX - 4 * s, y: footY - 2 * s)) // main au pied
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Marqueur crochet main-orteil (mini cercle signature agrippement)
        let graspSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: hipX - 5.5 * s, y: footY - 3.5 * s,
                                    width: graspSize, height: graspSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Surya Namaskar B — 3 mini-poses : Tadasana → Utkatasana (chaise) → Virabhadrasana I.
    /// Source : https://en.wikipedia.org/wiki/Surya_Namaskar
    /// Signature B vs A : la chaise (Utkatasana) au centre — pas dans Surya A.
    private func drawSuryaNamaskarB(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // 3 zones côte à côte : x=[2-26] | [28-52] | [54-78] — convention Surya A.
        drawMiniTadasana(ctx, s: s, stroke: stroke, originX: 4)
        drawMiniUtkatasana(ctx, s: s, stroke: stroke, originX: 28)
        drawMiniWarrior1Mini(ctx, s: s, stroke: stroke, originX: 52)

        // 2 flèches ÉPAISSIES + remontées pour signal progression visible à
        // small size (review novice Story 3.23 Lot 1+2+3).
        let arrowStyle = StrokeStyle(lineWidth: 2 * s, lineCap: .round, lineJoin: .round)
        var arrow1 = Path()
        arrow1.move(to: CGPoint(x: 24 * s, y: 16 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 16 * s))
        arrow1.move(to: CGPoint(x: 26 * s, y: 14 * s))
        arrow1.addLine(to: CGPoint(x: 28 * s, y: 16 * s))
        arrow1.addLine(to: CGPoint(x: 26 * s, y: 18 * s))
        ctx.stroke(arrow1, with: .color(annotation), style: arrowStyle)

        var arrow2 = Path()
        arrow2.move(to: CGPoint(x: 49 * s, y: 16 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 16 * s))
        arrow2.move(to: CGPoint(x: 51 * s, y: 14 * s))
        arrow2.addLine(to: CGPoint(x: 53 * s, y: 16 * s))
        arrow2.addLine(to: CGPoint(x: 51 * s, y: 18 * s))
        ctx.stroke(arrow2, with: .color(annotation), style: arrowStyle)
    }

    /// drawMiniUtkatasana — chaise (genoux pliés ~45°, hanche reculée, bras au-dessus).
    private func drawMiniUtkatasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc penché légèrement avant (hanche reculée à gauche, épaule devant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))     // hanche reculée
        trunk.addLine(to: CGPoint(x: cx, y: 14 * s))            // épaule centre
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe (hanche reculée → genou plié vers l'avant → pied au sol)
        var leg = Path()
        leg.move(to: CGPoint(x: cx - 2 * s, y: 32 * s))
        leg.addLine(to: CGPoint(x: cx + 2 * s, y: 38 * s))     // genou plié vers l'avant
        leg.addLine(to: CGPoint(x: cx, y: 44 * s))               // pied au sol
        ctx.stroke(leg, with: .color(silhouette), style: stroke)

        // Pied horizontal
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 2 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Bras tendus HAUT au-dessus (signature chaise)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: cx - 2 * s, y: 4 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: cx + 2 * s, y: 4 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// drawMiniWarrior1Mini — guerrier I (fente avant + bras tendus haut).
    private func drawMiniWarrior1Mini(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle, originX: CGFloat) {
        let cx: CGFloat = (originX + 12) * s
        let headSize: CGFloat = 4 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s, width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical (hanche → épaule)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 28 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe avant (pied droit avancé, genou plié au-dessus)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: cx, y: 28 * s))
        frontLeg.addLine(to: CGPoint(x: cx + 2 * s, y: 36 * s))
        frontLeg.addLine(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière (tendue, pied reculé à gauche)
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: cx, y: 28 * s))
        backLeg.addLine(to: CGPoint(x: cx - 5 * s, y: 44 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Pied arrière horizontal
        var backFoot = Path()
        backFoot.move(to: CGPoint(x: cx - 7 * s, y: 44 * s))
        backFoot.addLine(to: CGPoint(x: cx - 4 * s, y: 44 * s))
        ctx.stroke(backFoot, with: .color(silhouette), style: stroke)

        // Bras tendus haut (signature warrior I)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 1 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: cx - 1 * s, y: 4 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 1 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: cx + 1 * s, y: 4 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Baddha Konasana (cordonnier assis) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Baddha_Konasana
    /// Signature : vue de FACE + tronc DROIT vertical bien visible au-dessus
    /// d'un large losange de jambes (genoux très écartés + pieds joints centre).
    /// Refonte v2 : tête plus grosse + tronc allongé + losange élargi pour
    /// rendre "personne assise au sol" évident vs "diamant flottant".
    private func drawBaddhaKonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue de FACE, centrée dans viewbox 80×48. Cx=40.
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 7 * s

        // Tête (légèrement plus grosse pour signal "personne")
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 8 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou (court segment vertical)
        var neck = Path()
        neck.move(to: CGPoint(x: cx, y: 15 * s))
        neck.addLine(to: CGPoint(x: cx, y: 18 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Épaules (largeur signale "personne vue de face")
        var shoulders = Path()
        shoulders.move(to: CGPoint(x: cx - 6 * s, y: 18 * s))
        shoulders.addLine(to: CGPoint(x: cx + 6 * s, y: 18 * s))
        ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

        // Tronc droit vertical bien allongé (épaule → bassin)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 18 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 36 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Hanches larges (signale base assise)
        var hips = Path()
        hips.move(to: CGPoint(x: cx - 6 * s, y: 36 * s))
        hips.addLine(to: CGPoint(x: cx + 6 * s, y: 36 * s))
        ctx.stroke(hips, with: .color(silhouette), style: stroke)

        // Pieds joints au centre (segment vertical court signature)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 1 * s, y: 40 * s))
        feet.addLine(to: CGPoint(x: cx + 1 * s, y: 40 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Jambe gauche LOSANGE LARGE : hanche → genou très écarté → pied au centre
        var legL = Path()
        legL.move(to: CGPoint(x: cx - 6 * s, y: 36 * s))
        legL.addLine(to: CGPoint(x: cx - 18 * s, y: 44 * s))    // genou écarté loin
        legL.addLine(to: CGPoint(x: cx, y: 40 * s))                // pied centre
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        // Jambe droite LOSANGE LARGE
        var legR = Path()
        legR.move(to: CGPoint(x: cx + 6 * s, y: 36 * s))
        legR.addLine(to: CGPoint(x: cx + 18 * s, y: 44 * s))
        legR.addLine(to: CGPoint(x: cx, y: 40 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Bras gauche (épaule → main qui descend vers pieds)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 6 * s, y: 18 * s))
        armL.addLine(to: CGPoint(x: cx - 8 * s, y: 28 * s))
        armL.addLine(to: CGPoint(x: cx - 3 * s, y: 38 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 6 * s, y: 18 * s))
        armR.addLine(to: CGPoint(x: cx + 8 * s, y: 28 * s))
        armR.addLine(to: CGPoint(x: cx + 3 * s, y: 38 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Paschimottanasana (flexion avant assise) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Paschimottanasana
    /// Signature : profil + JAMBES horizontales nettes au sol + TRONC plié
    /// HORIZONTAL SÉPARÉ par un gap visible (au-dessus des jambes) + tête posée
    /// sur les genoux + bras qui descendent vers les pieds.
    private func drawPaschimottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil, jambes vers la droite. Centrée dans 80×48.
        let hipX: CGFloat = 12 * s
        let hipY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s

        // Hanche (point pivot, fesses assises au sol)
        // Jambes tendues horizontales au sol (hanche → genou → cheville)
        var legs = Path()
        legs.move(to: CGPoint(x: hipX, y: hipY))
        legs.addLine(to: CGPoint(x: 30 * s, y: hipY))    // genou
        legs.addLine(to: CGPoint(x: 62 * s, y: hipY))    // cheville
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pieds (pointe vers le haut — signature flex/point)
        var feet = Path()
        feet.move(to: CGPoint(x: 62 * s, y: hipY))
        feet.addLine(to: CGPoint(x: 64 * s, y: hipY - 6 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc plié horizontal SÉPARÉ DES JAMBES par gap vertical (signature
        // "buste rabattu sur jambes" — gap rend l'anatomie lisible).
        let shoulderX: CGFloat = 36 * s
        let shoulderY: CGFloat = 36 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: hipX, y: hipY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))   // tronc montant légèrement
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc (au-dessus des genoux signal "tête sur genoux")
        ctx.stroke(
            Path(ellipseIn: CGRect(x: shoulderX, y: shoulderY - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus qui descendent vers les pieds (épaule → main au pied)
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY + 2 * s))
        arm.addLine(to: CGPoint(x: 50 * s, y: 40 * s))
        arm.addLine(to: CGPoint(x: 60 * s, y: hipY - 2 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Marqueur main agrippe pied (mini cercle au point de jonction)
        let graspSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 58.5 * s, y: hipY - 3.5 * s,
                                    width: graspSize, height: graspSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Supta Baddha Konasana (papillon allongé) — refonte Story 3.23 Lot 2 v2.
    /// Source : https://en.wikipedia.org/wiki/Supta_Baddha_Konasana
    /// Signature : silhouette de PROFIL allongée sur le dos sur ligne sol +
    /// jambes pliées en papillon (genoux tombants + pieds joints contre le bassin).
    /// Refonte v2 : passage en vue profil (et non cavalière) pour rendre la
    /// silhouette humaine clairement reconnaissable vs "cerf-volant".
    private func drawSuptaBaddhaKonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        // Vue profil — corps allongé au sol, tête à gauche.
        let headX: CGFloat = 10 * s
        let headSize: CGFloat = 6 * s

        // Tête (à gauche, posée sur sol)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: headX - headSize / 2, y: 40 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou + tronc allongé au sol (épaule → bassin horizontal sur y=43)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 14 * s, y: 43 * s))   // épaule
        trunk.addLine(to: CGPoint(x: 40 * s, y: 43 * s)) // bassin
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras le long du corps (épaule → main posée près du bassin)
        var arm = Path()
        arm.move(to: CGPoint(x: 14 * s, y: 43 * s))
        arm.addLine(to: CGPoint(x: 26 * s, y: 45 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Jambes pliées en PAPILLON (signature) : du bassin, cuisses partent vers
        // le haut formant un V inversé (genoux écartés en l'air), pieds joints
        // qui reviennent au sol contre le bassin.
        // Jambe arrière (côté éloigné observateur — légèrement plus bas)
        var legL = Path()
        legL.move(to: CGPoint(x: 40 * s, y: 43 * s))
        legL.addLine(to: CGPoint(x: 50 * s, y: 28 * s))    // genou monte à gauche
        legL.addLine(to: CGPoint(x: 56 * s, y: 43 * s))    // pied collé au sol près bassin
        ctx.stroke(legL, with: .color(silhouette), style: stroke)

        // Jambe avant (côté observateur — légèrement plus à droite)
        var legR = Path()
        legR.move(to: CGPoint(x: 40 * s, y: 43 * s))
        legR.addLine(to: CGPoint(x: 56 * s, y: 28 * s))    // genou monte plus à droite
        legR.addLine(to: CGPoint(x: 60 * s, y: 43 * s))    // pied collé au sol
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds joints au sol contre le bassin (marqueur "papillon allongé")
        var feet = Path()
        feet.move(to: CGPoint(x: 56 * s, y: 43 * s))
        feet.addLine(to: CGPoint(x: 60 * s, y: 43 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)
    }

    // MARK: - Story 3.23 Lot 4 (moyenne fréquence)

    /// Janu Sirsasana (tête au genou) — Story 3.23 V2 yoga Lot 4 (2026-05-26).
    /// Source : https://en.wikipedia.org/wiki/Janusirsasana
    /// Signature V2 NON-RÉALISTE : jambe tendue horizontale droite + GENOU PIC
    /// VERTICAL HAUT à gauche (anatomiquement faux mais lisible 64×64) + tête
    /// plongée vers le pied droit. L'asymétrie L+pic devient instantanée.
    private func drawJanuSirsasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s
        let buttX: CGFloat = 22 * s
        let buttY: CGFloat = 42 * s

        // Jambe droite TENDUE horizontale au sol (vers la droite)
        var rightLeg = Path()
        rightLeg.move(to: CGPoint(x: buttX, y: buttY))
        rightLeg.addLine(to: CGPoint(x: 66 * s, y: 44 * s))
        ctx.stroke(rightLeg, with: .color(silhouette), style: stroke)

        // Jambe gauche PLIÉE en PIC VERTICAL (signature non-réaliste V2)
        // hanche → genou haut (y=26, 16 unités au-dessus du sol) → cheville → pied
        var leftLeg = Path()
        leftLeg.move(to: CGPoint(x: buttX, y: buttY))
        leftLeg.addLine(to: CGPoint(x: 20 * s, y: 26 * s))   // GENOU PIC HAUT
        leftLeg.addLine(to: CGPoint(x: 26 * s, y: 40 * s))
        leftLeg.addLine(to: CGPoint(x: 30 * s, y: 42 * s))   // pied au sol près cuisse
        ctx.stroke(leftLeg, with: .color(silhouette), style: stroke)

        // Marqueur genou (signature pic vertical)
        let kneeSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 20 * s - kneeSize / 2, y: 26 * s - kneeSize / 2,
                                    width: kneeSize, height: kneeSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc incliné en avant (bassin → épaules vers la droite)
        let shoulderX: CGFloat = 32 * s
        let shoulderY: CGFloat = 34 * s
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: shoulderX, y: shoulderY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête plongée vers le pied droit
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 55 * s - headSize / 2, y: 32 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus vers le pied droit
        var arm = Path()
        arm.move(to: CGPoint(x: shoulderX, y: shoulderY))
        arm.addLine(to: CGPoint(x: 46 * s, y: 36 * s))
        arm.addLine(to: CGPoint(x: 60 * s, y: 42 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Marqueur pied droit (ancre jambe tendue)
        let footSize: CGFloat = 2.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 66 * s - footSize / 2, y: 44 * s - footSize / 2,
                                    width: footSize, height: footSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Tadasana (montagne, standalone) — Story 3.23 Lot 4.
    /// Source : https://en.wikipedia.org/wiki/Tadasana
    /// Signature : silhouette verticale parfaite, pieds parallèles serrés,
    /// bras le long du corps (vue de FACE).
    private func drawTadasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 7 * s

        // Pieds parallèles (segments horizontaux côte à côte)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 4 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx - 1 * s, y: 44 * s))
        feet.move(to: CGPoint(x: cx + 1 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: cx + 4 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // 2 jambes verticales (légèrement écartées pour montrer 2 jambes)
        var legL = Path()
        legL.move(to: CGPoint(x: cx - 2 * s, y: 44 * s))
        legL.addLine(to: CGPoint(x: cx - 2 * s, y: 24 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        legR.addLine(to: CGPoint(x: cx + 2 * s, y: 24 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Hanches transversales
        var hips = Path()
        hips.move(to: CGPoint(x: cx - 2 * s, y: 24 * s))
        hips.addLine(to: CGPoint(x: cx + 2 * s, y: 24 * s))
        ctx.stroke(hips, with: .color(silhouette), style: stroke)

        // Tronc vertical (hanches → épaules)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 24 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Épaules
        var shoulders = Path()
        shoulders.move(to: CGPoint(x: cx - 5 * s, y: 14 * s))
        shoulders.addLine(to: CGPoint(x: cx + 5 * s, y: 14 * s))
        ctx.stroke(shoulders, with: .color(silhouette), style: stroke)

        // Bras le long du corps (verticaux)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 5 * s, y: 14 * s))
        armL.addLine(to: CGPoint(x: cx - 5 * s, y: 24 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 5 * s, y: 14 * s))
        armR.addLine(to: CGPoint(x: cx + 5 * s, y: 24 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 7 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Dandasana (bâton assis) — Story 3.23 Lot 4.
    /// Source : https://en.wikipedia.org/wiki/Dandasana
    /// Signature : équerre L à 90° pure — tronc vertical + jambes horizontales.
    private func drawDandasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let buttX: CGFloat = 22 * s
        let buttY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s

        // Jambes tendues horizontales (hanche → cheville → pied flexé)
        var legs = Path()
        legs.move(to: CGPoint(x: buttX, y: buttY))
        legs.addLine(to: CGPoint(x: 58 * s, y: buttY))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pointes de pieds VERTICALES (signature dandasana flex actif)
        var feet = Path()
        feet.move(to: CGPoint(x: 58 * s, y: buttY))
        feet.addLine(to: CGPoint(x: 58 * s, y: 36 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc vertical STRICT (équerre à 90°)
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: buttX, y: 26 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en haut)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: buttX - headSize / 2, y: 18 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras le long du tronc, mains au sol
        var arm = Path()
        arm.move(to: CGPoint(x: buttX + 2 * s, y: 26 * s))
        arm.addLine(to: CGPoint(x: buttX + 3 * s, y: 36 * s))
        arm.addLine(to: CGPoint(x: buttX + 4 * s, y: 42 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Marichyasana A (torsion assise) — Story 3.23 Lot 4 v2.
    /// Source : https://en.wikipedia.org/wiki/Marichyasana
    /// Signature : asymétrie visible — 1 jambe tendue horizontale + 1 jambe pliée
    /// GENOU VERTICAL HAUT (signature) + tronc qui s'enroule autour du genou plié.
    /// Refonte v2 : aérée + asymétrie nette + genou plié bien visible vers le haut.
    private func drawMarichyasanaA(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let buttX: CGFloat = 30 * s
        let buttY: CGFloat = 42 * s
        let headSize: CGFloat = 6 * s

        // Jambe gauche TENDUE horizontale vers la droite
        var tendedLeg = Path()
        tendedLeg.move(to: CGPoint(x: buttX, y: buttY))
        tendedLeg.addLine(to: CGPoint(x: 66 * s, y: 44 * s))
        ctx.stroke(tendedLeg, with: .color(silhouette), style: stroke)

        // Jambe droite PLIÉE — genou pointe VERTICAL HAUT (signature)
        var foldedLeg = Path()
        foldedLeg.move(to: CGPoint(x: buttX, y: buttY))
        foldedLeg.addLine(to: CGPoint(x: 22 * s, y: 22 * s))   // genou haut signature
        foldedLeg.addLine(to: CGPoint(x: 18 * s, y: 44 * s))   // cheville au sol
        ctx.stroke(foldedLeg, with: .color(silhouette), style: stroke)

        // Pied à plat au sol
        var foot = Path()
        foot.move(to: CGPoint(x: 14 * s, y: 44 * s))
        foot.addLine(to: CGPoint(x: 22 * s, y: 44 * s))
        ctx.stroke(foot, with: .color(silhouette), style: stroke)

        // Tronc vertical court (hanche → épaule juste derrière le genou plié)
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: 28 * s, y: 22 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (en haut, regard tourné vers la jambe tendue à droite)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 30 * s, y: 14 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras qui ENROULE la cuisse pliée (épaule → coude devant tibia → main main loin)
        var armWrap = Path()
        armWrap.move(to: CGPoint(x: 26 * s, y: 22 * s))         // épaule
        armWrap.addLine(to: CGPoint(x: 14 * s, y: 32 * s))      // coude passe devant tibia
        armWrap.addLine(to: CGPoint(x: 24 * s, y: 40 * s))      // main attrape derrière dos
        ctx.stroke(armWrap, with: .color(silhouette), style: stroke)

        // Marqueur mains liées (mini cercle au point d'agrippement)
        let claspSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 24 * s - claspSize / 2, y: 40 * s - claspSize / 2,
                                    width: claspSize, height: claspSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Matsyasana (poisson) — Story 3.23 V2 yoga Lot 4 (2026-05-26).
    /// Source : https://en.wikipedia.org/wiki/Matsyasana
    /// Signature V2 NON-RÉALISTE : dôme thoracique DRAMATIQUE culminant à y=24
    /// (20 unités au-dessus du sol, anatomiquement exagéré) + tête renversée
    /// déposée AU SOL côté gauche du dôme. Silhouette "vague + crête + tête au
    /// sol opposée" impossible à confondre avec Savasana (ligne plate).
    private func drawMatsyasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Jambes tendues au sol (de bassin à pieds)
        var legs = Path()
        legs.move(to: CGPoint(x: 46 * s, y: 42 * s))
        legs.addLine(to: CGPoint(x: 70 * s, y: 44 * s))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pied marqueur (extrémité droite)
        var feet = Path()
        feet.move(to: CGPoint(x: 70 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: 70 * s, y: 40 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Tronc en ARC DÔME DRAMATIQUE (signature V2 non-réaliste)
        // Bassin (46,42) → Apex (36,24) → Épaules (30,38)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 46 * s, y: 42 * s))
        trunk.addQuadCurve(to: CGPoint(x: 30 * s, y: 38 * s),
                           control: CGPoint(x: 36 * s, y: 24 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Marqueur sommet du dôme (signature crête thoracique)
        let apexSize: CGFloat = 2.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 36 * s - apexSize / 2, y: 24 * s - apexSize / 2,
                                    width: apexSize, height: apexSize)),
            with: .color(silhouette), style: stroke
        )

        // Cou : épaules → tête renversée au sol côté gauche
        var neck = Path()
        neck.move(to: CGPoint(x: 30 * s, y: 38 * s))
        neck.addLine(to: CGPoint(x: 22 * s, y: 42 * s))
        ctx.stroke(neck, with: .color(silhouette), style: stroke)

        // Tête au sol côté gauche (renversée derrière le dôme)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 18 * s - headSize / 2, y: 42 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Marqueur contact crâne-sol (signature renversement)
        let crownSize: CGFloat = 2 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 18 * s - crownSize / 2, y: 45 * s - crownSize / 2,
                                    width: crownSize, height: crownSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras le long du corps au sol sous le dôme
        var arm = Path()
        arm.move(to: CGPoint(x: 30 * s, y: 38 * s))
        arm.addLine(to: CGPoint(x: 28 * s, y: 42 * s))
        arm.addLine(to: CGPoint(x: 26 * s, y: 44 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Utthita Parsvakonasana (angle latéral étendu) — Story 3.23 Lot 4.
    /// Source : https://en.wikipedia.org/wiki/Utthita_Parsvakonasana
    /// Signature : diagonale continue du pied arrière au bout de la main levée
    /// + main basse au sol près du pied avant fléchi.
    private func drawParsvakonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Pied avant droit (fléchi)
        let frontFootX: CGFloat = 52 * s
        // Pied arrière gauche (tendu)
        let backFootX: CGFloat = 16 * s

        // Jambe arrière tendue
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: backFootX, y: 44 * s))
        backLeg.addLine(to: CGPoint(x: 40 * s, y: 28 * s))    // hanche
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Pied arrière marqueur horizontal
        var backFoot = Path()
        backFoot.move(to: CGPoint(x: 12 * s, y: 44 * s))
        backFoot.addLine(to: CGPoint(x: 20 * s, y: 44 * s))
        ctx.stroke(backFoot, with: .color(silhouette), style: stroke)

        // Jambe avant pliée (genou au-dessus du pied)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: 44 * s, y: 28 * s))      // hanche
        frontLeg.addLine(to: CGPoint(x: frontFootX, y: 32 * s)) // genou
        frontLeg.addLine(to: CGPoint(x: frontFootX, y: 44 * s)) // pied au sol
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Tronc incliné suivant la diagonale (hanche → épaule)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 42 * s, y: 28 * s))
        trunk.addLine(to: CGPoint(x: 44 * s, y: 22 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras BAS qui touche le sol près du pied avant (signature)
        var lowArm = Path()
        lowArm.move(to: CGPoint(x: 48 * s, y: 22 * s))
        lowArm.addLine(to: CGPoint(x: 50 * s, y: 32 * s))
        lowArm.addLine(to: CGPoint(x: 54 * s, y: 44 * s))     // main au sol près pied avant
        ctx.stroke(lowArm, with: .color(silhouette), style: stroke)

        // Bras HAUT tendu en l'air (signature diagonale ascendante)
        var highArm = Path()
        highArm.move(to: CGPoint(x: 40 * s, y: 22 * s))
        highArm.addLine(to: CGPoint(x: 34 * s, y: 14 * s))
        highArm.addLine(to: CGPoint(x: 28 * s, y: 8 * s))
        ctx.stroke(highArm, with: .color(silhouette), style: stroke)

        // Tête (regard vers la main levée)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 42 * s, y: 14 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Viparita Karani (jambes contre le mur) — Story 3.23 Lot 4.
    /// Source : https://en.wikipedia.org/wiki/Viparita_Karani
    /// Signature : silhouette en L pur — tronc au sol horizontal + jambes VERTICALES
    /// vers le haut (pieds tout en haut).
    private func drawViparitaKarani(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Tête au sol (à gauche)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 12 * s - headSize / 2, y: 38 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc allongé horizontal au sol (épaule → bassin pivot du L)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 16 * s, y: 43 * s))
        trunk.addLine(to: CGPoint(x: 38 * s, y: 43 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes VERTICALES vers le haut (signature L pivotant au bassin)
        var legs = Path()
        legs.move(to: CGPoint(x: 38 * s, y: 43 * s))
        legs.addLine(to: CGPoint(x: 38 * s, y: 8 * s))
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pointes de pieds au sommet (segment horizontal)
        var feet = Path()
        feet.move(to: CGPoint(x: 36 * s, y: 8 * s))
        feet.addLine(to: CGPoint(x: 40 * s, y: 8 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Bras au sol étirés à droite du tronc (signature paume au sol)
        var arm = Path()
        arm.move(to: CGPoint(x: 16 * s, y: 43 * s))
        arm.addLine(to: CGPoint(x: 24 * s, y: 45 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)

        // Suggestion mur invisible (trait vertical pointillé fin annotation)
        var wall = Path()
        wall.move(to: CGPoint(x: 42 * s, y: 8 * s))
        wall.addLine(to: CGPoint(x: 42 * s, y: 43 * s))
        ctx.stroke(wall, with: .color(annotation),
                   style: StrokeStyle(lineWidth: 1 * s, dash: [2 * s, 2 * s]))
    }

    /// Parsvottanasana (pyramide) — Story 3.23 Lot 4.
    /// Source : https://en.wikipedia.org/wiki/Parsvottanasana
    /// Signature : split-stance avec JAMBES DROITES TENDUES + tronc plié vers
    /// la jambe avant (variante mains au sol pour lisibilité).
    private func drawParsvottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Pied avant droit
        let frontFootX: CGFloat = 54 * s
        // Pied arrière gauche
        let backFootX: CGFloat = 20 * s

        // Pieds segments horizontaux
        var feet = Path()
        feet.move(to: CGPoint(x: backFootX - 4 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: backFootX, y: 44 * s))
        feet.move(to: CGPoint(x: frontFootX, y: 44 * s))
        feet.addLine(to: CGPoint(x: frontFootX + 4 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Jambe avant TENDUE (signature pas pliée)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: frontFootX, y: 44 * s))
        frontLeg.addLine(to: CGPoint(x: 50 * s, y: 24 * s))    // hanche droite
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière TENDUE
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: backFootX, y: 44 * s))
        backLeg.addLine(to: CGPoint(x: 42 * s, y: 24 * s))    // hanche gauche
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)

        // Tronc plié vers la jambe avant (front vers tibia)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 46 * s, y: 24 * s))
        trunk.addLine(to: CGPoint(x: 52 * s, y: 34 * s))     // épaules vers le bas-avant
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (front vers le tibia avant)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 54 * s - headSize / 2, y: 36 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras au sol de part et d'autre du pied avant (variante lisible)
        var armL = Path()
        armL.move(to: CGPoint(x: 50 * s, y: 34 * s))
        armL.addLine(to: CGPoint(x: 50 * s, y: 44 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: 54 * s, y: 34 * s))
        armR.addLine(to: CGPoint(x: 58 * s, y: 44 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Halasana (charrue) — Story 3.23 V2 yoga Lot 4 (2026-05-26).
    /// Source : https://en.wikipedia.org/wiki/Halasana
    /// Signature V2 NON-RÉALISTE : APEX BASSIN à y=10 (quasi sommet viewbox)
    /// formant un triangle pointu ultra-net + 2 contacts sol opposés (tête à
    /// droite x=58, pieds à gauche x=14). Silhouette "chevron pointu vers le
    /// haut" immédiatement reconnaissable.
    private func drawHalasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Tête au sol (à droite)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 58 * s - headSize / 2, y: 42 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc montant en DIAGONALE FORTE vers l'apex bassin (épaules → bassin)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 52 * s, y: 38 * s))    // épaules près du sol
        trunk.addLine(to: CGPoint(x: 42 * s, y: 10 * s)) // APEX BASSIN ultra-haut
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Marqueur apex bassin (signature pic vertical)
        let apexSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 42 * s - apexSize / 2, y: 10 * s - apexSize / 2,
                                    width: apexSize, height: apexSize)),
            with: .color(silhouette), style: stroke
        )

        // Jambes redescendant en diagonale du bassin vers les pieds au sol GAUCHE
        var legs = Path()
        legs.move(to: CGPoint(x: 42 * s, y: 10 * s))    // apex bassin
        legs.addLine(to: CGPoint(x: 34 * s, y: 22 * s))  // genoux
        legs.addLine(to: CGPoint(x: 22 * s, y: 36 * s))  // chevilles
        legs.addLine(to: CGPoint(x: 14 * s, y: 42 * s))  // pieds au sol
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Pieds marqueur segment au sol (signature ancrage opposé à la tête)
        var feet = Path()
        feet.move(to: CGPoint(x: 8 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: 18 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Bras au sol côté droite (le long du dos contre le sol)
        var arm = Path()
        arm.move(to: CGPoint(x: 52 * s, y: 38 * s))
        arm.addLine(to: CGPoint(x: 58 * s, y: 42 * s))
        arm.addLine(to: CGPoint(x: 64 * s, y: 44 * s))
        ctx.stroke(arm, with: .color(silhouette), style: stroke)
    }

    /// Kurmasana (tortue) — Story 3.23 V2 yoga Lot 4 (2026-05-26).
    /// Source : https://en.wikipedia.org/wiki/Kurmasana
    /// Signature V2 NON-RÉALISTE : 2 jambes verticales en V INVERSÉ (genoux
    /// pointés à y=16, 28 unités au-dessus du sol) + tronc plongé bas entre
    /// les cuisses + 2 bras qui DÉPASSENT latéralement aux extrémités (x=12,
    /// x=68). Silhouette "tortue dont les pattes dépassent de la carapace".
    private func drawKurmasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s
        let buttX: CGFloat = 40 * s
        let buttY: CGFloat = 42 * s

        // Jambe gauche V INVERSÉ — hanche → genou PIC HAUT → cheville → pied au sol
        var leftLeg = Path()
        leftLeg.move(to: CGPoint(x: buttX, y: buttY))
        leftLeg.addLine(to: CGPoint(x: 26 * s, y: 16 * s))   // GENOU PIC HAUT gauche
        leftLeg.addLine(to: CGPoint(x: 22 * s, y: 30 * s))
        leftLeg.addLine(to: CGPoint(x: 20 * s, y: 42 * s))   // pied au sol
        ctx.stroke(leftLeg, with: .color(silhouette), style: stroke)

        // Jambe droite V INVERSÉ — symétrique
        var rightLeg = Path()
        rightLeg.move(to: CGPoint(x: buttX, y: buttY))
        rightLeg.addLine(to: CGPoint(x: 54 * s, y: 16 * s))  // GENOU PIC HAUT droit
        rightLeg.addLine(to: CGPoint(x: 58 * s, y: 30 * s))
        rightLeg.addLine(to: CGPoint(x: 60 * s, y: 42 * s))  // pied au sol
        ctx.stroke(rightLeg, with: .color(silhouette), style: stroke)

        // Marqueurs genoux pics (signature 2 pics verticaux)
        let kneeSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 26 * s - kneeSize / 2, y: 16 * s - kneeSize / 2,
                                    width: kneeSize, height: kneeSize)),
            with: .color(silhouette), style: stroke
        )
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 54 * s - kneeSize / 2, y: 16 * s - kneeSize / 2,
                                    width: kneeSize, height: kneeSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc court vertical plongé (épaules basses entre les genoux levés)
        var trunk = Path()
        trunk.move(to: CGPoint(x: buttX, y: buttY))
        trunk.addLine(to: CGPoint(x: buttX, y: 36 * s))     // épaules basses
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête plongée bas au centre (presque au sol entre les cuisses)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: buttX - headSize / 2, y: 40 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras gauche DÉPASSE latéralement à gauche (signature pattes de tortue)
        var leftArm = Path()
        leftArm.move(to: CGPoint(x: buttX, y: 36 * s))
        leftArm.addLine(to: CGPoint(x: 28 * s, y: 40 * s))
        leftArm.addLine(to: CGPoint(x: 12 * s, y: 44 * s))  // main qui dépasse
        ctx.stroke(leftArm, with: .color(silhouette), style: stroke)

        // Bras droit DÉPASSE latéralement à droite (signature pattes de tortue)
        var rightArm = Path()
        rightArm.move(to: CGPoint(x: buttX, y: 36 * s))
        rightArm.addLine(to: CGPoint(x: 52 * s, y: 40 * s))
        rightArm.addLine(to: CGPoint(x: 68 * s, y: 44 * s)) // main qui dépasse
        ctx.stroke(rightArm, with: .color(silhouette), style: stroke)

        // Marqueurs mains qui dépassent (signature pattes)
        let handSize: CGFloat = 2.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 12 * s - handSize / 2, y: 44 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 68 * s - handSize / 2, y: 44 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )
    }

    // MARK: - Story 3.23 Lot 6 (reste yoga)

    /// Anjaneyasana (low lunge / fente basse) — Story 3.23 Lot 6 v2.
    /// Source : https://en.wikipedia.org/wiki/Anjaneyasana
    /// Signature : ASYMÉTRIE NETTE — bassin BAS (descente fente profonde) +
    /// genou arrière qui repose explicitement au sol avec tibia horizontal
    /// + bras hauts joints très visibles.
    /// Refonte v2 : descendre le bassin pour rendre la fente PROFONDE évidente
    /// (vs v1 qui ressemblait à grand écart debout symétrique).
    private func drawAnjaneyasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Bassin DESCENDU (fente profonde — signature low lunge)
        let bassinX: CGFloat = 40 * s
        let bassinY: CGFloat = 34 * s

        // Tête (en haut)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: bassinX - headSize / 2, y: 8 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical (épaule → bassin abaissé)
        var trunk = Path()
        trunk.move(to: CGPoint(x: bassinX, y: 16 * s))
        trunk.addLine(to: CGPoint(x: bassinX, y: bassinY))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras hauts joints (namaste levé au-dessus de la tête)
        var armL = Path()
        armL.move(to: CGPoint(x: bassinX - 2 * s, y: 16 * s))
        armL.addLine(to: CGPoint(x: bassinX - 2 * s, y: 2 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: bassinX + 2 * s, y: 16 * s))
        armR.addLine(to: CGPoint(x: bassinX + 2 * s, y: 2 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Mains jointes (segment horizontal au sommet)
        var hands = Path()
        hands.move(to: CGPoint(x: bassinX - 2 * s, y: 2 * s))
        hands.addLine(to: CGPoint(x: bassinX + 2 * s, y: 2 * s))
        ctx.stroke(hands, with: .color(silhouette), style: stroke)

        // Jambe avant pliée à 90° (tibia VERTICAL sous le genou)
        var frontLeg = Path()
        frontLeg.move(to: CGPoint(x: bassinX, y: bassinY))
        frontLeg.addLine(to: CGPoint(x: 56 * s, y: 36 * s))   // genou avant
        frontLeg.addLine(to: CGPoint(x: 56 * s, y: 44 * s))   // pied au sol
        ctx.stroke(frontLeg, with: .color(silhouette), style: stroke)

        // Jambe arrière SIGNATURE : cuisse part vers la gauche-bas, genou AU SOL
        // puis tibia HORIZONTAL au sol jusqu'au pied
        var backThigh = Path()
        backThigh.move(to: CGPoint(x: bassinX, y: bassinY))
        backThigh.addLine(to: CGPoint(x: 24 * s, y: 44 * s))   // genou TOUCHE le sol
        ctx.stroke(backThigh, with: .color(silhouette), style: stroke)

        // Tibia horizontal posé au sol (signature LOW lunge vs HIGH lunge)
        var backShin = Path()
        backShin.move(to: CGPoint(x: 24 * s, y: 44 * s))
        backShin.addLine(to: CGPoint(x: 14 * s, y: 44 * s))
        ctx.stroke(backShin, with: .color(silhouette), style: stroke)

        // Marqueur genou au sol (mini cercle signature critique)
        let kneeSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 24 * s - kneeSize / 2, y: 44 * s - kneeSize / 2,
                                    width: kneeSize, height: kneeSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Urdhva Dhanurasana (roue / Wheel pose) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Urdhva_Dhanurasana
    /// Signature : arc complet renversé — bassin SOMMET de l'arc + 4 appuis sol
    /// (2 mains + 2 pieds) + tête PENDANTE sous les épaules.
    private func drawUrdhvaDhanurasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Pieds au sol (à droite)
        var feet = Path()
        feet.move(to: CGPoint(x: 56 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: 62 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Mains au sol (à gauche — derrière la tête)
        var hands = Path()
        hands.move(to: CGPoint(x: 18 * s, y: 44 * s))
        hands.addLine(to: CGPoint(x: 24 * s, y: 44 * s))
        ctx.stroke(hands, with: .color(silhouette), style: stroke)

        // Jambes (pied droit → genou → bassin sommet)
        var rightLeg = Path()
        rightLeg.move(to: CGPoint(x: 58 * s, y: 44 * s))
        rightLeg.addLine(to: CGPoint(x: 54 * s, y: 34 * s))   // genou pointe haut
        rightLeg.addLine(to: CGPoint(x: 44 * s, y: 22 * s))   // hanche
        ctx.stroke(rightLeg, with: .color(silhouette), style: stroke)

        // Tronc en ARC RENVERSÉ avec quadCurve (bassin = sommet, épaule à gauche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 44 * s, y: 22 * s))    // bassin = sommet
        trunk.addQuadCurve(to: CGPoint(x: 28 * s, y: 22 * s),
                           control: CGPoint(x: 36 * s, y: 14 * s))   // arc montant
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras tendus vers le bas (épaule → coude → main au sol)
        var arms = Path()
        arms.move(to: CGPoint(x: 28 * s, y: 22 * s))
        arms.addLine(to: CGPoint(x: 24 * s, y: 32 * s))
        arms.addLine(to: CGPoint(x: 22 * s, y: 44 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)

        // Tête PENDANTE sous les épaules (signature wheel)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 26 * s - headSize / 2, y: 30 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Dolphin pose (Pincha) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Pincha_Mayurasana
    /// Signature : V inversé + appuis AVANT-BRAS au sol (coude visible à 90°)
    /// vs Adho Mukha (paumes au sol bras tendus).
    private func drawDolphinPose(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Bassin = sommet du V (le plus haut)
        let bassinX: CGFloat = 40 * s
        let bassinY: CGFloat = 14 * s

        // Jambes tendues descendant à droite (cuisse + tibia alignés)
        var legs = Path()
        legs.move(to: CGPoint(x: bassinX, y: bassinY))
        legs.addLine(to: CGPoint(x: 64 * s, y: 44 * s))    // pied au sol
        ctx.stroke(legs, with: .color(silhouette), style: stroke)

        // Tronc descendant à gauche (vers épaules)
        var trunk = Path()
        trunk.move(to: CGPoint(x: bassinX, y: bassinY))
        trunk.addLine(to: CGPoint(x: 24 * s, y: 28 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Bras : humérus court vertical (épaule → coude au sol)
        var humerus = Path()
        humerus.move(to: CGPoint(x: 24 * s, y: 28 * s))
        humerus.addLine(to: CGPoint(x: 20 * s, y: 38 * s))    // coude
        ctx.stroke(humerus, with: .color(silhouette), style: stroke)

        // Avant-bras HORIZONTAL au sol (SIGNATURE dolphin)
        var forearm = Path()
        forearm.move(to: CGPoint(x: 20 * s, y: 38 * s))
        forearm.addLine(to: CGPoint(x: 12 * s, y: 44 * s))    // main/poignet au sol
        ctx.stroke(forearm, with: .color(silhouette), style: stroke)

        // Marqueur coude 90° (mini cercle signature dolphin vs adho mukha)
        let elbowSize: CGFloat = 2.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 20 * s - elbowSize / 2, y: 38 * s - elbowSize / 2,
                                    width: elbowSize, height: elbowSize)),
            with: .color(silhouette), style: stroke
        )

        // Tête pendante entre les bras
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 24 * s - headSize / 2, y: 33 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Garudasana (aigle) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Garudasana
    /// Signature : silhouette debout vue face + X bras devant poitrine + genou
    /// levé qui croise la jambe support (2 signes lisibles).
    private func drawGarudasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 7 * s

        // Tête vue face (plus grosse)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 7 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc vertical légèrement fléchi
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 15 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 30 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambe support (droite anatomique = gauche écran, axe central)
        var support = Path()
        support.move(to: CGPoint(x: cx, y: 30 * s))
        support.addLine(to: CGPoint(x: cx - 2 * s, y: 38 * s))   // léger fléchissement
        support.addLine(to: CGPoint(x: cx - 2 * s, y: 44 * s))
        ctx.stroke(support, with: .color(silhouette), style: stroke)

        // Jambe enroulée — genou levé qui CROISE devant la support
        var wrap = Path()
        wrap.move(to: CGPoint(x: cx, y: 30 * s))
        wrap.addLine(to: CGPoint(x: cx + 4 * s, y: 36 * s))      // genou croise devant
        wrap.addLine(to: CGPoint(x: cx - 4 * s, y: 41 * s))      // pied enroulé derrière mollet
        ctx.stroke(wrap, with: .color(silhouette), style: stroke)

        // Marqueur croisement jambe (mini cercle)
        let crossSize: CGFloat = 2 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 2.5 * s, y: 38 * s,
                                    width: crossSize, height: crossSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras CROISÉS — X devant la poitrine (signature)
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 3 * s, y: 15 * s))    // épaule gauche
        armL.addLine(to: CGPoint(x: cx + 3 * s, y: 22 * s)) // coude croisé à droite
        armL.addLine(to: CGPoint(x: cx, y: 14 * s))           // main remonte au visage
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 3 * s, y: 15 * s))
        armR.addLine(to: CGPoint(x: cx - 3 * s, y: 22 * s))
        armR.addLine(to: CGPoint(x: cx, y: 14 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Marqueur croisement bras (mini cercle au centre du X)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 1 * s, y: 20 * s,
                                    width: 2 * s, height: 2 * s)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Utkatasana (chaise) standalone — Story 3.23 Lot 6 v2.
    /// Source : https://en.wikipedia.org/wiki/Utkatasana
    /// Signature : posture "skieur" — bassin TRÈS RECULÉ vers l'arrière +
    /// 2 genoux fléchis projetés devant + tronc incliné en avant +
    /// bras tendus au-dessus de la tête.
    /// Refonte v2 : fléchissement très marqué + bras alignés avec tronc incliné.
    private func drawUtkatasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Pieds parallèles rapprochés
        var feet = Path()
        feet.move(to: CGPoint(x: 34 * s, y: 44 * s))
        feet.addLine(to: CGPoint(x: 42 * s, y: 44 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)

        // Bassin TRÈS RECULÉ (signature assise dans le vide)
        let bassinX: CGFloat = 28 * s
        let bassinY: CGFloat = 32 * s

        // Jambes fléchies — cuisses presque horizontales, tibias verticaux
        // (signature chaise — genoux projetés en avant vs bassin reculé)
        var legL = Path()
        legL.move(to: CGPoint(x: bassinX, y: bassinY))
        legL.addLine(to: CGPoint(x: 38 * s, y: 38 * s))   // genou projeté devant
        legL.addLine(to: CGPoint(x: 36 * s, y: 44 * s))   // pied
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: bassinX, y: bassinY))
        legR.addLine(to: CGPoint(x: 42 * s, y: 38 * s))
        legR.addLine(to: CGPoint(x: 40 * s, y: 44 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Marqueur fléchissement genou (mini cercle)
        let kneeSize: CGFloat = 2.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 40 * s - kneeSize / 2, y: 38 * s - kneeSize / 2,
                                    width: kneeSize, height: kneeSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc INCLINÉ vers l'avant (bassin reculé → épaule devant)
        var trunk = Path()
        trunk.move(to: CGPoint(x: bassinX, y: bassinY))
        trunk.addLine(to: CGPoint(x: 36 * s, y: 20 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête (alignée avec inclinaison tronc)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 38 * s - headSize / 2, y: 14 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus haut ALIGNÉS avec tronc incliné (mains vers le haut-avant)
        var armL = Path()
        armL.move(to: CGPoint(x: 34 * s, y: 20 * s))
        armL.addLine(to: CGPoint(x: 44 * s, y: 4 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)
        var armR = Path()
        armR.move(to: CGPoint(x: 38 * s, y: 20 * s))
        armR.addLine(to: CGPoint(x: 48 * s, y: 4 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)
    }

    /// Warrior 3 (Virabhadrasana III) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Virabhadrasana
    /// Signature : silhouette en T horizontal sur 1 jambe verticale (1 seul
    /// appui sol vs Warrior I/II avec 2 pieds au sol).
    private func drawWarrior3(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Jambe support VERTICALE (axe central)
        var support = Path()
        support.move(to: CGPoint(x: 40 * s, y: 44 * s))    // pied
        support.addLine(to: CGPoint(x: 40 * s, y: 26 * s)) // hanche (pivot du T)
        ctx.stroke(support, with: .color(silhouette), style: stroke)

        // Pied support (segment horizontal au sol)
        var foot = Path()
        foot.move(to: CGPoint(x: 36 * s, y: 44 * s))
        foot.addLine(to: CGPoint(x: 44 * s, y: 44 * s))
        ctx.stroke(foot, with: .color(silhouette), style: stroke)

        // Tronc HORIZONTAL parallèle au sol (vers la gauche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 40 * s, y: 26 * s))   // bassin pivot
        trunk.addLine(to: CGPoint(x: 24 * s, y: 26 * s)) // épaules
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 18 * s - headSize / 2, y: 26 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Bras tendus DEVANT (prolongement du tronc horizontal)
        var arms = Path()
        arms.move(to: CGPoint(x: 24 * s, y: 26 * s))
        arms.addLine(to: CGPoint(x: 10 * s, y: 26 * s))
        ctx.stroke(arms, with: .color(silhouette), style: stroke)

        // Jambe arrière HORIZONTALE tendue (en arrière, dans le prolongement)
        var backLeg = Path()
        backLeg.move(to: CGPoint(x: 40 * s, y: 26 * s))
        backLeg.addLine(to: CGPoint(x: 66 * s, y: 26 * s))
        ctx.stroke(backLeg, with: .color(silhouette), style: stroke)
    }

    /// Nadi Shodhana (respiration alternée) — Story 3.23 Lot 6 v2.
    /// Source : https://en.wikipedia.org/wiki/Nadi_shodhana
    /// Signature : silhouette assise tailleur DROITE + main DROITE TRÈS VISIBLE
    /// portée AU VISAGE (geste signature pranayama).
    /// Refonte v2 : main au visage agrandie + bras plus expressif.
    private func drawNadiShodhana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 10 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit VERTICAL (signature posture assise droite)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 18 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 32 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes croisées triangle large
        var legL = Path()
        legL.move(to: CGPoint(x: cx, y: 32 * s))
        legL.addLine(to: CGPoint(x: cx - 10 * s, y: 42 * s))
        legL.addLine(to: CGPoint(x: cx - 4 * s, y: 43 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx, y: 32 * s))
        legR.addLine(to: CGPoint(x: cx + 10 * s, y: 42 * s))
        legR.addLine(to: CGPoint(x: cx + 4 * s, y: 43 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Bras GAUCHE descendant au repos sur genou
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 2 * s, y: 18 * s))
        armL.addLine(to: CGPoint(x: cx - 6 * s, y: 28 * s))
        armL.addLine(to: CGPoint(x: cx - 10 * s, y: 42 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras DROIT SIGNATURE — coude bien levé + main au visage TRÈS VISIBLE
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 2 * s, y: 18 * s))    // épaule
        armR.addLine(to: CGPoint(x: cx + 8 * s, y: 14 * s)) // coude levé bien à droite
        armR.addLine(to: CGPoint(x: cx + 3 * s, y: 12 * s)) // main au visage
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Marqueur main au visage AGRANDI (cercle bien visible)
        let handSize: CGFloat = 4 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx + 3 * s - handSize / 2, y: 12 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )

        // Mini segments doigts vers les narines (signature pranayama)
        var fingers = Path()
        fingers.move(to: CGPoint(x: cx + 1 * s, y: 12 * s))
        fingers.addLine(to: CGPoint(x: cx + 3 * s, y: 12 * s))
        ctx.stroke(fingers, with: .color(silhouette), style: stroke)
    }

    /// Ardha Chandrasana (demi-lune) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Ardha_Chandrasana
    /// Signature : silhouette en CROIX horizontale équilibrée sur 1 jambe
    /// verticale + 1 main au sol + 1 bras tendu vers le ciel + 1 jambe horizontale.
    private func drawArdhaChandrasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let headSize: CGFloat = 6 * s

        // Jambe support VERTICALE (à droite)
        var support = Path()
        support.move(to: CGPoint(x: 52 * s, y: 44 * s))
        support.addLine(to: CGPoint(x: 52 * s, y: 24 * s))    // hanche pivot croix
        ctx.stroke(support, with: .color(silhouette), style: stroke)

        // Pied support
        var foot = Path()
        foot.move(to: CGPoint(x: 48 * s, y: 44 * s))
        foot.addLine(to: CGPoint(x: 56 * s, y: 44 * s))
        ctx.stroke(foot, with: .color(silhouette), style: stroke)

        // Tronc HORIZONTAL parallèle au sol (vers la gauche)
        var trunk = Path()
        trunk.move(to: CGPoint(x: 52 * s, y: 24 * s))
        trunk.addLine(to: CGPoint(x: 32 * s, y: 24 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Tête au bout du tronc
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 26 * s - headSize / 2, y: 24 * s - headSize / 2,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Jambe levée HORIZONTALE en l'air (prolongement du tronc)
        var liftedLeg = Path()
        liftedLeg.move(to: CGPoint(x: 52 * s, y: 24 * s))
        liftedLeg.addLine(to: CGPoint(x: 72 * s, y: 24 * s))
        ctx.stroke(liftedLeg, with: .color(silhouette), style: stroke)

        // Bras AU SOL (descend de l'épaule vers le sol)
        var lowArm = Path()
        lowArm.move(to: CGPoint(x: 32 * s, y: 24 * s))
        lowArm.addLine(to: CGPoint(x: 30 * s, y: 32 * s))
        lowArm.addLine(to: CGPoint(x: 28 * s, y: 44 * s))    // main au sol
        ctx.stroke(lowArm, with: .color(silhouette), style: stroke)

        // Bras VERTICAL vers le ciel (signature demi-lune)
        var highArm = Path()
        highArm.move(to: CGPoint(x: 32 * s, y: 24 * s))
        highArm.addLine(to: CGPoint(x: 32 * s, y: 14 * s))
        highArm.addLine(to: CGPoint(x: 32 * s, y: 6 * s))
        ctx.stroke(highArm, with: .color(silhouette), style: stroke)

        // Marqueur main au sol (signature)
        let handSize: CGFloat = 2 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: 28 * s - handSize / 2, y: 44 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Sukhasana (assise en tailleur) — Story 3.23 Lot 6.
    /// Source : https://en.wikipedia.org/wiki/Sukhasana
    /// Signature : assis tronc droit vertical + jambes croisées en triangle bas
    /// + LES DEUX mains posées symétriquement sur les genoux.
    private func drawSukhasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 6 * s

        // Tête
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 15 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Tronc droit vertical
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 23 * s))
        trunk.addLine(to: CGPoint(x: cx, y: 34 * s))
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes croisées triangle (signature tailleur — large + bas)
        var legL = Path()
        legL.move(to: CGPoint(x: cx, y: 34 * s))
        legL.addLine(to: CGPoint(x: cx - 10 * s, y: 42 * s))
        legL.addLine(to: CGPoint(x: cx - 5 * s, y: 43 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx, y: 34 * s))
        legR.addLine(to: CGPoint(x: cx + 10 * s, y: 42 * s))
        legR.addLine(to: CGPoint(x: cx + 5 * s, y: 43 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Mini X au croisement des chevilles (signature tailleur)
        var crossLeft = Path()
        crossLeft.move(to: CGPoint(x: cx - 2 * s, y: 42 * s))
        crossLeft.addLine(to: CGPoint(x: cx + 2 * s, y: 44 * s))
        ctx.stroke(crossLeft, with: .color(silhouette), style: stroke)
        var crossRight = Path()
        crossRight.move(to: CGPoint(x: cx + 2 * s, y: 42 * s))
        crossRight.addLine(to: CGPoint(x: cx - 2 * s, y: 44 * s))
        ctx.stroke(crossRight, with: .color(silhouette), style: stroke)

        // Bras gauche descendant sur genou
        var armL = Path()
        armL.move(to: CGPoint(x: cx - 2 * s, y: 23 * s))
        armL.addLine(to: CGPoint(x: cx - 7 * s, y: 32 * s))
        armL.addLine(to: CGPoint(x: cx - 10 * s, y: 42 * s))
        ctx.stroke(armL, with: .color(silhouette), style: stroke)

        // Bras droit descendant sur genou (SYMÉTRIE = signature Sukhasana vs Nadi)
        var armR = Path()
        armR.move(to: CGPoint(x: cx + 2 * s, y: 23 * s))
        armR.addLine(to: CGPoint(x: cx + 7 * s, y: 32 * s))
        armR.addLine(to: CGPoint(x: cx + 10 * s, y: 42 * s))
        ctx.stroke(armR, with: .color(silhouette), style: stroke)

        // Marqueurs mains sur genoux (mini cercles bilatéraux signature symétrie)
        let handSize: CGFloat = 1.5 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - 10 * s - handSize / 2, y: 42 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx + 10 * s - handSize / 2, y: 42 * s - handSize / 2,
                                    width: handSize, height: handSize)),
            with: .color(silhouette), style: stroke
        )
    }

    /// Sirsasana (headstand) — Story 3.23 Lot 6 v2.
    /// Source : https://en.wikipedia.org/wiki/Sirsasana
    /// Signature : inversion totale — tête au sol BIEN MARQUÉE + TRÉPIED
    /// avant-bras formant triangle visible + corps vertical inversé + pieds
    /// avec marqueur explicite en haut.
    /// Refonte v2 : trépied avant-bras + tête plus expressifs pour différencier
    /// de "debout simple".
    private func drawSirsasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        let cx: CGFloat = 40 * s
        let headSize: CGFloat = 8 * s    // tête plus grosse pour signature inversion claire

        // Tête AU SOL BIEN VISIBLE (cercle gros, posée par le haut au sol y=44)
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - headSize / 2, y: 36 * s,
                                    width: headSize, height: headSize)),
            with: .color(silhouette), style: stroke
        )

        // Marqueur tête-sol (mini cercle au point de contact)
        let crownSize: CGFloat = 3 * s
        ctx.stroke(
            Path(ellipseIn: CGRect(x: cx - crownSize / 2, y: 44 * s - crownSize,
                                    width: crownSize, height: crownSize)),
            with: .color(silhouette), style: stroke
        )

        // Trépied avant-bras GAUCHE (main → coude → épaule sous la tête)
        // Tracé en triangle bien visible
        var leftArm = Path()
        leftArm.move(to: CGPoint(x: 26 * s, y: 44 * s))    // main au sol gauche bien écartée
        leftArm.addLine(to: CGPoint(x: 32 * s, y: 36 * s)) // coude au-dessus
        leftArm.addLine(to: CGPoint(x: cx - 4 * s, y: 34 * s)) // épaule
        ctx.stroke(leftArm, with: .color(silhouette), style: stroke)

        // Trépied avant-bras DROIT (symétrique)
        var rightArm = Path()
        rightArm.move(to: CGPoint(x: 54 * s, y: 44 * s))
        rightArm.addLine(to: CGPoint(x: 48 * s, y: 36 * s))
        rightArm.addLine(to: CGPoint(x: cx + 4 * s, y: 34 * s))
        ctx.stroke(rightArm, with: .color(silhouette), style: stroke)

        // Tronc VERTICAL en l'air (épaules → bassin en haut)
        var trunk = Path()
        trunk.move(to: CGPoint(x: cx, y: 32 * s))    // épaules sous la tête (au-dessus)
        trunk.addLine(to: CGPoint(x: cx, y: 18 * s)) // bassin en haut
        ctx.stroke(trunk, with: .color(silhouette), style: stroke)

        // Jambes VERTICALES vers le ciel (2 jambes parallèles bien écartées)
        var legL = Path()
        legL.move(to: CGPoint(x: cx - 2 * s, y: 18 * s))
        legL.addLine(to: CGPoint(x: cx - 2 * s, y: 4 * s))
        ctx.stroke(legL, with: .color(silhouette), style: stroke)
        var legR = Path()
        legR.move(to: CGPoint(x: cx + 2 * s, y: 18 * s))
        legR.addLine(to: CGPoint(x: cx + 2 * s, y: 4 * s))
        ctx.stroke(legR, with: .color(silhouette), style: stroke)

        // Pieds en haut (segment horizontal + 2 petits L pour pointes)
        var feet = Path()
        feet.move(to: CGPoint(x: cx - 4 * s, y: 4 * s))
        feet.addLine(to: CGPoint(x: cx + 4 * s, y: 4 * s))
        ctx.stroke(feet, with: .color(silhouette), style: stroke)
    }

    // MARK: - Party illustrations 2026-06-08 — asanas avancées (helpers + 17 poses)

    /// Polyligne silhouette (points déjà en coordonnées écran).
    private func yLimb(_ ctx: GraphicsContext, _ pts: [CGPoint], _ stroke: StrokeStyle) {
        guard let f = pts.first else { return }
        var path = Path(); path.move(to: f)
        for q in pts.dropFirst() { path.addLine(to: q) }
        ctx.stroke(path, with: .color(silhouette), style: stroke)
    }
    /// Courbe quadratique silhouette.
    private func yCurve(_ ctx: GraphicsContext, _ a: CGPoint, _ b: CGPoint, _ ctrl: CGPoint, _ stroke: StrokeStyle) {
        var path = Path(); path.move(to: a); path.addQuadCurve(to: b, control: ctrl)
        ctx.stroke(path, with: .color(silhouette), style: stroke)
    }
    /// Tête (cercle r≈3).
    private func yHead(_ ctx: GraphicsContext, _ c: CGPoint, _ s: CGFloat, _ stroke: StrokeStyle) {
        let r = 3 * s
        ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)),
                   with: .color(silhouette), style: stroke)
    }

    /// Salabhasana (Sauterelle) — couché sur le ventre, tête/buste ET jambes décollés (banane).
    private func drawSalabhasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(38, 44), p(50, 44)], stroke)         // bassin/ventre au sol (zone de contact)
        yCurve(ctx, p(38, 44), p(18, 29), p(26, 35), stroke) // buste + tête bien hauts (gauche)
        yHead(ctx, p(15, 27), s, stroke)
        yLimb(ctx, [p(26, 36), p(38, 42)], stroke)         // bras le long du corps vers l'arrière
        yCurve(ctx, p(50, 44), p(66, 29), p(58, 35), stroke) // jambes bien hautes (droite)
    }

    /// Ustrasana (Chameau) — à genoux, cambrure arrière, mains aux talons.
    private func drawUstrasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(34, 46), p(48, 46)], stroke)       // tibias/pieds au sol
        yLimb(ctx, [p(41, 46), p(40, 32)], stroke)       // cuisse verticale
        yCurve(ctx, p(40, 32), p(48, 27), p(46, 28), stroke) // buste cambré en arrière
        yHead(ctx, p(50, 28), s, stroke)
        yLimb(ctx, [p(45, 28), p(47, 44)], stroke)       // bras vers le talon
    }

    /// Dhanurasana (Arc) — couché ventre, mains attrapent les chevilles, corps en arc.
    private func drawDhanurasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(30, 44), p(42, 44)], stroke)       // ventre au sol
        yCurve(ctx, p(34, 44), p(25, 37), p(28, 40), stroke) // buste relevé
        yHead(ctx, p(21, 35), s, stroke)
        yCurve(ctx, p(42, 44), p(52, 31), p(51, 40), stroke) // cuisse → tibia relevés
        yLimb(ctx, [p(26, 38), p(51, 31)], stroke)       // bras tendu (la « corde » de l'arc)
    }

    /// Phalakasana (Planche yoga) — gainage bras tendus, corps en ligne.
    private func drawPhalakasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(20, 46), p(20, 33)], stroke)       // bras tendu vertical
        yLimb(ctx, [p(20, 33), p(60, 44)], stroke)       // corps gainé épaule→talons
        yHead(ctx, p(16, 32), s, stroke)
        yLimb(ctx, [p(58, 44), p(62, 46)], stroke)       // pied
    }

    /// Upavistha Konasana — assise jambes écartées, flexion avant.
    private func drawUpavisthaKonasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(18, 46), p(40, 41), p(62, 46)], stroke) // jambes en grand V
        yCurve(ctx, p(40, 41), p(40, 45), p(36, 43), stroke)  // buste plonge en avant
        yHead(ctx, p(39, 44), s, stroke)
        yLimb(ctx, [p(40, 43), p(30, 46)], stroke)
        yLimb(ctx, [p(40, 43), p(50, 46)], stroke)            // bras vers les pieds
    }

    /// Bakasana (Corbeau) — équilibre sur les bras, genoux posés sur les triceps, pieds décollés.
    private func drawBakasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(37, 46), p(39, 33)], stroke)       // bras quasi VERTICAL (main sol → épaule)
        yLimb(ctx, [p(45, 46), p(43, 33)], stroke)
        yCurve(ctx, p(41, 33), p(49, 29), p(45, 28), stroke) // dos/bassin compact AU-DESSUS des bras
        yCurve(ctx, p(49, 29), p(52, 24), p(53, 27), stroke) // tibias + pieds tuckés EN HAUT derrière
        yLimb(ctx, [p(40, 35), p(44, 37)], stroke)       // genou posé sur le bras
        yHead(ctx, p(33, 36), s, stroke)                 // tête en avant, basse
    }

    /// Purvottanasana (Planche inversée) — face au ciel, corps gainé en ligne montante.
    private func drawPurvottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(16, 44), p(26, 32)], stroke)        // bras : main au sol → épaule
        yLimb(ctx, [p(26, 32), p(44, 32)], stroke)        // bord SUPÉRIEUR PLAT (tronc face au ciel)
        yLimb(ctx, [p(44, 32), p(60, 44)], stroke)        // jambes descendent vers les pieds au sol
        yHead(ctx, p(22, 30), s, stroke)                  // tête basculée en arrière
    }

    /// Uttana Padasana — couché sur le dos, jambes ET bras levés en diagonale.
    private func drawUttanaPadasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yHead(ctx, p(14, 43), s, stroke)
        yLimb(ctx, [p(18, 44), p(40, 44)], stroke)       // tronc au sol
        yLimb(ctx, [p(40, 44), p(60, 30)], stroke)       // jambes levées ~45°
        yLimb(ctx, [p(24, 44), p(42, 33)], stroke)       // bras parallèles aux jambes
    }

    /// Prasarita Padottanasana — debout jambes très écartées, flexion avant tête au sol.
    private func drawPrasaritaPadottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(22, 46), p(40, 30)], stroke)       // jambe G
        yLimb(ctx, [p(58, 46), p(40, 30)], stroke)       // jambe D
        yCurve(ctx, p(40, 30), p(40, 43), p(45, 37), stroke) // buste plonge
        yHead(ctx, p(40, 43), s, stroke)
        yLimb(ctx, [p(40, 42), p(40, 46)], stroke)       // mains au sol
    }

    /// Padahastasana — debout, flexion avant complète, mains sous les pieds.
    private func drawPadahastasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(39, 46), p(40, 25)], stroke)       // jambe verticale
        yLimb(ctx, [p(45, 46), p(40, 25)], stroke)       // 2e jambe (ensemble en haut)
        yCurve(ctx, p(40, 25), p(42, 44), p(43, 33), stroke) // buste plié SERRÉ le long des jambes
        yHead(ctx, p(42, 43), s, stroke)                 // tête près des pieds
        yLimb(ctx, [p(42, 42), p(41, 46)], stroke)       // mains sous les pieds
    }

    /// Ardha Matsyendrasana — torsion vertébrale assise.
    private func drawArdhaMatsyendrasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(22, 46), p(34, 45), p(40, 44)], stroke) // jambe du bas à plat au sol (gauche)
        yLimb(ctx, [p(40, 44), p(43, 36), p(40, 46)], stroke) // genou levé + pied planté (droite)
        yLimb(ctx, [p(40, 44), p(39, 28)], stroke)        // buste vertical
        yHead(ctx, p(42, 25), s, stroke)                  // tête TOURNÉE (décalée droite) = torsion
        yLimb(ctx, [p(39, 30), p(45, 39)], stroke)        // bras avant en appui contre le genou
        yLimb(ctx, [p(39, 33), p(31, 38)], stroke)        // bras arrière qui enveloppe (côté opposé)
    }

    /// Kapotasana (Pigeon royal) — à genoux, cambrure arrière profonde, mains vers les pieds.
    private func drawKapotasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(28, 46), p(46, 46)], stroke)       // tibias au sol
        yLimb(ctx, [p(38, 46), p(38, 32)], stroke)       // cuisse verticale
        yCurve(ctx, p(38, 32), p(50, 41), p(53, 30), stroke) // cambrure profonde, tête vers les pieds
        yHead(ctx, p(50, 42), s, stroke)
        yCurve(ctx, p(38, 33), p(47, 43), p(40, 28), stroke) // bras au-dessus vers les pieds
    }

    /// Bhujapidasana (Pression épaule) — équilibre bras, jambes en appui sur les bras, pieds devant.
    private func drawBhujapidasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(39, 46), p(41, 35)], stroke)       // bras quasi VERTICAL (main sol → épaule)
        yLimb(ctx, [p(46, 46), p(44, 35)], stroke)
        yCurve(ctx, p(42, 35), p(48, 31), p(47, 32), stroke) // bassin compact au-dessus
        yHead(ctx, p(35, 33), s, stroke)                 // tête en avant
        yLimb(ctx, [p(43, 37), p(34, 41), p(41, 43)], stroke) // jambes EN AVANT par-dessus les bras, pieds croisés devant
    }

    /// Garbha Pindasana (Embryon) — boule compacte en équilibre sur le sacrum.
    private func drawGarbhaPindasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yCurve(ctx, p(40, 44), p(36, 32), p(32, 40), stroke) // dos arrondi vers la tête
        yHead(ctx, p(35, 31), s, stroke)
        yCurve(ctx, p(40, 44), p(46, 33), p(49, 40), stroke) // jambes repliées en boule
        yLimb(ctx, [p(37, 35), p(45, 35)], stroke)       // bras passés entre les jambes
    }

    /// Karnapidasana (Genoux aux oreilles) — inversion sur les épaules, genoux repliés au sol près de la tête.
    private func drawKarnapidasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yHead(ctx, p(22, 44), s, stroke)                  // tête au sol (gauche)
        yLimb(ctx, [p(16, 46), p(28, 45)], stroke)        // nuque/épaules au sol
        yLimb(ctx, [p(28, 45), p(44, 19)], stroke)        // dos monte au bassin (apex haut, inversion type charrue)
        yLimb(ctx, [p(44, 19), p(34, 32)], stroke)        // cuisses redescendent vers la tête
        yLimb(ctx, [p(34, 32), p(26, 44)], stroke)        // tibias pliés, genoux au sol près de la tête (oreilles)
    }

    /// Utthita Hasta Padangusthasana — debout sur une jambe, l'autre tendue tenue par la main.
    private func drawUtthitaHastaPadangusthasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(36, 46), p(38, 30)], stroke)       // jambe d'appui
        yLimb(ctx, [p(38, 30), p(38, 18)], stroke)       // buste
        yHead(ctx, p(38, 14), s, stroke)
        yLimb(ctx, [p(38, 30), p(60, 30)], stroke)       // jambe levée tendue devant
        yLimb(ctx, [p(38, 19), p(58, 30)], stroke)       // bras qui tient l'orteil
        yLimb(ctx, [p(38, 20), p(33, 25)], stroke)       // autre bras sur la hanche
    }

    /// Ardha Baddha Padmottanasana — debout demi-lotus, flexion avant, bras lié dans le dos.
    private func drawArdhaBaddhaPadmottanasana(_ ctx: GraphicsContext, s: CGFloat, stroke: StrokeStyle) {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * s, y: y * s) }
        yLimb(ctx, [p(40, 46), p(40, 26)], stroke)        // jambe d'appui VERTICALE nette (centrée)
        yLimb(ctx, [p(38, 34), p(31, 31), p(38, 29)], stroke) // pied en demi-lotus (triangle sur la cuisse)
        yLimb(ctx, [p(40, 26), p(52, 30)], stroke)        // buste plié ~horizontal vers l'avant
        yHead(ctx, p(54, 31), s, stroke)                  // tête en avant-bas
        yLimb(ctx, [p(50, 30), p(52, 40)], stroke)        // bras libre pend vers le sol
        yLimb(ctx, [p(43, 27), p(36, 24)], stroke)        // bras lié dans le dos (arrière-haut)
    }
}

#if DEBUG
#Preview("Yoga — 17 poses") {
    ScrollView {
        VStack(spacing: 12) {
            ForEach([
                "Chien tête en bas", "Guerrier I", "Guerrier II",
                "Arbre", "Cobra", "Enfant",
                "Pince debout", "Triangle", "Bateau", "Savasana",
                // Story 3.23 Tier 1 Jalon 1
                "Dirgha pranayama", "Cat-cow", "Cat-cow sur les avant-bras",
                // Story 3.23 Tier 1 Jalon 3
                "Sarvangasana (Chandelle)", "Setu Bandha (Pont yoga)",
                "Ujjayi (souffle océan)", "Surya Namaskar A"
            ], id: \.self) { name in
                VStack(alignment: .leading) {
                    Text(verbatim: name).font(.caption)
                    YogaIllustration(sportCode: "yoga", exerciseName: name)
                }
            }
        }
        .padding()
        .background(Color.coachingBackground)
    }
}

#Preview("Yoga POC — fallback orientation + taille") {
    ScrollView {
        VStack(spacing: 16) {
            // D1 — postures NON cataloguées : doivent prendre la bonne orientation
            // (et non plus Warrior I debout systématique).
            Group {
                Text(verbatim: "D1 — fallback orientation (non catalogué)").font(.caption.bold())
                ForEach([
                    ("Jathara Parivartanasana (couché)", "lying attendu"),
                    ("Gomukhasana (assis)", "seated attendu"),
                    ("Utthita Hasta Padangusthasana (debout)", "standing attendu")
                ], id: \.0) { name, expect in
                    VStack(alignment: .leading) {
                        Text(verbatim: "\(name) — \(expect)").font(.caption2).foregroundStyle(.secondary)
                        YogaIllustration(sportCode: "yoga", exerciseName: name, size: 110)
                            .frame(maxWidth: .infinity)
                            .background(Color(uiColor: .secondarySystemBackground))
                    }
                }
            }
            // D4 — une posture connue rendue à la taille FOCUS (176) : grossie + centrée.
            Group {
                Text(verbatim: "D4 — taille FOCUS (176 pt)").font(.caption.bold())
                YogaIllustration(sportCode: "yoga", exerciseName: "Savasana", size: 176)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color.coachingBackground)
    }
}
#endif
