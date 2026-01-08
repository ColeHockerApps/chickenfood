import SwiftUI

enum FoodGlyphs {

    static func star(
        size: CGFloat,
        color: Color
    ) -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
            .shadow(
                color: color.opacity(0.35),
                radius: size * 0.6,
                x: 0,
                y: 0
            )
    }
}
