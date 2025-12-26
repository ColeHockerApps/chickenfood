import Combine
import Foundation

final class TemplateStore: ObservableObject {
    static let shared = TemplateStore()

    @Published private(set) var collections: [TemplateCollection] = []

    private let storeKey = "tastyroad.templates"
    private let local = LocalStore.shared

    private init() {
        if let saved = local.load([TemplateCollection].self, key: storeKey) {
            collections = saved
        } else {
            collections = TemplateStore.bootstrap()
            persist()
        }
    }

    func allTemplates() -> [MealTemplate] {
        collections.flatMap { $0.templates }
    }

    func templates(for slot: MealSlot) -> [MealTemplate] {
        allTemplates().filter { $0.slot == slot }
    }

    func addTemplate(
        title: String,
        slot: MealSlot,
        note: String,
        collectionId: UUID
    ) {
        guard let index = collections.firstIndex(where: { $0.id == collectionId }) else { return }
        let template = MealTemplate(title: title, slot: slot, defaultNote: note)
        collections[index].templates.append(template)
        persist()
    }

    func addCollection(name: String) {
        let collection = TemplateCollection(name: name, templates: [])
        collections.append(collection)
        persist()
    }

    func removeTemplate(id: UUID) {
        for idx in collections.indices {
            collections[idx].templates.removeAll { $0.id == id }
        }
        persist()
    }

    private func persist() {
        local.save(collections, key: storeKey)
    }

    private static func bootstrap() -> [TemplateCollection] {
        [
            TemplateCollection(
                name: "Daily",
                templates: [
                    MealTemplate(
                        title: "Eggs and Toast",
                        slot: .breakfast,
                        defaultNote: "Simple and filling"
                    ),
                    MealTemplate(
                        title: "Chicken Rice Bowl",
                        slot: .lunch,
                        defaultNote: "Warm and balanced"
                    ),
                    MealTemplate(
                        title: "Soup and Bread",
                        slot: .dinner,
                        defaultNote: "Light evening meal"
                    ),
                    MealTemplate(
                        title: "Fruit Snack",
                        slot: .snack,
                        defaultNote: "Quick bite"
                    )
                ]
            )
        ]
    }
}
