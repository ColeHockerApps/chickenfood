import Combine
import Foundation

final class MealLogStore: ObservableObject {
    static let shared = MealLogStore()

    @Published private(set) var days: [DayMealLog] = []

    private let storeKey = "tastyroad.meallogs"
    private let local = LocalStore.shared

    private init() {
        if let saved = local.load([DayMealLog].self, key: storeKey) {
            days = saved
        } else {
            days = []
            persist()
        }
    }

    func log(for dayStamp: String) -> DayMealLog {
        if let found = days.first(where: { $0.dayStamp == dayStamp }) {
            return found
        }
        let created = DayMealLog(dayStamp: dayStamp, meals: [])
        days.insert(created, at: 0)
        persist()
        return created
    }

    func upsertMeal(dayStamp: String, entry: MealEntry) {
        if let dayIndex = days.firstIndex(where: { $0.dayStamp == dayStamp }) {
            if let mealIndex = days[dayIndex].meals.firstIndex(where: { $0.id == entry.id }) {
                days[dayIndex].meals[mealIndex] = entry
            } else {
                days[dayIndex].meals.append(entry)
            }
        } else {
            var created = DayMealLog(dayStamp: dayStamp, meals: [])
            created.meals.append(entry)
            days.insert(created, at: 0)
        }
        normalizeOrder()
        persist()
    }

    func deleteMeal(dayStamp: String, id: UUID) {
        guard let dayIndex = days.firstIndex(where: { $0.dayStamp == dayStamp }) else { return }
        days[dayIndex].meals.removeAll { $0.id == id }
        if days[dayIndex].meals.isEmpty {
            days.remove(at: dayIndex)
        }
        persist()
    }

    func clearAll() {
        days.removeAll()
        persist()
    }

    private func normalizeOrder() {
        days.sort { $0.dayStamp > $1.dayStamp }
        for i in days.indices {
            days[i].meals = days[i].mealsSorted()
        }
    }

    private func persist() {
        local.save(days, key: storeKey)
    }
}
