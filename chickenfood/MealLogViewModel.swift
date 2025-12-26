import Combine
import Foundation

final class MealLogViewModel: ObservableObject {
    @Published private(set) var dayStamp: String = FormatKit.dayStamp(from: Date())
    @Published private(set) var dayTitle: String = ""
    @Published private(set) var entries: [MealEntry] = []

    @Published var editorEntryId: UUID? = nil
    @Published var editorSlot: MealSlot = .breakfast
    @Published var editorTitle: String = ""
    @Published var editorNote: String = ""
    @Published var isEditing: Bool = false

    @Published var templatePickerSlot: MealSlot = .breakfast
    @Published private(set) var slotTemplates: [MealTemplate] = []

    private let logStore: MealLogStore
    private let templateStore: TemplateStore
    private var bag = Set<AnyCancellable>()

    init(
        logStore: MealLogStore = .shared,
        templateStore: TemplateStore = .shared
    ) {
        self.logStore = logStore
        self.templateStore = templateStore

        logStore.$days
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &bag)

        templateStore.$collections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadTemplates()
            }
            .store(in: &bag)

        setDayStamp(FormatKit.dayStamp(from: Date()))
        reloadTemplates()
    }

    func setDayStamp(_ stamp: String) {
        dayStamp = stamp
        dayTitle = FormatKit.readableDay(from: stamp)
        reload()
        resetEditor()
    }

    func goToday() {
        setDayStamp(FormatKit.dayStamp(from: Date()))
        HapticsHub.shared.tapLight()
    }

    func goPreviousDay() {
        guard let date = dateFromStamp(dayStamp) else { return }
        guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: date) else { return }
        setDayStamp(FormatKit.dayStamp(from: prev))
        HapticsHub.shared.tapLight()
    }

    func goNextDay() {
        guard let date = dateFromStamp(dayStamp) else { return }
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return }
        setDayStamp(FormatKit.dayStamp(from: next))
        HapticsHub.shared.tapLight()
    }

    func startNew(slot: MealSlot) {
        editorEntryId = nil
        editorSlot = slot
        editorTitle = ""
        editorNote = ""
        isEditing = true
        HapticsHub.shared.tapMedium()
    }

    func edit(entry: MealEntry) {
        editorEntryId = entry.id
        editorSlot = entry.slot
        editorTitle = entry.title
        editorNote = entry.note
        isEditing = true
        HapticsHub.shared.tapLight()
    }

    func cancelEditing() {
        resetEditor()
        HapticsHub.shared.tapLight()
    }

    func saveEditing() {
        let title = sanitized(editorTitle)
        let note = sanitized(editorNote)
        guard title.isEmpty == false else { return }

        let entry = MealEntry(
            id: editorEntryId ?? UUID(),
            slot: editorSlot,
            title: title,
            note: note,
            createdAt: editorEntryId == nil ? Date() : (entries.first(where: { $0.id == editorEntryId })?.createdAt ?? Date())
        )

        logStore.upsertMeal(dayStamp: dayStamp, entry: entry)
        resetEditor()
        HapticsHub.shared.success()
    }

    func delete(entryId: UUID) {
        logStore.deleteMeal(dayStamp: dayStamp, id: entryId)
        if editorEntryId == entryId {
            resetEditor()
        }
        HapticsHub.shared.tapMedium()
    }

    func setTemplateSlot(_ slot: MealSlot) {
        templatePickerSlot = slot
        reloadTemplates()
        HapticsHub.shared.tapLight()
    }

    func applyTemplate(_ template: MealTemplate) {
        editorEntryId = nil
        editorSlot = template.slot
        editorTitle = template.title
        editorNote = template.defaultNote
        isEditing = true
        HapticsHub.shared.success()
    }

    func quickAddTemplate(_ template: MealTemplate) {
        let entry = MealEntry(
            slot: template.slot,
            title: sanitized(template.title),
            note: sanitized(template.defaultNote)
        )
        guard entry.title.isEmpty == false else { return }
        logStore.upsertMeal(dayStamp: dayStamp, entry: entry)
        HapticsHub.shared.success()
    }

    private func reload() {
        let log = logStore.log(for: dayStamp)
        entries = log.mealsSorted()
    }

    private func reloadTemplates() {
        slotTemplates = templateStore.templates(for: templatePickerSlot)
            .sorted {
                if $0.slot.orderIndex == $1.slot.orderIndex {
                    return $0.createdAt < $1.createdAt
                }
                return $0.slot.orderIndex < $1.slot.orderIndex
            }
    }

    private func resetEditor() {
        editorEntryId = nil
        editorSlot = .breakfast
        editorTitle = ""
        editorNote = ""
        isEditing = false
    }

    private func sanitized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func dateFromStamp(_ stamp: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: stamp)
    }
}
