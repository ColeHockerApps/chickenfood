import Combine
import Foundation

struct MealTemplate: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var slot: MealSlot
    var defaultNote: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        slot: MealSlot,
        defaultNote: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.slot = slot
        self.defaultNote = defaultNote
        self.createdAt = createdAt
    }
}

struct TemplateCollection: Identifiable, Codable {
    let id: UUID
    var name: String
    var templates: [MealTemplate]

    init(
        id: UUID = UUID(),
        name: String,
        templates: [MealTemplate]
    ) {
        self.id = id
        self.name = name
        self.templates = templates
    }
}
