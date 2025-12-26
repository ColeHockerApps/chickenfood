
import Combine
import Foundation
import WebKit
import SwiftUI

final class PrivacyPolicy: NSObject, ObservableObject {
    static let shared = PrivacyPolicy()

    @Published var isPresented: Bool = false
    let policyURL: URL

    private override init() {
        policyURL = URL(string: "https://www.freeprivacypolicy.com/live/dcd3a139-8fff-459c-8899-e254e3080528")!
        super.init()
    }

    func open() {
        isPresented = true
    }

    func close() {
        isPresented = false
    }
}

struct PrivacyPolicyView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.load(URLRequest(url: url))
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
}
