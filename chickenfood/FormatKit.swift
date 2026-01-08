import Combine
import Foundation

struct FormatKit {
    static func dayStamp(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
 
    static func readableDay(from stamp: String) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: stamp) else {
            return stamp
        }

        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }

    static func timeLabel(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    static func clampText(_ text: String, limit: Int) -> String {
        if text.count <= limit {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: limit)
        return String(text[..<index])
    }
}
