import SwiftUI
import Combine

struct FoodLoadingScreen: View {

    @State private var spin = false
    @State private var pulse = false
    @State private var sparkle = false

    var body: some View {
        ZStack {
            FoodTheme.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    FoodTheme.accentPrimary.opacity(0.2),
                                    FoodTheme.accentPrimary.opacity(0.8),
                                    FoodTheme.accentPrimary.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 4
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(
                            .linear(duration: 2.2)
                                .repeatForever(autoreverses: false),
                            value: spin
                        )

                    ForEach(0..<6, id: \.self) { i in
                        Text("🍗")
                            .font(.system(size: 18))
                            .opacity(sparkle ? 1 : 0.35)
                            .offset(y: -80)
                            .rotationEffect(.degrees(Double(i) * 60))
                            .scaleEffect(pulse ? 1.15 : 0.85)
                            .animation(
                                .easeInOut(duration: 1.4)
                                    .repeatForever()
                                    .delay(Double(i) * 0.15),
                                value: pulse
                            )
                    }
                }

                VStack(spacing: 6) {
                    Text("Loading...")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(FoodTheme.textPrimary)

//                    Text("Warming up the kitchen")
//                        .font(.system(size: 14, weight: .regular))
//                        .foregroundColor(FoodTheme.textSecondary)
                }
            }
        }
        .onAppear {
            spin = true
            pulse = true
            sparkle = true
        }
    }
}
