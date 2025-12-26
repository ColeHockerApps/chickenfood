import Combine
import Foundation

final class SettingsViewModel: ObservableObject {
    @Published var privacyURLString: String = ""
    @Published var isPrivacyPresented: Bool = false
    @Published private(set) var privacyURL: URL? = nil

    @Published var isResetConsentAlertPresented: Bool = false

    private let local = LocalStore.shared
    private let urlKey = "tastyroad.settings.privacy.url"

    init() {
        if let saved: String = local.load(String.self, key: urlKey) {
            privacyURLString = saved
        } else {
            privacyURLString = "https://www.freeprivacypolicy.com/live/dcd3a139-8fff-459c-8899-e254e3080528"
            persistURL()
        }
        updateURL()
    }

    func setPrivacyURL(_ raw: String) {
        privacyURLString = raw
        persistURL()
        updateURL()
        HapticsHub.shared.tapLight()
    }

    func openPrivacy() {
        updateURL()
        guard privacyURL != nil else { return }
        isPrivacyPresented = true
        HapticsHub.shared.tapMedium()
    }

    func closePrivacy() {
        isPrivacyPresented = false
        HapticsHub.shared.tapLight()
    }

    func requestResetConsent() {
        isResetConsentAlertPresented = true
        HapticsHub.shared.warning()
    }

    func clearAllData() {
        local.remove(key: "tastyroad.meallogs")
        local.remove(key: "tastyroad.templates")
        HapticsHub.shared.error()
    }

    private func persistURL() {
        local.save(privacyURLString, key: urlKey)
    }

    private func updateURL() {
        let trimmed = privacyURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        if let url = URL(string: trimmed), url.scheme?.isEmpty == false {
            privacyURL = url
        } else if let url = URL(string: "https://" + trimmed) {
            privacyURL = url
        } else {
            privacyURL = nil
        }
    }
}
