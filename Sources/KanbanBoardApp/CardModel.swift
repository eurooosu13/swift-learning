import Foundation
import KanbanCore
import SwiftData

@Model
final class CardModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var notes: String
    var statusRawValue: String
    var priorityRawValue: String
    var tagsText: String
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        status: CardStatus = .todo,
        priority: CardPriority = .medium,
        tags: [String] = [],
        dueDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        statusRawValue = status.rawValue
        priorityRawValue = priority.rawValue
        tagsText = KanbanCardDraft.normalizedTags(tags).joined(separator: ",")
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }

    var status: CardStatus {
        get { CardStatus(rawValue: statusRawValue) ?? .todo }
        set {
            statusRawValue = newValue.rawValue
            updatedAt = Date()
        }
    }

    var priority: CardPriority {
        get { CardPriority(rawValue: priorityRawValue) ?? .medium }
        set {
            priorityRawValue = newValue.rawValue
            updatedAt = Date()
        }
    }

    var tags: [String] {
        get {
            tagsText
                .split(separator: ",")
                .map { String($0) }
                .filter { !$0.isEmpty }
        }
        set {
            tagsText = KanbanCardDraft.normalizedTags(newValue).joined(separator: ",")
            updatedAt = Date()
        }
    }

    func apply(
        title: String,
        notes: String,
        status: CardStatus,
        priority: CardPriority,
        tags: [String],
        dueDate: Date?
    ) throws {
        let draft = try KanbanCardDraft(
            title: title,
            notes: notes,
            status: status,
            priority: priority,
            tags: tags,
            dueDate: dueDate
        )

        self.title = draft.title
        self.notes = draft.notes
        self.statusRawValue = draft.status.rawValue
        self.priorityRawValue = draft.priority.rawValue
        self.tagsText = draft.tags.joined(separator: ",")
        self.dueDate = draft.dueDate
        self.updatedAt = Date()
    }

    func matches(query: String, priority: CardPriority?, tag: String) -> Bool {
        if let priority, self.priority != priority {
            return false
        }

        let normalizedTag = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !normalizedTag.isEmpty, !tags.contains(normalizedTag) {
            return false
        }

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            return true
        }

        return ([title, notes] + tags)
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(normalizedQuery)
    }
}
