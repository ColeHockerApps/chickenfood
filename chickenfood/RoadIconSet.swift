import Combine
import SwiftUI

struct RoadIconSet {
    static let breakfast = "sunrise"
    static let lunch = "fork.knife"
    static let dinner = "moon.stars"
    static let snack = "takeoutbag.and.cup.and.straw"

    static let template = "square.grid.2x2"
    static let add = "plus.circle.fill"
    static let edit = "pencil"
    static let delete = "trash"
    static let settings = "gearshape.fill"
    static let road = "map.fill"
    static let check = "checkmark.circle.fill"
    static let note = "note.text"

    static func mealIcon(for slot: MealSlot) -> String {
        switch slot {
        case .breakfast: return breakfast
        case .lunch: return lunch
        case .dinner: return dinner
        case .snack: return snack
        }
    }
}
