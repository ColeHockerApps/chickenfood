import Combine
import SwiftUI

struct MealLogScreen: View {
    @StateObject private var vm = MealLogViewModel()
    @State private var isTemplatePickerPresented = false

    var body: some View {
        VStack(spacing: 14) {
            header
            dayNav
            quickAddRow
            logList
        }
        .padding(.top, 4)
        .sheet(isPresented: $vm.isEditing) {
            MealEditorScreen(
                isPresented: $vm.isEditing,
                slot: $vm.editorSlot,
                title: $vm.editorTitle,
                note: $vm.editorNote,
                onSave: { vm.saveEditing() },
                onCancel: { vm.cancelEditing() },
                headerTitle: vm.editorEntryId == nil ? "New Meal" : "Edit Meal"
            )
            .presentationDetents([.large])
        }
        .sheet(isPresented: $isTemplatePickerPresented) {
            TemplatePickerSheet(
                slot: $vm.templatePickerSlot,
                templates: vm.slotTemplates,
                onPickSlot: { vm.setTemplateSlot($0) },
                onQuickAdd: { vm.quickAddTemplate($0) },
                onEdit: { vm.applyTemplate($0) },
                onClose: { isTemplatePickerPresented = false }
            )
            .presentationDetents([.large])
        }
        .onAppear {
            vm.goToday()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadAccent.opacity(0.40))
                    .frame(width: 54, height: 54)

                Text("🍽️")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Meal Log")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)

                Text(vm.dayTitle)
                    .font(TastyRoadTheme.bodyFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.72))
                    .lineLimit(1)
            }

            Spacer()

            Button {
                HapticsHub.shared.tapLight()
                vm.goToday()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                        .frame(width: 44, height: 44)

                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var dayNav: some View {
        HStack(spacing: 10) {
            Button {
                vm.goPreviousDay()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Prev")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.72))
                )
            }
            .buttonStyle(.plain)

            Button {
                vm.goNextDay()
            } label: {
                HStack(spacing: 8) {
                    Text("Next")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white.opacity(0.72))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 2)
    }

    private var quickAddRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(MealSlot.allCases.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { slot in
                    Button {
                        vm.startNew(slot: slot)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: RoadIconSet.mealIcon(for: slot))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text(slot.title)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.70)
                        }
                        .foregroundStyle(HuePalette.roadDark)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(HuePalette.tone(for: slot.orderIndex).opacity(0.35))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                HapticsHub.shared.tapMedium()
                isTemplatePickerPresented = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: RoadIconSet.template)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Use Template")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .foregroundStyle(HuePalette.roadDark)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                        .shadow(color: TastyRoadTheme.softShadow(), radius: 14, x: 0, y: 8)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var logList: some View {
        VStack(spacing: 10) {
            if vm.entries.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(vm.entries) { entry in
                            entryRow(entry)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadSoft.opacity(0.8))
                    .frame(width: 64, height: 64)

                Image(systemName: RoadIconSet.note)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
            }

            Text("No meals yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(HuePalette.roadDark)

            Text("Tap a meal slot above to add a new meal.")
                .font(TastyRoadTheme.bodyFont)
                .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                Button {
                    HapticsHub.shared.tapMedium()
                    vm.startNew(slot: .breakfast)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: RoadIconSet.add)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Add Breakfast")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(HuePalette.roadDark)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(HuePalette.roadAccent.opacity(0.92))
                    )
                }
                .buttonStyle(.plain)

                Button {
                    HapticsHub.shared.tapLight()
                    isTemplatePickerPresented = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: RoadIconSet.template)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Templates")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .foregroundStyle(HuePalette.roadDark)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 18)
    }

    private func entryRow(_ entry: MealEntry) -> some View {
        let tone = HuePalette.tone(for: entry.slot.orderIndex)

        return Button {
            vm.edit(entry: entry)
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(tone.opacity(0.35))
                        .frame(width: 48, height: 48)

                    Image(systemName: RoadIconSet.mealIcon(for: entry.slot))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(entry.slot.title)
                            .font(TastyRoadTheme.captionFont)
                            .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Text("•")
                            .font(TastyRoadTheme.captionFont)
                            .foregroundStyle(HuePalette.roadDark.opacity(0.45))
                        Text(FormatKit.timeLabel(from: entry.createdAt))
                            .font(TastyRoadTheme.captionFont)
                            .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    }

                    if entry.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                        Text(entry.note)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark.opacity(0.68))
                            .lineLimit(2)
                    }
                }

                Spacer()

                Button {
                    vm.delete(entryId: entry.id)
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                            .frame(width: 42, height: 42)

                        Image(systemName: RoadIconSet.delete)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark.opacity(0.75))
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.white.opacity(0.72))
            )
        }
        .buttonStyle(.plain)
    }
}

private struct TemplatePickerSheet: View {
    @Binding var slot: MealSlot
    let templates: [MealTemplate]
    let onPickSlot: (MealSlot) -> Void
    let onQuickAdd: (MealTemplate) -> Void
    let onEdit: (MealTemplate) -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()

            VStack(spacing: 14) {
                topBar
                slotStrip
                listCard
                Spacer(minLength: 0)
            }
            .padding(18)
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.35))
                    .frame(width: 44, height: 44)
                Text("⚡️")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Templates")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Quick add or edit before saving")
                    .font(TastyRoadTheme.captionFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
            }

            Spacer()

            Button {
                HapticsHub.shared.tapLight()
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
    }

    private var slotStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(MealSlot.allCases.sorted(by: { $0.orderIndex < $1.orderIndex }), id: \.self) { s in
                    let isSelected = s == slot
                    Button {
                        slot = s
                        onPickSlot(s)
                        HapticsHub.shared.tapLight()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: RoadIconSet.mealIcon(for: s))
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                            Text(s.title)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .lineLimit(1)
                                .minimumScaleFactor(0.70)
                        }
                        .foregroundStyle(HuePalette.roadDark.opacity(isSelected ? 1.0 : 0.68))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? HuePalette.tone(for: s.orderIndex).opacity(0.42) : Color.white.opacity(0.72))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var listCard: some View {
        VStack(spacing: 10) {
            if templates.isEmpty {
                VStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(HuePalette.roadSoft.opacity(0.8))
                            .frame(width: 64, height: 64)

                        Image(systemName: RoadIconSet.template)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark)
                    }

                    Text("No templates for this slot")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)

                    Text("Create templates in the Templates screen.")
                        .font(TastyRoadTheme.bodyFont)
                        .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.vertical, 18)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(templates) { t in
                            templateRow(t)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private func templateRow(_ t: MealTemplate) -> some View {
        let tone = HuePalette.tone(for: t.slot.orderIndex)

        return HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tone.opacity(0.35))
                    .frame(width: 48, height: 48)

                Image(systemName: RoadIconSet.mealIcon(for: t.slot))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(t.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                    .lineLimit(1)

                Text(t.slot.title)
                    .font(TastyRoadTheme.captionFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer()

            Button {
                onEdit(t)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.72))
                        .frame(width: 42, height: 42)

                    Image(systemName: RoadIconSet.edit)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark.opacity(0.75))
                }
            }
            .buttonStyle(.plain)

            Button {
                onQuickAdd(t)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(HuePalette.roadAccent.opacity(0.85))
                        .frame(width: 42, height: 42)

                    Image(systemName: RoadIconSet.add)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.72))
        )
    }
}
