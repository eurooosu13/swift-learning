import ArgumentParser
import Foundation
import KanbanCore

@main
struct KanbanCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "kanban",
        abstract: "A small CLI used in the Swift learning course.",
        discussion: "The CLI intentionally uses a JSON store so the first two weeks can focus on SwiftPM, Codable, tests, and command-line workflows.",
        subcommands: [
            Add.self,
            List.self,
            Move.self,
            Edit.self,
            Delete.self
        ],
        defaultSubcommand: List.self
    )
}

struct StoreOptions: ParsableArguments {
    @Option(help: "Path to the JSON card store.")
    var store: String = ".kanban/cards.json"

    func makeService() -> KanbanService {
        KanbanService(store: JSONCardStore(fileURL: URL(fileURLWithPath: store)))
    }
}

struct Add: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Add a card to the board."
    )

    @OptionGroup
    var storeOptions: StoreOptions

    @Argument(help: "Card title.")
    var title: String

    @Option(help: "Longer card notes.")
    var notes: String = ""

    @Option(help: "Initial status: todo, in-progress, or done.")
    var status: String = CardStatus.todo.rawValue

    @Option(help: "Priority: high, medium, or low.")
    var priority: String = CardPriority.medium.rawValue

    @Option(name: .customLong("tag"), help: "Repeatable tag.")
    var tags: [String] = []

    @Option(help: "Optional due date in yyyy-MM-dd format.")
    var due: String?

    mutating func run() throws {
        guard let parsedStatus = CardStatus.parse(status) else {
            throw ValidationError("Unknown status '\(status)'.")
        }
        guard let parsedPriority = CardPriority.parse(priority) else {
            throw ValidationError("Unknown priority '\(priority)'.")
        }

        let draft = try KanbanCardDraft(
            title: title,
            notes: notes,
            status: parsedStatus,
            priority: parsedPriority,
            tags: tags,
            dueDate: try due.map(DayDateParser.parse)
        )
        let card = try storeOptions.makeService().add(draft)
        print("Added \(card.shortID) \(card.title)")
    }
}

struct List: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List cards."
    )

    @OptionGroup
    var storeOptions: StoreOptions

    @Option(help: "Filter by status.")
    var status: String?

    @Option(help: "Filter by priority.")
    var priority: String?

    @Option(help: "Case-insensitive text query.")
    var query: String = ""

    @Option(name: .customLong("tag"), help: "Repeatable tag filter.")
    var tags: [String] = []

    mutating func run() throws {
        let filter = CardFilter(
            query: query,
            status: try status.map(parseStatus),
            priority: try priority.map(parsePriority),
            tags: tags
        )
        let cards = try storeOptions.makeService().list(filter: filter)

        if cards.isEmpty {
            print("No cards.")
            return
        }

        for card in cards {
            print(card.cliLine)
        }
    }
}

struct Move: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Move a card to a different status."
    )

    @OptionGroup
    var storeOptions: StoreOptions

    @Argument(help: "Card UUID prefix.")
    var idPrefix: String

    @Argument(help: "Target status.")
    var status: String

    mutating func run() throws {
        let moved = try storeOptions.makeService().move(
            idPrefix: idPrefix,
            to: parseStatus(status)
        )
        print("Moved \(moved.shortID) to \(moved.status.displayName)")
    }
}

struct Edit: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Replace editable fields on a card."
    )

    @OptionGroup
    var storeOptions: StoreOptions

    @Argument(help: "Card UUID prefix.")
    var idPrefix: String

    @Option(help: "New title.")
    var title: String?

    @Option(help: "New notes.")
    var notes: String?

    @Option(help: "New status.")
    var status: String?

    @Option(help: "New priority.")
    var priority: String?

    @Option(name: .customLong("tag"), help: "Replacement tag. Repeat for multiple tags.")
    var tags: [String] = []

    @Option(help: "Replacement due date in yyyy-MM-dd format.")
    var due: String?

    mutating func run() throws {
        let service = storeOptions.makeService()
        let existing = try service.list().first {
            $0.id.uuidString.lowercased().hasPrefix(idPrefix.lowercased())
        }

        guard let existing else {
            throw ValidationError("No card matches id prefix '\(idPrefix)'.")
        }

        let draft = try KanbanCardDraft(
            title: title ?? existing.title,
            notes: notes ?? existing.notes,
            status: try status.map(parseStatus) ?? existing.status,
            priority: try priority.map(parsePriority) ?? existing.priority,
            tags: tags.isEmpty ? existing.tags : tags,
            dueDate: try due.map(DayDateParser.parse) ?? existing.dueDate
        )
        let edited = try service.replace(idPrefix: idPrefix, with: draft)
        print("Edited \(edited.shortID) \(edited.title)")
    }
}

struct Delete: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Delete a card."
    )

    @OptionGroup
    var storeOptions: StoreOptions

    @Argument(help: "Card UUID prefix.")
    var idPrefix: String

    mutating func run() throws {
        let removed = try storeOptions.makeService().delete(idPrefix: idPrefix)
        print("Deleted \(removed.shortID) \(removed.title)")
    }
}

private func parseStatus(_ value: String) throws -> CardStatus {
    guard let status = CardStatus.parse(value) else {
        throw ValidationError("Unknown status '\(value)'.")
    }
    return status
}

private func parsePriority(_ value: String) throws -> CardPriority {
    guard let priority = CardPriority.parse(value) else {
        throw ValidationError("Unknown priority '\(value)'.")
    }
    return priority
}

private extension KanbanCard {
    var shortID: String {
        String(id.uuidString.prefix(8)).lowercased()
    }

    var cliLine: String {
        let dueText = dueDate.map { " due:\(DayDateParser.string(from: $0))" } ?? ""
        let tagText = tags.isEmpty ? "" : " tags:\(tags.joined(separator: ","))"
        return "\(shortID) [\(status.displayName)] [\(priority.displayName)] \(title)\(dueText)\(tagText)"
    }
}
