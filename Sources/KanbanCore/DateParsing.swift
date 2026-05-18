import Foundation

public enum DayDateParser {
    public static func parse(_ value: String) throws -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter.date(from: value.trimmed) else {
            throw DayDateParserError.invalidDate(value)
        }

        return date
    }

    public static func string(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

public enum DayDateParserError: Error, Equatable, LocalizedError {
    case invalidDate(String)

    public var errorDescription: String? {
        switch self {
        case .invalidDate(let value):
            "Expected date '\(value)' to use yyyy-MM-dd format."
        }
    }
}
