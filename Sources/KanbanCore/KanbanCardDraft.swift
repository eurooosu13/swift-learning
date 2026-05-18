import Foundation

public struct KanbanCardDraft: Codable, Equatable, Sendable {
    public var title: String
    public var notes: String
    public var status: CardStatus
    public var priority: CardPriority
    public var tags: [String]
    public var dueDate: Date?

    public init(
        title: String,
        notes: String = "",
        status: CardStatus = .todo,
        priority: CardPriority = .medium,
        tags: [String] = [],
        dueDate: Date? = nil
    ) throws {
        let normalizedTitle = title.trimmed
        guard !normalizedTitle.isEmpty else {
            throw KanbanValidationError.emptyTitle
        }
        guard normalizedTitle.count <= 120 else {
            throw KanbanValidationError.titleTooLong(limit: 120)
        }

        let normalizedNotes = notes.trimmed
        guard normalizedNotes.count <= 2_000 else {
            throw KanbanValidationError.notesTooLong(limit: 2_000)
        }

        self.title = normalizedTitle
        self.notes = normalizedNotes
        self.status = status
        self.priority = priority
        self.tags = Self.normalizedTags(tags)
        self.dueDate = dueDate
    }

    public static func normalizedTags(_ tags: [String]) -> [String] {
        Array(
            Set(
                tags
                    .map { $0.trimmed.lowercased() }
                    .filter { !$0.isEmpty }
            )
        )
        .sorted()
    }
}

public enum KanbanValidationError: Error, Equatable, LocalizedError {
    case emptyTitle
    case titleTooLong(limit: Int)
    case notesTooLong(limit: Int)

    public var errorDescription: String? {
        switch self {
        case .emptyTitle:
            "Card title cannot be empty."
        case .titleTooLong(let limit):
            "Card title must be \(limit) characters or fewer."
        case .notesTooLong(let limit):
            "Card notes must be \(limit) characters or fewer."
        }
    }
}
