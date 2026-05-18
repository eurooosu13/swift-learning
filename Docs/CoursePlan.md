# Swift + SwiftUI Four-Week Course

This course assumes you already know one mainstream programming language. Explanations are intentionally practical: every day has a concept, a coding exercise, and a verification step.

## Week 1: Swift Core And SwiftPM

### Day 1: Project, SwiftPM, Git
- Concept: package structure, targets, products, and test targets.
- Code: inspect `Package.swift`, run the initial core test suite, and add one tiny helper function.
- Verify: `swift test`.

### Day 2: Types, Optionals, Control Flow
- Concept: enums, raw values, optional parsing, and `switch`.
- Code: extend `CardStatus.parse(_:)` and `CardPriority.parse(_:)`.
- Verify: enum parsing tests.

### Day 3: Structs And Value Semantics
- Concept: structs, initializers, immutable identity, mutable fields.
- Code: update `KanbanCardDraft` validation and tag normalization.
- Verify: draft validation tests.

### Day 4: Collections And Closures
- Concept: arrays, dictionaries, sets, key paths, sorting closures.
- Code: adjust `CardFilter` and board sorting.
- Verify: search/filter tests.

### Day 5: Errors And Codable
- Concept: throwing functions, `LocalizedError`, `Codable`, JSON files.
- Code: add a new persistence edge case to `JSONCardStore`.
- Verify: temp-file persistence tests.

### Day 6: CLI With ArgumentParser
- Concept: executables, arguments, options, subcommands.
- Code: practice `kanban add`, `list`, and `move`.
- Verify: `swift run kanban ...`.

### Day 7: Integration Day
- Concept: refactoring without changing behavior.
- Code: clean names, update README examples, commit the first stable checkpoint.
- Verify: `swift test` and CLI smoke commands.

## Week 2: Design, Testing, And Async

### Day 8: Protocols And Stores
- Concept: protocols as behavior contracts.
- Code: add behavior to `CardStore` or `KanbanService`.
- Verify: in-memory store tests.

### Day 9: Generics And Sequences
- Concept: generic helpers and sequence extensions.
- Code: modify `sortedForBoard` and add one test for ordering.
- Verify: generic helper tests.

### Day 10: XCTest Patterns
- Concept: fixtures, temp directories, failure cases.
- Code: add tests for duplicate IDs or invalid prefixes.
- Verify: targeted XCTest run.

### Day 11: async/await
- Concept: `async`, `await`, `Task.sleep`, async XCTest.
- Code: extend `AsyncCardLoader`.
- Verify: async loader test.

### Day 12: GitHub And CI Basics
- Concept: workflow triggers, hosted runners, quality gates.
- Code: inspect `.github/workflows/ci.yml`.
- Verify: push to GitHub and confirm Actions starts.

### Day 13: Xcode Project And App Target
- Concept: app target, local core library, build settings.
- Code: open `KanbanBoard.xcodeproj` and build the app scheme.
- Verify: `xcodebuild ... build`.

### Day 14: Integration Day
- Concept: keeping package and app workflows aligned.
- Code: update README and fix any broken command.
- Verify: `swift test`, `swift build`, and Xcode build.

## Week 3: SwiftUI And SwiftData

### Day 15: SwiftUI Layout
- Concept: `View`, `VStack`, `HStack`, `ForEach`, native macOS materials.
- Code: inspect the three-column board.
- Verify: app launches and shows columns.

### Day 16: State And Forms
- Concept: `@State`, `@Binding`, sheets, forms.
- Code: edit `CardEditorView` and validation behavior.
- Verify: manual create/edit flow.

### Day 17: SwiftData Model
- Concept: `@Model`, model containers, `@Query`.
- Code: inspect `CardModel` and how raw values bridge to core enums.
- Verify: create a card, relaunch, confirm it remains.

### Day 18: SwiftData CRUD
- Concept: insert, mutate, delete, save.
- Code: trace `ContentView.save`, `move`, and `delete`.
- Verify: manual CRUD checklist.

### Day 19: Filtering And Movement
- Concept: view-derived filtering and status transitions.
- Code: adjust search, priority, or tag filtering.
- Verify: filter and move cards across columns.

### Day 20: Accessibility And Testability
- Concept: accessibility identifiers as UI-test contracts.
- Code: inspect every `.accessibilityIdentifier`.
- Verify: UI tests can find stable elements.

### Day 21: Integration Day
- Concept: tightening the user workflow.
- Code: remove rough edges and add one focused test.
- Verify: package tests and app build.

## Week 4: UI Tests, CI, And Release Polish

### Day 22: Xcode Unit Tests
- Concept: Xcode test targets versus SwiftPM tests.
- Code: run the `KanbanCoreTests` target from Xcode.
- Verify: Xcode test output.

### Day 23: UI Test Setup
- Concept: `XCUIApplication`, launch arguments, clean test data.
- Code: inspect `--uitesting-reset-store` in `ContentView`.
- Verify: UI test launches the app.

### Day 24: Full CRUD UI Test
- Concept: testing user-visible behavior rather than implementation.
- Code: inspect `KanbanBoardUITests`.
- Verify: create, edit, search, move, relaunch, delete.

### Day 25: GitHub Actions
- Concept: CI as a repeatable quality gate.
- Code: push the public repo and inspect the macOS job logs.
- Verify: `swift test`, Xcode build, and Xcode tests pass remotely.

### Day 26: iOS Adaptation Comparison
- Concept: shared views, navigation differences, simulator risk.
- Code: write notes about which views could move into a shared package.
- Verify: no iOS simulator requirement.

### Day 27: Release Polish
- Concept: README, screenshots, license, archive notes.
- Code: update README after your final local run.
- Verify: repo is presentable.

### Day 28: Final Review
- Concept: demo script and maintenance backlog.
- Code: record known limitations and stretch goals.
- Verify: app runs, CLI runs, tests pass, CI is green.

## Stretch Goals

- Drag and drop cards between columns.
- Multiple boards.
- Keyboard shortcuts for moving cards.
- SwiftData migration exercise.
- iOS target once simulator or device workflow is stable.
