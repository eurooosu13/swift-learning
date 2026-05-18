import Foundation

public struct AsyncCardLoader {
    private let store: CardStore

    public init(store: CardStore) {
        self.store = store
    }

    public func loadCards(afterNanoseconds delay: UInt64 = 0) async throws -> [KanbanCard] {
        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }

        return try store.loadCards().sortedForBoard()
    }
}
