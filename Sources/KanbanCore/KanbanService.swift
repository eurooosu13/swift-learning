import Foundation

public final class KanbanService {
    private let store: CardStore

    public init(store: CardStore) {
        self.store = store
    }

    public func list(filter: CardFilter = CardFilter()) throws -> [KanbanCard] {
        try store.loadCards().filtered(using: filter)
    }

    @discardableResult
    public func add(_ draft: KanbanCardDraft, now: Date = Date()) throws -> KanbanCard {
        var cards = try store.loadCards()
        let card = KanbanCard(draft: draft, createdAt: now)
        cards.append(card)
        try store.saveCards(cards)
        return card
    }

    @discardableResult
    public func replace(
        idPrefix: String,
        with draft: KanbanCardDraft,
        now: Date = Date()
    ) throws -> KanbanCard {
        var cards = try store.loadCards()
        let index = try Self.index(matching: idPrefix, in: cards)
        cards[index].apply(draft, updatedAt: now)
        try store.saveCards(cards)
        return cards[index]
    }

    @discardableResult
    public func move(
        idPrefix: String,
        to status: CardStatus,
        now: Date = Date()
    ) throws -> KanbanCard {
        var cards = try store.loadCards()
        let index = try Self.index(matching: idPrefix, in: cards)
        cards[index].move(to: status, updatedAt: now)
        try store.saveCards(cards)
        return cards[index]
    }

    @discardableResult
    public func delete(idPrefix: String) throws -> KanbanCard {
        var cards = try store.loadCards()
        let index = try Self.index(matching: idPrefix, in: cards)
        let removed = cards.remove(at: index)
        try store.saveCards(cards)
        return removed
    }

    private static func index(matching idPrefix: String, in cards: [KanbanCard]) throws -> Int {
        let normalizedPrefix = idPrefix.trimmed.lowercased()
        guard !normalizedPrefix.isEmpty else {
            throw KanbanServiceError.invalidIdentifier
        }

        let matches = cards.enumerated().filter {
            $0.element.id.uuidString.lowercased().hasPrefix(normalizedPrefix)
        }

        switch matches.count {
        case 1:
            return matches[0].offset
        case 0:
            throw KanbanServiceError.cardNotFound(idPrefix: idPrefix)
        default:
            throw KanbanServiceError.ambiguousIdentifier(idPrefix: idPrefix)
        }
    }
}

public enum KanbanServiceError: Error, Equatable, LocalizedError {
    case invalidIdentifier
    case cardNotFound(idPrefix: String)
    case ambiguousIdentifier(idPrefix: String)

    public var errorDescription: String? {
        switch self {
        case .invalidIdentifier:
            "Provide a non-empty card id prefix."
        case .cardNotFound(let idPrefix):
            "No card matches id prefix '\(idPrefix)'."
        case .ambiguousIdentifier(let idPrefix):
            "More than one card matches id prefix '\(idPrefix)'."
        }
    }
}
