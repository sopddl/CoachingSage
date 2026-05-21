import XCTest

final class CoachingSageUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchEnvironment["IS_UI_TESTING"] = "1"
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    func testAppLaunchesToMainTabView() throws {
        // Story 3.8 (UI fix 2026-05-09) — passage en custom HStack tab bar
        // (pattern GardenSage). `app.tabBars` ne matche plus, on cible directement
        // les `accessibilityIdentifier` des boutons.
        XCTAssertTrue(
            app.buttons["tab.session"].waitForExistence(timeout: 5),
            "Onglet Séances doit être visible après auto-auth en mode UI testing"
        )
        XCTAssertTrue(app.buttons["tab.progress"].exists, "Onglet Progrès doit être visible")
        XCTAssertTrue(app.buttons["tab.profile"].exists, "Onglet Profil doit être visible")
        XCTAssertTrue(app.buttons["leon.fab"].exists, "FAB Léon doit être visible (3.8)")
    }

    func testEachTabShowsItsContent() throws {
        // En mode IS_UI_TESTING : ModelContainer in-memory, user pré-authentifié,
        // onboarding complété, mais session Supabase absente → les VMs `refresh`
        // sont gardés hors d'atteinte (pas d'userId). On cible donc des éléments
        // stables qui ne dépendent pas du chargement de données.

        // tab.session — bouton "+" toolbar exposé dès que dashboardViewModel
        // est bootstrappé (indépendant du mode empty/dormantOnly/active).
        app.buttons["tab.session"].tap()
        XCTAssertTrue(
            app.buttons["dashboard.toolbar.create"].waitForExistence(timeout: 5),
            "Tab Séances doit exposer le bouton '+' de création programme"
        )

        // tab.progress — la NavigationBar avec le titre traduit "Progress" (EN)
        // est toujours présente (cf navigationTitle("progress.title")).
        app.buttons["tab.progress"].tap()
        XCTAssertTrue(
            app.navigationBars["Progress"].waitForExistence(timeout: 5),
            "Tab Progrès doit afficher la NavigationBar 'Progress'"
        )

        // tab.profile — sans CoachingProfile inséré, le VM passe en
        // `.error(.notFound)` → bouton `profile.error.signOut` visible. En cas
        // de succès (data seedée future), c'est `profile.account.signOut`.
        // Predicate pour couvrir les deux états sans XCTSkip.
        app.buttons["tab.profile"].tap()
        let signOutPredicate = NSPredicate(
            format: "identifier == 'profile.error.signOut' OR identifier == 'profile.account.signOut'"
        )
        let signOutElement = app.descendants(matching: .any)
            .matching(signOutPredicate)
            .firstMatch
        XCTAssertTrue(
            signOutElement.waitForExistence(timeout: 5),
            "Tab Profil doit exposer un bouton 'Sign out' (state error.notFound ou success)"
        )
    }
}
