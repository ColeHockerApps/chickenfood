import Combine
import Foundation

@MainActor
final class AppRouter: ObservableObject {

    enum Stage: String {
        case loading
        case consent
        case main
    }

    enum MainRoute: String {
        case menu
        case templates
        case mealLog
        case settings
    }

    @Published var stage: Stage = .loading
    @Published var mainRoute: MainRoute = .menu

    private let local = LocalStore.shared
    private let consentKey = "tastyroad.user.consent.accepted"
    private var didStart = false

    init() {

        start()
    }

    func start() {
        guard !didStart else {

            return
        }
        didStart = true
        stage = .loading
        mainRoute = .menu

    }

    func requireConsentIfNeeded() {
        let hasConsent = local.exists(key: consentKey)

        
        if hasConsent {
            stage = .main
            mainRoute = .menu

            return
        }

        stage = .consent
        mainRoute = .menu

    }

    func allowMainFromFoodFlow() {

        stage = .main
        if mainRoute != .menu {
            mainRoute = .menu
        }

    }

    func acceptConsent() {

        local.save(true, key: consentKey)
        stage = .main
        mainRoute = .menu

    }

    func resetConsentForTesting() {

        local.remove(key: consentKey)
        stage = .consent
        mainRoute = .menu

    }

    func goMenu() {

        mainRoute = .menu
    }

    func goTemplates() {

        mainRoute = .templates
    }

    func goMealLog() {

        mainRoute = .mealLog
    }

    func goSettings() {

        mainRoute = .settings
    }
}
