import Combine
import SwiftUI

@main
struct ChickenFoodApp: App {
    @StateObject private var router = AppRouter()
    @StateObject private var orientation = FoodOrientationManager.shared
    @StateObject private var launch = FoodLaunchPoints()

    @State private var minLoadingPassed = false
    @State private var pendingDecision: PendingDecision? = nil
    @State private var didApplyOnce = false

    private enum PendingDecision: String {
        case consent
        case main
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if router.stage == .loading {
                    FoodMainScreen()
                } else if router.stage == .consent {
                    ConsentGateScreen()
                } else {
                    MainMenuScreen()
                }
            }
            .environmentObject(router)
            .environmentObject(orientation)
            .environmentObject(launch)
            .onAppear {

                orientation.allowFlexible()

                minLoadingPassed = false
                pendingDecision = nil
                didApplyOnce = false

                let base = launch.mainPoint.absoluteString

                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    minLoadingPassed = true

                    applyPendingIfNeeded()
                }
            }
            .onReceive(orientation.$activeValue) { value in
                let urlStr = value?.absoluteString ?? "nil"
                let baseHost = launch.mainPoint.host?.lowercased()
                let nowHost = value?.host?.lowercased()


                
                guard let _ = value else { return }
                guard let baseHost, let nowHost else { return }

                let decision: PendingDecision = (nowHost == baseHost) ? .consent : .main

                
                if minLoadingPassed {
                    apply(decision)
                } else {
                    pendingDecision = decision

                }
            }
        }
    }

    private func applyPendingIfNeeded() {
        guard let d = pendingDecision else {

            return
        }

        apply(d)
        pendingDecision = nil

    }

    private func apply(_ decision: PendingDecision) {

        
        guard router.stage == .loading else {

            return
        }

        if didApplyOnce {

            return
        }

        didApplyOnce = true

        switch decision {
        case .consent:

            router.requireConsentIfNeeded()

        case .main:


            break
        }
    }
}
