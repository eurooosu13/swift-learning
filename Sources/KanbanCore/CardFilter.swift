import Foundation

public struct CardFilter: Equatable, Sendable {
    public var query: String
    public var status: CardStatus?
    public var priority: CardPriority?
    public var tags: [String]

    public init(
        query: String = "",
        status: CardStatus? = nil,
        priority: CardPriority? = nil,
        tags: [String] = []
    ) {
        self.query = query.trimmed
        self.status = status
        self.priority = priority
        self.tags = KanbanCardDraft.normalizedTags(tags)
    }

    public func matches(_ card: KanbanCard) -> Bool {
        if let status, card.status != status {
            return false
        }
        if let priority, card.priority != priority {
            return false
        }
        if !tags.isEmpty, !tags.allSatisfy({ card.tags.contains($0) }) {
            return false
        }
        guard !query.isEmpty else {
            return true
        }

        let haystack = ([card.title, card.notes] + card.tags)
            .joined(separator: " ")
            .localizedCaseInsensitiveContains(query)
        return haystack
    }
}

public extension Sequence where Element == KanbanCard {
    func filtered(using filter: CardFilter) -> [KanbanCard] {
        self.filter { filter.matches($0) }.sortedForBoard()
    }

    func sortedForBoard() -> [KanbanCard] {
        KanbanCore.sortedForBoard(
            self,
            byPriority: \.priority,
            dueDate: \.dueDate,
            updatedAt: \.updatedAt,
            title: \.title
        )
    }
}

public func sortedForBoard<Element>(
    _ values: some Sequence<Element>,
    byPriority priority: KeyPath<Element, CardPriority>,
    dueDate: KeyPath<Element, Date?>,
    updatedAt: KeyPath<Element, Date>,
    title: KeyPath<Element, String>
) -> [Element] {
    values.sorted { lhs, rhs in
        let lhsPriority = lhs[keyPath: priority].sortRank
        let rhsPriority = rhs[keyPath: priority].sortRank
        if lhsPriority != rhsPriority {
            return lhsPriority < rhsPriority
        }

        switch (lhs[keyPath: dueDate], rhs[keyPath: dueDate]) {
        case let (lhsDate?, rhsDate?) where lhsDate != rhsDate:
            return lhsDate < rhsDate
        case (.some, .none):
            return true
        case (.none, .some):
            return false
        default:
            break
        }

        let lhsUpdatedAt = lhs[keyPath: updatedAt]
        let rhsUpdatedAt = rhs[keyPath: updatedAt]
        if lhsUpdatedAt != rhsUpdatedAt {
            return lhsUpdatedAt > rhsUpdatedAt
        }

        return lhs[keyPath: title].localizedCaseInsensitiveCompare(rhs[keyPath: title]) == .orderedAscending
    }
}
