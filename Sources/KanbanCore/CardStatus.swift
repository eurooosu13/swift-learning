import Foundation

public enum CardStatus: String, CaseIterable, Codable, Identifiable, Sendable {
    case todo
    case inProgress = "in-progress"
    case done

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .todo: "Todo"
        case .inProgress: "In Progress"
        case .done: "Done"
        }
    }

    public var sortRank: Int {
        switch self {
        case .todo: 0
        case .inProgress: 1
        case .done: 2
        }
    }

    public static func parse(_ input: String) -> CardStatus? {
        switch input.normalizedToken {
        case "todo", "to-do", "backlog", "t": .todo
        case "in-progress", "inprogress", "doing", "wip", "ip": .inProgress
        case "done", "complete", "completed", "d": .done
        default: nil
        }
    }
}
