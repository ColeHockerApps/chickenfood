import Combine
import Foundation

final class LocalStore {
    static let shared = LocalStore()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "local.store.queue", qos: .utility)

    private init() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func save<T: Codable>(_ value: T, key: String) {
        queue.async {
            if let data = try? self.encoder.encode(value) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
 
    func load<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? decoder.decode(type, from: data)
    }

    func remove(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func exists(key: String) -> Bool {
        UserDefaults.standard.object(forKey: key) != nil
    }
}
