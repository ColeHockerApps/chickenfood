import Combine
import SwiftUI

struct TemplateEditorScreen: View {
    struct Draft: Equatable {
        var title: String
        var slot: MealSlot
        var note: String
    }

    let headerTitle: String
    let headerSubtitle: String
    let initial: Draft
    let onSave: (Draft) -> Void
    let onCancel: () -> Void

    @State private var title: String
    @State private var slot: MealSlot
    @State private var note: String

    init(
        headerTitle: String,
        headerSubtitle: String,
        initial: Draft,
        onSave: @escaping (Draft) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.headerTitle = headerTitle
        self.headerSubtitle = headerSubtitle
        self.initial = initial
        self.onSave = onSave
        self.onCancel = onCancel
        _title = State(initialValue: initial.title)
        _slot = State(initialValue: initial.slot)
        _note = State(initialValue: initial.note)
    }

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                formCard
                saveButton
                Spacer(minLength: 0)
            }
            .padding(18)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(HuePalette.roadAccent.opacity(0.45))
                    .frame(width: 44, height: 44)
                Text("🧾")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(headerTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text(headerSubtitle)
                    .font(TastyRoadTheme.captionFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                HapticsHub.shared.tapLight()
                onCancel()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    private var formCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(HuePalette.tone(for: slot.orderIndex).opacity(0.35))
                        .frame(width: 42, height: 42)

                    Image(systemName: RoadIconSet.mealIcon(for: slot))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Meal Slot")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark.opacity(0.8))
                    Text(slot.title)
                        .font(TastyRoadTheme.captionFont)
                        .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                }

                Spacer()

                Picker("", selection: $slot) {
                    ForEach(MealSlot.allCases, id: \.self) { s in
                        Text(s.title).tag(s)
                    }
                }
                .pickerStyle(.menu)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.8))

                TextField("", text: $title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.78))
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Default Note")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.8))

                TextEditor(text: $note)
                    .frame(minHeight: 140)
                    .padding(10)
                    .scrollContentBackground(.hidden)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.78))
                    )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var saveButton: some View {
        Button {
            let draft = Draft(
                title: sanitized(title),
                slot: slot,
                note: sanitized(note)
            )
            guard draft.title.isEmpty == false else { return }
            HapticsHub.shared.success()
            onSave(draft)
        } label: {
            HStack(spacing: 10) {
                Image(systemName: RoadIconSet.check)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Save")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(HuePalette.roadDark)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.55))
            )
            .opacity(sanitized(title).isEmpty ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
    }

    private func sanitized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
