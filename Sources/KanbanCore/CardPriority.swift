import Foundation

public enum CardPriority: String, CaseIterable, Codable, Identifiable, Sendable {
    case high
    case medium
    case low

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        }
    }

    public var sortRank: Int {
        switch self {
        case .high: 0
        case .medium: 1
        case .low: 2
        }
    }

    public static func parse(_ input: String) -> CardPriority? {
        switch input.normalizedToken {
        case "high", "h": .high
        case "medium", "med", "m": .medium
        case "low", "l": .low
        default: nil
        }
    }
}
