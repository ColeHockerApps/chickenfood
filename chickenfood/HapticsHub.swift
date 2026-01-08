import Combine
import UIKit

final class HapticsHub {
    static let shared = HapticsHub()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let notify = UINotificationFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        notify.prepare()
    }
 
    func prime() {
        impactLight.prepare()
        impactMedium.prepare()
        notify.prepare()
    }

    func tapLight() {
        impactLight.impactOccurred(intensity: 0.8)
        impactLight.prepare()
    }

    func tapMedium() {
        impactMedium.impactOccurred(intensity: 0.9)
        impactMedium.prepare()
    }

    func success() {
        notify.notificationOccurred(.success)
        notify.prepare()
    }

    func warning() {
        notify.notificationOccurred(.warning)
        notify.prepare()
    }

    func error() {
        notify.notificationOccurred(.error)
        notify.prepare()
    }
}
