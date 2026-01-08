import Foundation
import Combine
import SwiftUI

@MainActor
final class FoodLaunchPoints: ObservableObject {

    @Published var mainPoint: URL
    @Published var privacyPoint: URL

    private let mainKey = "chickenfood.main"
    private let privacyKey = "chickenfood.privacy"
    private let resumeKey = "chickenfood.resume"
    private let marksKey = "chickenfood.marks"

    private var didStoreResume = false

    init() {
        let defaults = UserDefaults.standard

        let defaultMain = "https://colehockerapps.github.io/foodreceipts"
        let defaultPrivacy = "https://www.freeprivacypolicy.com/live/dcd3a139-8fff-459c-8899-e254e3080528"

        if let saved = defaults.string(forKey: mainKey),
           let value = URL(string: saved) {
            mainPoint = value
        } else {
            mainPoint = URL(string: defaultMain)!
        }

        if let saved = defaults.string(forKey: privacyKey),
           let value = URL(string: saved) {
            privacyPoint = value
        } else {
            privacyPoint = URL(string: defaultPrivacy)!
        }
    }

    func updateMain(_ value: String) {
        guard let point = URL(string: value) else { return }
        mainPoint = point
        UserDefaults.standard.set(value, forKey: mainKey)
    }

    func updatePrivacy(_ value: String) {
        guard let point = URL(string: value) else { return }
        privacyPoint = point
        UserDefaults.standard.set(value, forKey: privacyKey)
    }

    func storeResumeIfNeeded(_ point: URL) {
        guard didStoreResume == false else { return }
        didStoreResume = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: resumeKey) != nil {
            return
        }

        defaults.set(point.absoluteString, forKey: resumeKey)
    }

    func restoreResume() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: resumeKey),
           let point = URL(string: saved) {
            return point
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func loadMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }

    func resetAll() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: mainKey)
        defaults.removeObject(forKey: privacyKey)
        defaults.removeObject(forKey: resumeKey)
        defaults.removeObject(forKey: marksKey)
        didStoreResume = false
    }
}
