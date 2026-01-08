import Combine
import SwiftUI

struct LoadingScreen: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var boot = BootViewModel()
 
    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()
            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(HuePalette.roadAccent.opacity(0.55))
                        .frame(width: 108, height: 108)

                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                }

                Text("Chicken Food")
                    .font(TastyRoadTheme.titleFont)
                    .foregroundStyle(HuePalette.roadDark)

                Text("Tasty Road")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.78))

                ProgressView()
                    .padding(.top, 10)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.white.opacity(0.72))
                    .shadow(color: TastyRoadTheme.softShadow(), radius: 18, x: 0, y: 10)
            )
            .padding(.horizontal, 22)
        }
        .onAppear {
            boot.run(router: router)
        }
    }
}
