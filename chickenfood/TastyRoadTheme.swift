import Combine
import SwiftUI

struct TastyRoadTheme {
    static let cornerRadiusLarge: CGFloat = 22
    static let cornerRadiusSmall: CGFloat = 12

    static let spacingXS: CGFloat = 6
    static let spacingS: CGFloat = 10
    static let spacingM: CGFloat = 16
    static let spacingL: CGFloat = 24

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let sectionFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 13, weight: .medium, design: .rounded)

    static let shadowColor: Color = Color.black.opacity(0.08)

    static func cardBackground(_ hue: Color) -> some View {
        RoundedRectangle(cornerRadius: cornerRadiusLarge, style: .continuous)
            .fill(hue)
    }

    static func softShadow() -> Color {
        shadowColor
    }
}
