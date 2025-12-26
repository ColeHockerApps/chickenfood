import Combine
import SwiftUI

struct MainMenuScreen: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()

            VStack(spacing: 14) {
                header
                routeBody
                bottomBar
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.35))
                    .frame(width: 56, height: 56)

                Text("🍗")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Chicken Food")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Tasty Road")
                    .font(TastyRoadTheme.bodyFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.72))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var routeBody: some View {
        Group {
            switch router.mainRoute {
            case .menu:
                menuBody
            case .templates:
                TemplatesScreen()
            case .mealLog:
                MealLogScreen()
            case .settings:
                SettingsScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var menuBody: some View {
        VStack(spacing: 14) {
            menuCard(
                title: "Meal Log",
                subtitle: "Write meals as notes for the day",
                icon: RoadIconSet.note,
                tone: HuePalette.roadAccent
            ) {
                HapticsHub.shared.tapMedium()
                router.goMealLog()
            }

            menuCard(
                title: "Templates",
                subtitle: "Create reusable meal drafts",
                icon: RoadIconSet.template,
                tone: HuePalette.roadFresh
            ) {
                HapticsHub.shared.tapMedium()
                router.goTemplates()
            }

            menuCard(
                title: "Settings",
                subtitle: "Privacy, reset, and preferences",
                icon: RoadIconSet.settings,
                tone: HuePalette.roadWarm
            ) {
                HapticsHub.shared.tapMedium()
                router.goSettings()
            }

            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private func menuCard(
        title: String,
        subtitle: String,
        icon: String,
        tone: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(tone.opacity(0.38))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)

                    Text(subtitle)
                        .font(TastyRoadTheme.captionFont)
                        .foregroundStyle(HuePalette.roadDark.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.55))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.78))
                    .shadow(color: TastyRoadTheme.softShadow(), radius: 14, x: 0, y: 8)
            )
        }
        .buttonStyle(MainMenuBounceStyle())
    }

    private var bottomBar: some View {
        HStack(spacing: 8) {
            bottomButton(
                title: "Menu",
                icon: RoadIconSet.road,
                isActive: router.mainRoute == .menu
            ) {
                HapticsHub.shared.tapLight()
                router.goMenu()
            }

            bottomButton(
                title: "Log",
                icon: RoadIconSet.note,
                isActive: router.mainRoute == .mealLog
            ) {
                HapticsHub.shared.tapLight()
                router.goMealLog()
            }

            bottomButton(
                title: "Templates",
                icon: RoadIconSet.template,
                isActive: router.mainRoute == .templates
            ) {
                HapticsHub.shared.tapLight()
                router.goTemplates()
            }

            bottomButton(
                title: "Settings",
                icon: RoadIconSet.settings,
                isActive: router.mainRoute == .settings
            ) {
                HapticsHub.shared.tapLight()
                router.goSettings()
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 14, x: 0, y: 8)
        )
    }

    private func bottomButton(
        title: String,
        icon: String,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .foregroundStyle(HuePalette.roadDark.opacity(isActive ? 1.0 : 0.62))
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isActive ? HuePalette.roadSoft.opacity(0.85) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct MainMenuBounceStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
            .opacity(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
    }
}
