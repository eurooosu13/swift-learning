import Foundation
import XCTest
@testable import KanbanCore

final class KanbanCoreTests: XCTestCase {
    func testStatusParsingAcceptsCommonCLIInputs() throws {
        XCTAssertEqual(CardStatus.parse("todo"), .todo)
        XCTAssertEqual(CardStatus.parse("in-progress"), .inProgress)
        XCTAssertEqual(CardStatus.parse("in progress"), .inProgress)
        XCTAssertEqual(CardStatus.parse("wip"), .inProgress)
        XCTAssertEqual(CardStatus.parse("done"), .done)
        XCTAssertNil(CardStatus.parse("blocked"))
    }

    func testPriorityParsingAndOrdering() throws {
        XCTAssertEqual(CardPriority.parse("low"), .low)
        XCTAssertEqual(CardPriority.parse("medium"), .medium)
        XCTAssertEqual(CardPriority.parse("high"), .high)
        XCTAssertLessThan(CardPriority.high.sortRank, CardPriority.medium.sortRank)
    }

    func testDraftValidationNormalizesTagsAndRejectsEmptyTitles() throws {
        let draft = try KanbanCardDraft(
            title: "  Learn SwiftData  ",
            notes: "Persist cards",
            status: .todo,
            priority: .high,
            tags: [" Swift ", "", "UI", "swift"]
        )

        XCTAssertEqual(draft.title, "Learn SwiftData")
        XCTAssertEqual(draft.tags, ["swift", "ui"])

        XCTAssertThrowsError(try KanbanCardDraft(title: "   "))
    }

    func testFilteringMatchesTextStatusPriorityAndTags() throws {
        let cards = try [
            KanbanCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                draft: KanbanCardDraft(title: "Build CLI", status: .todo, priority: .medium, tags: ["cli"]),
                createdAt: Date(timeIntervalSince1970: 100)
            ),
            KanbanCard(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                draft: KanbanCardDraft(title: "Wire SwiftData", status: .inProgress, priority: .high, tags: ["app", "swiftdata"]),
                createdAt: Date(timeIntervalSince1970: 200)
            )
        ]

        let filter = CardFilter(query: "swift", status: .inProgress, priority: .high, tags: ["app"])

        XCTAssertEqual(cards.filtered(using: filter).map(\.title), ["Wire SwiftData"])
    }

    func testJSONCardStoreRoundTripsCards() throws {
        let temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let storeURL = temporaryDirectory.appendingPathComponent("cards.json")
        let store = JSONCardStore(fileURL: storeURL)
        let card = try KanbanCard(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            draft: KanbanCardDraft(title: "Test persistence", priority: .low, tags: ["test"]),
            createdAt: Date(timeIntervalSince1970: 300)
        )

        try store.saveCards([card])

        XCTAssertEqual(try store.loadCards(), [card])
    }

    func testServiceMovesCardsByUUIDPrefix() throws {
        let store = InMemoryCardStore()
        let service = KanbanService(store: store)
        let card = try service.add(
            KanbanCardDraft(title: "Move me", status: .todo, priority: .medium)
        )

        let moved = try service.move(idPrefix: String(card.id.uuidString.prefix(8)), to: .done)

        XCTAssertEqual(moved.status, .done)
        XCTAssertEqual(try service.list().first?.status, .done)
    }

    func testAsyncLoaderReturnsStoredCards() async throws {
        let card = try KanbanCard(draft: KanbanCardDraft(title: "Async lesson"))
        let store = InMemoryCardStore(initialCards: [card])
        let loader = AsyncCardLoader(store: store)

        let cards = try await loader.loadCards(afterNanoseconds: 1)

        XCTAssertEqual(cards, [card])
    }

    // Day1: Test String Blank Detection
    func testStringBlankDection() throws {
        XCTAssertTrue("   ".isBlank)
        XCTAssertTrue("\n\t".isBlank)
        XCTAssertFalse("  a  ".isBlank)
    }
}
