import Foundation

public struct KanbanCard: Codable, Equatable, Identifiable, Sendable {
    public let id: UUID
    public var title: String
    public var notes: String
    public var status: CardStatus
    public var priority: CardPriority
    public var tags: [String]
    public var dueDate: Date?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        draft: KanbanCardDraft,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        title = draft.title
        notes = draft.notes
        status = draft.status
        priority = draft.priority
        tags = draft.tags
        dueDate = draft.dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }

    public mutating func apply(_ draft: KanbanCardDraft, updatedAt: Date = Date()) {
        title = draft.title
        notes = draft.notes
        status = draft.status
        priority = draft.priority
        tags = draft.tags
        dueDate = draft.dueDate
        self.updatedAt = updatedAt
    }

    public mutating func move(to status: CardStatus, updatedAt: Date = Date()) {
        self.status = status
        self.updatedAt = updatedAt
    }
}
