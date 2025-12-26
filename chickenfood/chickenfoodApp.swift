import Combine
import SwiftUI

@main
struct ChickenFoodApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if router.stage == .loading {
                    LoadingScreen()
                } else if router.stage == .consent {
                    ConsentGateScreen()
                } else {
                    MainMenuScreen()
                }
            }
            .environmentObject(router)
        }
    }
}
