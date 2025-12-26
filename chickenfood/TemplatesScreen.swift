import Combine
import SwiftUI

struct TemplatesScreen: View {
    @StateObject private var vm = TemplatesViewModel()
    @State private var isAddTemplatePresented = false
    @State private var isAddCollectionPresented = false

    var body: some View {
        VStack(spacing: 14) {
            header
            collectionStrip
            templatesList
            actionRow
        }
        .padding(.top, 4)
        .sheet(isPresented: $isAddCollectionPresented) {
            AddCollectionSheet(
                draftName: $vm.draftCollectionName,
                onCreate: {
                    vm.createCollection()
                    isAddCollectionPresented = false
                },
                onClose: {
                    isAddCollectionPresented = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isAddTemplatePresented) {
            AddTemplateSheet(
                selectedCollectionName: vm.collectionName(for: vm.selectedCollectionId),
                title: $vm.draftTitle,
                note: $vm.draftNote,
                slot: $vm.draftSlot,
                onCreate: {
                    vm.createTemplate()
                    isAddTemplatePresented = false
                },
                onClose: {
                    vm.resetDraft()
                    isAddTemplatePresented = false
                }
            )
            .presentationDetents([.large])
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.35))
                    .frame(width: 54, height: 54)

                Text("🧩")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Templates")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)

                Text("Reusable drafts for quick logs")
                    .font(TastyRoadTheme.bodyFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.72))
            }

            Spacer()

            Button {
                HapticsHub.shared.tapLight()
                isAddCollectionPresented = true
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                        .frame(width: 44, height: 44)
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark)
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

    private var collectionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(vm.collections.enumerated()), id: \.element.id) { index, item in
                    let isSelected = vm.selectedCollectionId == item.id
                    Button {
                        vm.pickCollection(item.id)
                    } label: {
                        HStack(spacing: 8) {
                            Text("🍱")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                            Text(item.name)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .lineLimit(1)
                        }
                        .foregroundStyle(HuePalette.roadDark.opacity(isSelected ? 1.0 : 0.7))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? HuePalette.tone(for: index).opacity(0.42) : Color.white.opacity(0.72))
                        )
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    HapticsHub.shared.tapLight()
                    isAddCollectionPresented = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: RoadIconSet.add)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Text("New")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.white.opacity(0.72))
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 2)
        }
        .padding(.horizontal, 6)
    }

    private var templatesList: some View {
        let selected = vm.collections.first(where: { $0.id == vm.selectedCollectionId })
        return VStack(spacing: 10) {
            if let selected {
                if vm.templates(in: selected).isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(vm.templates(in: selected)) { t in
                                templateRow(t, tone: HuePalette.tone(for: t.slot.orderIndex))
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            } else {
                emptyState
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
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadSoft.opacity(0.8))
                    .frame(width: 64, height: 64)

                Image(systemName: RoadIconSet.template)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
            }

            Text("No templates yet")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(HuePalette.roadDark)

            Text("Create a template to reuse it in your meal log.")
                .font(TastyRoadTheme.bodyFont)
                .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 18)
    }

    private func templateRow(_ t: MealTemplate, tone: Color) -> some View {
        HStack(spacing: 12) {
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
            }

            Spacer()

            Button {
                vm.deleteTemplate(t.id)
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

    private var actionRow: some View {
        HStack(spacing: 10) {
            Button {
                guard vm.selectedCollectionId != nil else { return }
                HapticsHub.shared.tapMedium()
                isAddTemplatePresented = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: RoadIconSet.add)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Add Template")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
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
                isAddCollectionPresented = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Add Group")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                }
                .foregroundStyle(HuePalette.roadDark)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(HuePalette.roadFresh.opacity(0.55))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }
}

private struct AddCollectionSheet: View {
    @Binding var draftName: String
    let onCreate: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(HuePalette.roadFresh.opacity(0.35))
                            .frame(width: 44, height: 44)
                        Text("📦")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("New Group")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark)
                        Text("Create a template group")
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

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(HuePalette.roadDark.opacity(0.8))
                    TextField("Daily", text: $draftName)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white.opacity(0.78))
                        )
                }

                Button {
                    onCreate()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: RoadIconSet.check)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        Text("Create")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
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

                Spacer(minLength: 0)
            }
            .padding(18)
        }
    }
}

private struct AddTemplateSheet: View {
    let selectedCollectionName: String
    @Binding var title: String
    @Binding var note: String
    @Binding var slot: MealSlot
    let onCreate: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()
            VStack(spacing: 14) {
                topBar
                formCard
                createButton
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
                Text("📝")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("New Template")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text(selectedCollectionName.isEmpty ? "No group" : selectedCollectionName)
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

    private var formCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: RoadIconSet.mealIcon(for: slot))
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Meal Slot")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark.opacity(0.8))
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
                TextField("Chicken Rice Bowl", text: $title)
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
                    .frame(minHeight: 120)
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

    private var createButton: some View {
        Button {
            onCreate()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: RoadIconSet.check)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Create Template")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundStyle(HuePalette.roadDark)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(HuePalette.roadFresh.opacity(0.55))
            )
        }
        .buttonStyle(.plain)
    }
}
