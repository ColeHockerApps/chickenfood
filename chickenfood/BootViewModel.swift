import Combine
import Foundation

final class BootViewModel: ObservableObject {
    @Published var isReady: Bool = false

    private var bag = Set<AnyCancellable>()

    func run(router: AppRouter) {
        guard !isReady else { return }

        HapticsHub.shared.prime()
        TemplateStore.shared.objectWillChange
            .sink { _ in }
            .store(in: &bag)

        MealLogStore.shared.objectWillChange
            .sink { _ in }
            .store(in: &bag)

        router.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { [weak self] in
            self?.isReady = true
        }
    }
}
