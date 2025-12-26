import Combine
import SwiftUI

struct HuePalette {
    static let roadBase = Color(red: 0.98, green: 0.95, blue: 0.90)
    static let roadAccent = Color(red: 0.96, green: 0.78, blue: 0.45)
    static let roadWarm = Color(red: 0.92, green: 0.62, blue: 0.38)
    static let roadFresh = Color(red: 0.55, green: 0.78, blue: 0.62)
    static let roadSoft = Color(red: 0.86, green: 0.90, blue: 0.82)
    static let roadDark = Color(red: 0.32, green: 0.28, blue: 0.24)
    static let roadMuted = Color(red: 0.74, green: 0.70, blue: 0.66)

    static func tone(for index: Int) -> Color {
        let tones = [
            roadAccent,
            roadFresh,
            roadWarm,
            roadSoft,
            roadMuted
        ]
        return tones[index % tones.count]
    }
}
