import Combine
import Foundation

enum MealSlot: String, CaseIterable, Codable {
    case breakfast
    case lunch
    case dinner
    case snack

    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }

    var orderIndex: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snack: return 3
        }
    }
}

struct MealEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let slot: MealSlot
    var title: String
    var note: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        slot: MealSlot,
        title: String,
        note: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.slot = slot
        self.title = title
        self.note = note
        self.createdAt = createdAt
    }
}

struct DayMealLog: Identifiable, Codable {
    let id: UUID
    let dayStamp: String
    var meals: [MealEntry]

    init(
        id: UUID = UUID(),
        dayStamp: String,
        meals: [MealEntry] = []
    ) {
        self.id = id
        self.dayStamp = dayStamp
        self.meals = meals
    }

    func mealsSorted() -> [MealEntry] {
        meals.sorted {
            if $0.slot.orderIndex == $1.slot.orderIndex {
                return $0.createdAt < $1.createdAt
            }
            return $0.slot.orderIndex < $1.slot.orderIndex
        }
    }
}
