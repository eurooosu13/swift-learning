import Foundation

public protocol CardStore: AnyObject {
    func loadCards() throws -> [KanbanCard]
    func saveCards(_ cards: [KanbanCard]) throws
}

public final class InMemoryCardStore: CardStore {
    private var cards: [KanbanCard]

    public init(initialCards: [KanbanCard] = []) {
        cards = initialCards
    }

    public func loadCards() throws -> [KanbanCard] {
        cards
    }

    public func saveCards(_ cards: [KanbanCard]) throws {
        self.cards = cards
    }
}

public final class JSONCardStore: CardStore {
    private struct CardFile: Codable {
        var cards: [KanbanCard]
    }

    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(fileURL: URL, fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    public func loadCards() throws -> [KanbanCard] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(CardFile.self, from: data).cards
    }

    public func saveCards(_ cards: [KanbanCard]) throws {
        let directory = fileURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        let data = try encoder.encode(CardFile(cards: cards.sortedForBoard()))
        try data.write(to: fileURL, options: [.atomic])
    }
}
