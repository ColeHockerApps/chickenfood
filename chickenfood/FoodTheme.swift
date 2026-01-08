import SwiftUI

enum FoodTheme {

    // MARK: - Colors

    static let background = LinearGradient(
        colors: [
            Color(red: 0.08, green: 0.08, blue: 0.14),
            Color(red: 0.02, green: 0.02, blue: 0.06)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let surface = Color.white.opacity(0.08)
    static let surfaceStrong = Color.white.opacity(0.14)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)

    static let accent = Color(red: 0.45, green: 0.75, blue: 1.0)
    static let accentPrimary = accent
    static let glow = Color(red: 0.55, green: 0.85, blue: 1.0).opacity(0.9)

    static let borderSoft = Color.white.opacity(0.16)
    static let shadow = Color.black.opacity(0.6)

    // MARK: - Layout

    static let cornerRadius: CGFloat = 16

    // MARK: - Fonts

    static func buttonFont() -> Font {
        .system(size: 15, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }

    static func title(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}
