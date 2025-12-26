import Combine
import SwiftUI

struct MealEditorScreen: View {
    @Binding var isPresented: Bool
    @Binding var slot: MealSlot
    @Binding var title: String
    @Binding var note: String

    let onSave: () -> Void
    let onCancel: () -> Void
    let headerTitle: String

    @State private var localPressed = false

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                formCard
                actionRow
                Spacer(minLength: 0)
            }
            .padding(18)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(HuePalette.tone(for: slot.orderIndex).opacity(0.40))
                    .frame(width: 44, height: 44)
                Text("🍗")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(headerTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text(slot.title)
                    .font(TastyRoadTheme.captionFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                HapticsHub.shared.tapLight()
                onCancel()
                isPresented = false
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

                TextField("Write meal name", text: $title)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.78))
                    )
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Note")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.8))

                TextEditor(text: $note)
                    .frame(minHeight: 160)
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

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button {
                HapticsHub.shared.tapLight()
                onCancel()
                isPresented = false
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Cancel")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.72))
                )
            }
            .buttonStyle(.plain)

            Button {
                guard sanitized(title).isEmpty == false else { return }
                HapticsHub.shared.success()
                onSave()
                isPresented = false
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
                        .fill(HuePalette.roadAccent.opacity(localPressed ? 0.75 : 0.95))
                )
                .opacity(sanitized(title).isEmpty ? 0.55 : 1.0)
                .scaleEffect(localPressed ? 0.985 : 1.0)
                .animation(.spring(response: 0.26, dampingFraction: 0.82), value: localPressed)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in localPressed = true }
                    .onEnded { _ in localPressed = false }
            )
        }
    }

    private func sanitized(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
