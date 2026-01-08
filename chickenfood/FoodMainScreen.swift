import SwiftUI
import Combine

struct FoodMainScreen: View {

    @EnvironmentObject private var orientation: FoodOrientationManager

    @State private var showLoading: Bool = true
    @State private var minTimePassed: Bool = false
    @State private var surfaceReady: Bool = false

    var body: some View {
        ZStack {
            FoodPlayContainer {
                surfaceReady = true
                tryFinishLoading()
            }
            .opacity(showLoading ? 0 : 1)
            .animation(.easeOut(duration: 0.35), value: showLoading)

            if showLoading {
                FoodLoadingScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            orientation.allowFlexible()

            showLoading = true
            minTimePassed = false
            surfaceReady = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                minTimePassed = true
                tryFinishLoading()
            }
        }
    }

    private func tryFinishLoading() {
        guard minTimePassed && surfaceReady else { return }
        withAnimation(.easeOut(duration: 0.35)) {
            showLoading = false
        }
    }
}
