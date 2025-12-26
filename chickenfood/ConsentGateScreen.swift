import Combine
import SwiftUI

struct ConsentGateScreen: View {
    @EnvironmentObject private var router: AppRouter
    @State private var isPressed = false

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()

            VStack(spacing: 16) {
                headerCard
                consentCard
                continueButton
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 22)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.35))
                    .frame(width: 58, height: 58)

                Image(systemName: "road.lanes.curved.right")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)

                Text("Notes for meals and templates")
                    .font(TastyRoadTheme.bodyFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.72))
            }

            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var consentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)

                Text("Consent")
                    .font(TastyRoadTheme.sectionFont)
                    .foregroundStyle(HuePalette.roadDark)
            }

            Text("By continuing, you agree to our Privacy Policy and the processing of information you enter in the app on this device.")
                .font(TastyRoadTheme.bodyFont)
                .foregroundStyle(HuePalette.roadDark.opacity(0.78))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .foregroundStyle(HuePalette.roadDark.opacity(0.9))
                Text("You can open Privacy Policy in Settings later.")
                    .font(TastyRoadTheme.captionFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var continueButton: some View {
        Button {
            HapticsHub.shared.success()
            router.acceptConsent()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(HuePalette.roadDark)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(HuePalette.roadAccent.opacity(isPressed ? 0.75 : 0.95))
            )
            .scaleEffect(isPressed ? 0.985 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(.plain)
        .pressEvents {
            isPressed = true
        } onRelease: {
            isPressed = false
        }
    }
}

private struct PressEventsModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

private extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEventsModifier(onPress: onPress, onRelease: onRelease))
    }
}
