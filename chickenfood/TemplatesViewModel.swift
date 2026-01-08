import Combine
import Foundation

final class TemplatesViewModel: ObservableObject {
    @Published private(set) var collections: [TemplateCollection] = []
    @Published var selectedCollectionId: UUID?
    @Published var draftTitle: String = ""
    @Published var draftNote: String = ""
    @Published var draftSlot: MealSlot = .breakfast
    @Published var draftCollectionName: String = ""

    private let store: TemplateStore
    private var bag = Set<AnyCancellable>()

    init(store: TemplateStore = .shared) {
        self.store = store
 
        store.$collections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.collections = items
                if self.selectedCollectionId == nil {
                    self.selectedCollectionId = items.first?.id
                } else if let sel = self.selectedCollectionId, items.contains(where: { $0.id == sel }) == false {
                    self.selectedCollectionId = items.first?.id
                }
            }
            .store(in: &bag)
    }

    func pickCollection(_ id: UUID) {
        selectedCollectionId = id
        HapticsHub.shared.tapLight()
    }

    func resetDraft() {
        draftTitle = ""
        draftNote = ""
        draftSlot = .breakfast
    }

    func createCollection() {
        let name = sanitized(draftCollectionName)
        guard name.isEmpty == false else { return }
        store.addCollection(name: name)
        draftCollectionName = ""
        if selectedCollectionId == nil {
            selectedCollectionId = store.collections.first?.id
        }
        HapticsHub.shared.success()
    }

    func createTemplate() {
        guard let collectionId = selectedCollectionId else { return }
        let title = sanitized(draftTitle)
        let note = sanitized(draftNote)

        guard title.isEmpty == false else { return }

        store.addTemplate(
            title: title,
            slot: draftSlot,
            note: note,
            collectionId: collectionId
        )

        resetDraft()
        HapticsHub.shared.success()
    }

    func deleteTemplate(_ id: UUID) {
        store.removeTemplate(id: id)
        HapticsHub.shared.tapMedium()
    }

    func collectionName(for id: UUID?) -> String {
        guard let id else { return "" }
        return collections.first(where: { $0.id == id })?.name ?? ""
    }

    func templates(in collection: TemplateCollection) -> [MealTemplate] {
        collection.templates.sorted {
            if $0.slot.orderIndex == $1.slot.orderIndex {
                return $0.createdAt < $1.createdAt
            }
            return $0.slot.orderIndex < $1.slot.orderIndex
        }
    }

    private func sanitized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
