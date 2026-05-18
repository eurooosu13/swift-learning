# Swift Kanban Learning

A four-week Swift learning project that grows from a tested SwiftPM core and CLI into a macOS SwiftUI + SwiftData Mini Kanban Board app.

## What You Build

- `KanbanCore`: Swift models, validation, filtering, JSON persistence, async loading, and tests.
- `kanban`: a Swift ArgumentParser CLI for early SwiftPM practice.
- `KanbanBoardApp`: a macOS SwiftUI app backed by SwiftData.
- `KanbanBoard.xcodeproj`: app, core library, unit test, and UI test targets for Xcode workflows.

## Requirements

- macOS on Apple Silicon
- Xcode 26.5 or newer
- Swift 6.3 or newer

## Run The CLI

```bash
swift run kanban add "Learn Optional" --tag swift --priority high
swift run kanban list
swift run kanban move <id-prefix> done
```

The CLI writes to `.kanban/cards.json` by default.

## Run The App

From Xcode:

```bash
xed KanbanBoard.xcodeproj
```

Select the `KanbanBoardApp` scheme and run.

From Terminal:

```bash
xcodebuild -project KanbanBoard.xcodeproj \
  -scheme KanbanBoardApp \
  -destination 'platform=macOS' \
  -derivedDataPath .build/xcode \
  build
```

The built app appears at `.build/xcode/Build/Products/Debug/KanbanBoardApp.app`.

## Verify

```bash
swift test

xcodebuild -project KanbanBoard.xcodeproj \
  -scheme KanbanBoardApp \
  -destination 'platform=macOS' \
  -derivedDataPath .build/xcode \
  test
```

## Course Materials

The daily course plan lives in [Docs/CoursePlan.md](Docs/CoursePlan.md). Each day follows the same rhythm:

1. Concept: read the Swift or toolchain idea.
2. Code: implement the TODO-guided exercise.
3. Verify: run the listed command or manual check.

## Notes

- The app target uses SwiftData as the main persistence path.
- The early CLI intentionally uses JSON so you can practice `Codable`, file I/O, and command-line workflows before moving into SwiftData.
- The Xcode project is arm64-only to match Apple Silicon local development and the GitHub `macos-26` runner.
