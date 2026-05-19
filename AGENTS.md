# Repository Guidelines

## Project Structure & Module Organization

This repository is a Swift learning project built with SwiftPM and an Xcode macOS app project.

- `Sources/KanbanCore/`: shared domain models, validation, filtering, persistence, and service logic.
- `Sources/kanban/`: Swift ArgumentParser CLI entry point and commands.
- `Sources/KanbanBoardApp/`: macOS SwiftUI app, SwiftData models, and views.
- `Tests/KanbanCoreTests/`: SwiftPM XCTest coverage for core logic.
- `Tests/KanbanBoardUITests/`: Xcode UI tests for the app workflow.
- `Docs/`: course and learning materials.
- `scripts/`: helper scripts, currently `build_and_run.sh`.

Keep reusable behavior in `KanbanCore`; keep CLI and SwiftUI concerns in their target-specific folders.

## Build, Test, and Development Commands

- `swift build`: builds the SwiftPM package targets.
- `swift test`: runs the SwiftPM unit tests for `KanbanCore`.
- `swift run kanban list`: runs the CLI against `.kanban/cards.json`.
- `swift run KanbanBoardApp`: launches the SwiftPM app executable.
- `./scripts/build_and_run.sh`: helper wrapper for `swift run KanbanBoardApp`.
- `xcodebuild -project KanbanBoard.xcodeproj -scheme KanbanBoardApp -destination 'platform=macOS' -derivedDataPath .build/xcode build`: builds the Xcode app target.
- `xcodebuild -project KanbanBoard.xcodeproj -scheme KanbanBoardApp -destination 'platform=macOS' -derivedDataPath .build/xcode test`: runs Xcode unit and UI tests.

## Coding Style & Naming Conventions

Use Swift 6 style with 4-space indentation, explicit access control for public API, and small focused types. Name types in `UpperCamelCase`, methods and properties in `lowerCamelCase`, and XCTest methods as `testBehaviorUnderCondition`. Prefer `let` over `var` when values do not change. Avoid unrelated formatting churn; no formatter or linter is currently configured.

## Testing Guidelines

Use XCTest. Add or update `KanbanCoreTests` for domain, parsing, filtering, persistence, and service behavior. Add UI tests only for full app workflows or accessibility-driven interactions. Keep accessibility identifiers stable because UI tests depend on them. Run `swift test` before commits that touch `KanbanCore`; run the Xcode `test` command when app UI or SwiftData behavior changes.

## Review Guidelines

Review code for correctness, user-visible regressions, missing tests, and fit with the target boundaries above. Call out findings first, ordered by severity, and include specific file and line references when possible. Check that shared behavior remains in `KanbanCore`, CLI behavior stays in `Sources/kanban`, and SwiftUI or SwiftData changes stay in `Sources/KanbanBoardApp`. Note any verification you performed, and explicitly mention residual risk when tests were skipped or coverage is limited.

## Commit & Pull Request Guidelines

Recent commits are short, imperative summaries such as `Initial Swift Kanban learning project`. Keep commit subjects concise and describe the user-visible change. Pull requests should include a brief description, tests run, linked issue or course task when applicable, and screenshots only for visible UI changes. Note any skipped verification with the reason.

## Security & Configuration Tips

Do not commit generated state or local build outputs. `.gitignore` already excludes `.build/`, `.swiftpm/`, `.kanban/`, `DerivedData/`, `*.xcresult`, and user-specific Xcode files.
