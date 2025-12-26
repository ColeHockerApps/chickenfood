import Combine
import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var vm = SettingsViewModel()

    @State private var privacyURL: URL? = nil
    @State private var isPrivacyPresented: Bool = false

    private let urlKey = "tastyroad.settings.privacy.url"

    var body: some View {
        VStack(spacing: 14) {
            header
            privacyCard
            dataCard
            consentCard
        }
        .padding(.top, 4)
        .onAppear {
            loadPrivacyURL()
        }
        .sheet(isPresented: $isPrivacyPresented) {
            PrivacySheet(url: privacyURL, onClose: {
                isPrivacyPresented = false
                HapticsHub.shared.tapLight()
            })
            .presentationDetents([.large])
        }
        .alert("Reset Consent", isPresented: $vm.isResetConsentAlertPresented) {
            Button("Cancel", role: .cancel) {
                HapticsHub.shared.tapLight()
            }
            Button("Reset", role: .destructive) {
                HapticsHub.shared.warning()
                router.resetConsentForTesting()
            }
        } message: {
            Text("App will show the consent screen on next launch.")
        }
        .alert("Clear Data", isPresented: $isClearDataAlert) {
            Button("Cancel", role: .cancel) {
                HapticsHub.shared.tapLight()
            }
            Button("Clear", role: .destructive) {
                vm.clearAllData()
            }
        } message: {
            Text("Templates and meal logs will be removed from this device.")
        }
    }

    @State private var isClearDataAlert = false

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(HuePalette.roadWarm.opacity(0.35))
                    .frame(width: 54, height: 54)

                Text("⚙️")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Settings")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)

                Text("Privacy and device storage")
                    .font(TastyRoadTheme.bodyFont)
                    .foregroundStyle(HuePalette.roadDark.opacity(0.72))
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Privacy Policy")
                    .font(TastyRoadTheme.sectionFont)
                    .foregroundStyle(HuePalette.roadDark)
                Spacer()
            }

            Button {
                guard privacyURL != nil else { return }
                HapticsHub.shared.tapMedium()
                isPrivacyPresented = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "safari.fill")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Open Privacy")
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
                .opacity(privacyURL == nil ? 0.6 : 1.0)
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

    private var dataCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "externaldrive.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Device Data")
                    .font(TastyRoadTheme.sectionFont)
                    .foregroundStyle(HuePalette.roadDark)
                Spacer()
            }

            Text("Templates and meal logs are stored locally on this device.")
                .font(TastyRoadTheme.bodyFont)
                .foregroundStyle(HuePalette.roadDark.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                HapticsHub.shared.warning()
                isClearDataAlert = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Clear Templates and Logs")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .foregroundStyle(HuePalette.roadDark)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(HuePalette.roadSoft.opacity(0.85))
                )
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

    private var consentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HuePalette.roadDark)
                Text("Consent")
                    .font(TastyRoadTheme.sectionFont)
                    .foregroundStyle(HuePalette.roadDark)
                Spacer()
            }

            Text("Reset consent to show the consent screen again.")
                .font(TastyRoadTheme.bodyFont)
                .foregroundStyle(HuePalette.roadDark.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)

            Button {
                vm.requestResetConsent()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("Reset Consent")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
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
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.78))
                .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
        )
    }

    private func loadPrivacyURL() {
        if let saved = LocalStore.shared.load(String.self, key: urlKey) {
            privacyURL = normalizeURL(from: saved)
            return
        }
        let fallback = "https://www.freeprivacypolicy.com/live/dcd3a139-8fff-459c-8899-e254e3080528"
        LocalStore.shared.save(fallback, key: urlKey)
        privacyURL = normalizeURL(from: fallback)
    }

    private func normalizeURL(from raw: String) -> URL? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if let url = URL(string: trimmed), url.scheme?.isEmpty == false { return url }
        return URL(string: "https://" + trimmed)
    }
}

private struct PrivacySheet: View {
    let url: URL?
    let onClose: () -> Void

    var body: some View {
        ZStack {
            HuePalette.roadBase.ignoresSafeArea()
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(HuePalette.roadAccent.opacity(0.45))
                            .frame(width: 44, height: 44)
                        Text("🔒")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Privacy Policy")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark)
                        Text(url?.absoluteString ?? "")
                            .font(TastyRoadTheme.captionFont)
                            .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                            .lineLimit(1)
                    }

                    Spacer()

                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.78))
                        .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
                )

                if let url {
                    PrivacyPolicyView(url: url)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                } else {
                    VStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(HuePalette.roadSoft.opacity(0.8))
                                .frame(width: 64, height: 64)

                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(HuePalette.roadDark.opacity(0.85))
                        }

                        Text("Policy unavailable")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(HuePalette.roadDark)

                        Text("Privacy URL is missing.")
                            .font(TastyRoadTheme.bodyFont)
                            .foregroundStyle(HuePalette.roadDark.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color.white.opacity(0.78))
                            .shadow(color: TastyRoadTheme.softShadow(), radius: 16, x: 0, y: 8)
                    )
                }
            }
            .padding(18)
        }
    }
}
